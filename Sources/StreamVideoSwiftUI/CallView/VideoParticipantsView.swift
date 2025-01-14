//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamVideo
import SwiftUI

public struct VideoParticipantsView<Factory: ViewFactory>: View {
    
    var viewFactory: Factory
    @ObservedObject var viewModel: CallViewModel
    var availableSize: CGSize
    var onViewRendering: (VideoRenderer, CallParticipant) -> Void
    var onChangeTrackVisibility: @MainActor(CallParticipant, Bool) -> Void
    
    @State private var orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown
    
    public init(
        viewFactory: Factory,
        viewModel: CallViewModel,
        availableSize: CGSize,
        onViewRendering: @escaping (VideoRenderer, CallParticipant) -> Void,
        onChangeTrackVisibility: @escaping @MainActor(CallParticipant, Bool) -> Void
    ) {
        self.viewFactory = viewFactory
        self.viewModel = viewModel
        self.availableSize = availableSize
        self.onViewRendering = onViewRendering
        self.onChangeTrackVisibility = onChangeTrackVisibility
    }
    
    public var body: some View {
        ZStack {
            if viewModel.participantsLayout == .fullScreen, let first = viewModel.participants.first {
                ParticipantsFullScreenLayout(
                    viewFactory: viewFactory,
                    participant: first,
                    call: viewModel.call,
                    size: availableSize,
                    onViewRendering: onViewRendering,
                    onChangeTrackVisibility: onChangeTrackVisibility
                )
            } else if viewModel.participantsLayout == .spotlight, let first = viewModel.participants.first {
                ParticipantsSpotlightLayout(
                    viewFactory: viewFactory,
                    participant: first,
                    call: viewModel.call,
                    participants: Array(viewModel.participants.dropFirst()),
                    size: availableSize,
                    onViewRendering: onViewRendering,
                    onChangeTrackVisibility: onChangeTrackVisibility
                )
            } else {
                ParticipantsGridLayout(
                    viewFactory: viewFactory,
                    call: viewModel.call,
                    participants: viewModel.participants,
                    availableSize: availableSize,
                    orientation: orientation,
                    onViewRendering: onViewRendering,
                    onChangeTrackVisibility: onChangeTrackVisibility
                )
            }
        }
        .onRotate { newOrientation in
            orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown
        }
    }
}

public struct VideoCallParticipantModifier: ViewModifier {
            
    @State var popoverShown = false
    
    var participant: CallParticipant
    var call: Call?
    var availableSize: CGSize
    var ratio: CGFloat
    var showAllInfo: Bool
    
    public init(
        participant: CallParticipant,
        call: Call?,
        availableSize: CGSize,
        ratio: CGFloat,
        showAllInfo: Bool
    ) {
        self.participant = participant
        self.call = call
        self.availableSize = availableSize
        self.ratio = ratio
        self.showAllInfo = showAllInfo
    }
    
    public func body(content: Content) -> some View {
        content
            .adjustVideoFrame(to: availableSize.width, ratio: ratio)
            .overlay(
                ZStack {
                    BottomView(content: {
                        HStack {
                            ParticipantInfoView(
                                participant: participant,
                                isPinned: participant.isPinned
                            )
                            
                            if showAllInfo {
                                Spacer()
                                ConnectionQualityIndicator(
                                    connectionQuality: participant.connectionQuality
                                )
                            }
                        }
                        .padding(.bottom, 2)
                    })
                    .padding(.all, showAllInfo ? 16 : 8)
                    
                    if participant.isSpeaking && participantCount > 1 {
                        Rectangle()
                            .strokeBorder(Color.blue.opacity(0.7), lineWidth: 2)
                    }
                    
                    if popoverShown {
                        VStack(spacing: 16) {
                            if !participant.isPinnedRemotely {
                                PopoverButton(
                                    title: pinTitle,
                                    popoverShown: $popoverShown
                                ) {
                                    if participant.isPinned {
                                        Task {
                                            try await call?.unpin(
                                                sessionId: participant.sessionId
                                            )
                                        }
                                    } else {
                                        Task {
                                            try await call?.pin(
                                                sessionId: participant.sessionId
                                            )
                                        }
                                    }
                                }
                            }
                            
                            if call?.state.ownCapabilities.contains(.pinForEveryone) == true {
                                PopoverButton(
                                    title: pinForEveryoneTitle,
                                    popoverShown: $popoverShown
                                ) {
                                    if participant.isPinnedRemotely {
                                        Task {
                                            try await call?.unpinForEveryone(
                                                userId: participant.userId,
                                                sessionId: participant.id
                                            )
                                        }
                                    } else {
                                        Task {
                                            try await call?.pinForEveryone(
                                                userId: participant.userId,
                                                sessionId: participant.id
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .modifier(ShadowViewModifier())
                    }
                }
            )
            .onTapGesture(count: 2, perform: {
                popoverShown = true
            })
            .onTapGesture(count: 1) {
                if popoverShown {
                    popoverShown = false
                }
            }
    }
    
    @MainActor
    private var participantCount: Int {
        call?.state.participants.count ?? 0
    }
    
    private var pinTitle: String {
        participant.isPinned
            ? L10n.Call.Current.unpinUser
            : L10n.Call.Current.pinUser
    }
    
    private var pinForEveryoneTitle: String {
        participant.isPinnedRemotely
            ? L10n.Call.Current.unpinForEveryone
            : L10n.Call.Current.pinForEveryone
    }
    
}

public struct VideoCallParticipantView: View {
    
    @Injected(\.images) var images
    @Injected(\.streamVideo) var streamVideo
        
    let participant: CallParticipant
    var id: String
    var availableSize: CGSize
    var contentMode: UIView.ContentMode
    var edgesIgnoringSafeArea: Edge.Set
    var customData: [String: RawJSON]
    var onViewUpdate: (CallParticipant, VideoRenderer) -> Void
    
    public init(
        participant: CallParticipant,
        id: String? = nil,
        availableSize: CGSize,
        contentMode: UIView.ContentMode,
        edgesIgnoringSafeArea: Edge.Set = .all,
        customData: [String: RawJSON],
        onViewUpdate: @escaping (CallParticipant, VideoRenderer) -> Void
    ) {
        self.participant = participant
        self.id = id ?? participant.id
        self.availableSize = availableSize
        self.contentMode = contentMode
        self.edgesIgnoringSafeArea = edgesIgnoringSafeArea
        self.customData = customData
        self.onViewUpdate = onViewUpdate
    }
    
    public var body: some View {
        VideoRendererView(
            id: id,
            size: availableSize,
            contentMode: contentMode
        ) { view in
            onViewUpdate(participant, view)
        }
        .opacity(showVideo ? 1 : 0)
        .edgesIgnoringSafeArea(edgesIgnoringSafeArea)
        .accessibility(identifier: "callParticipantView")
        .streamAccessibility(value: showVideo ? "1" : "0")
        .overlay(
            CallParticipantImageView(
                id: participant.id,
                name: participant.name,
                imageURL: participant.profileImageURL
            )
            .frame(width: availableSize.width)
            .opacity(showVideo ? 0 : 1)
        )
    }
    
    private var showVideo: Bool {
        participant.shouldDisplayTrack || customData["videoOn"]?.boolValue == true
    }
}

public struct ParticipantInfoView: View {
    @Injected(\.images) var images
    @Injected(\.fonts) var fonts
    
    var participant: CallParticipant
    var isPinned: Bool
    
    public init(participant: CallParticipant, isPinned: Bool) {
        self.participant = participant
        self.isPinned = isPinned
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            if isPinned {
                Image(systemName: "pin.fill")
                    .foregroundColor(.white)
                    .padding(.trailing, 4)
            }
            Text(participant.name)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .font(fonts.caption1)
                .accessibility(identifier: "participantName")
                        
            SoundIndicator(participant: participant)
        }
        .padding(.all, 2)
        .padding(.horizontal, 4)
        .frame(height: 28)
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
    }
}

public struct SoundIndicator: View {
            
    @Injected(\.images) var images
    
    let participant: CallParticipant
    
    public init(participant: CallParticipant) {
        self.participant = participant
    }
    
    public var body: some View {
        (participant.hasAudio ? images.micTurnOn : images.micTurnOff)
            .foregroundColor(.white)
            .padding(.all, 4)
            .accessibility(identifier: "participantMic")
            .streamAccessibility(value: participant.hasAudio ? "1" : "0")
    }
    
}

struct PopoverButton: View {
    
    var title: String
    @Binding var popoverShown: Bool
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
            popoverShown = false
        } label: {
            Text(title)
                .padding(.horizontal)
                .foregroundColor(.primary)
        }
    }
}
