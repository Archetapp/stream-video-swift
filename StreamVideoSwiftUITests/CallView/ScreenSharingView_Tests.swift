//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import StreamVideoSwiftUI
@testable import StreamVideo
import SnapshotTesting
import XCTest

@MainActor
final class ScreenSharingView_Tests: StreamVideoUITestCase {
    
    func test_screenSharingView_snapshot() throws {
        let view = ScreenSharingView(
            viewModel: CallViewModel(),
            screenSharing: .init(track: .none, participant: ParticipantFactory.get(2).last!),
            availableSize: defaultScreenSize
        )
        AssertSnapshot(view)
    }
}
