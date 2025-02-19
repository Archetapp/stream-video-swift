---
title: Audio Room/ Spaces
---

:::warning
TODO before launch:

- Make the tutorial shorter, it's very big
- Update the tutorial not to use hardcoded tokens 
- Update the UI section with "raise hand" features
- Record demo videos to showcase what is built in this guide
- Polish the intro with sample video and relevant explanation of it
- find good way to address repeating installation and setup guide
:::

In this guide, you'll build an audio room experience similar to Twitter Spaces / Clubhouse.m

The final result will look like this:

// TODO add sample video

The code for the final result can also be found on GitHub, so if you're only interested in seeing the resulting code, go [here](https://github.com/GetStream/stream-video-ios-examples/tree/main/AudioRooms).

:::note
For the sake of simplicity the code provided in this guide may be simplified in certain situations. However, there will always be a link to the repository with the full code, so that you'll be able to have a look at that.
:::

Alright, let's get started. Creating this app will require the following steps:

1. [Project setup and Stream Video SDK installation](#project-setup-and-stream-video-sdk-installation)
2. [Setup SDK and prepare the data](#setup-sdk-and-prepare-the-data)
3. [Login the user](#login-the-user)
4. [Show a list of audio rooms](#show-a-list-of-audio-rooms)
5. [Create a room and join the call](#create-a-room-and-join-the-call)

## Project setup and Stream Video SDK installation

This project requires only a machine that is running _macOS_ as well as the latest _Xcode_ version to follow along the guide.

The first thing to do is to create a new _Xcode_ project (_File_ -> _New_ -> _Project_), select _iOS_ and _App_ and hit _Next_. Give it a name that you like and make sure that `SwiftUI` is selected under _Interface_. Save it somewhere on your machine.

// TODO: record a gif that shows the process

Now that the project is created you can add the dependency for the Stream Video SDK. In your newly created project, go to _File_ -> _Add Packages_. In the search bar on the top right, enter the URL to the SDK on GitHub (https://github.com/GetStream/stream-video-swift).

Select the package that pops up and make sure for _Dependency Rule_ to select _Branch_ -> `main`. When clicking on _Add Package_ it will take a moment but then you can select `StreamVideo` in the list of packages that pop up. Hit _Add Package_ again and wait for the package loading to finish.

// TODO: record a gif that shows the process

:::note
The other two packages `StreamVideoSwiftUI` and `StreamVideoUIKit` provide built-in UI elements, ready for you to use and customize. For a tutorial on how to use these take a look [here](./video-call.md). For this one, you'll build out the UI yourself.
:::

With this, the project is set up and all dependencies are installed.

## Setup SDK and prepare the data

Before starting with the code of the application itself, let's take a look at how to initialize the Stream Video SDK. This is the low-level client that directly exposes the calling functionality to you so that you have full control. It requires a few parameters for setup:

- `apiKey`: when creating an application in the [Stream Dashboard](https://dashboard.getstream.io) you will be provided with an API key to identify your application. In our example, we are providing an example application, but feel free to replace this one with your own.
- `user`: the `User` that you are logging in to the application. For this application, there are pre-built users provided.
- `token`: for the authentication with the Stream backend, a user token is required. In this example, the users will have non-expiring tokens provided for simplicity. Otherwise, this requires a backend, handling token generation.
- `videoConfig`: the `VideoConfig` object allows you to set some more advanced settings in the SDK.
- `tokenProvider`: once a token expires, this function will be called so that you can request a new token from your backend and update it. (Not necessary here, since non-expiring tokens are provided)

Now, you will create a new file called `AppState` where you'll handle when a user is selected (you'll build the UI and logic for that in the next chapter) and initialize the SDK accordingly.

Create a new Swift file called `AppState` and add the following code:

```swift
import SwiftUI
import StreamVideo

class AppState: ObservableObject {

    var streamVideo: StreamVideo?

    func login(_ user: UserCredentials) {
        let streamVideo = StreamVideo(
            apiKey: "your_api_key",
            user: user.userInfo,
            token: user.token,
            videoConfig: VideoConfig(),
            tokenProvider: { result in
                result(.success(user.token))
            }
        )
        self.streamVideo = streamVideo
        connectUser()
    }

    private func connectUser() {
        Task {
          try await streamVideo?.connect()
        }
    }
}
```

The `login` function will take care of the selected user and initialize the `StreamVideo` object with the parameters that you just learned about.

:::note
The `apiKey` provided [here](https://github.com/GetStream/stream-video-ios-examples/blob/5ae414d09cbcff39e68b77c6527d8586d11d73fb/AudioRooms/AudioRooms/AppState.swift#L27) will use a Stream project that we set up for you. You can also use your application with your key. For that, visit the [Stream Dashboard](https://dashboard.getstream.io).
:::

This will not yet compile as the `UserCredentials` type does not exist yet. Therefore, create a new file called `UserCredentials` and add this code:

```swift
import Foundation
import StreamVideo

struct UserCredentials: Identifiable, Codable {
    var id: String {
        userInfo.id
    }
    let userInfo: User
    let token: UserToken
}
```

With that, the initial setup is done and you can start with the functionality.

## Login the user

The logic for handling whether a user is logged in or not will be placed in the `AppState`. For that, add an `enum` called `UserState` at the bottom of the `AppState.swift` file:

```swift
enum UserState {
   case notLoggedIn
   case loggedIn
}
```

Next, add a new `@Published` property to the `AppState`:

```swift
@Published var userState: UserState = .notLoggedIn
```

This value can now be used inside the start point of your application. Depending on what you called your application, this might have a different name in our case, this is the `AudioRoomsApp.swift` file. Fill in the code so that it looks like this:

```swift
@main
struct AudioRoomsApp: App {

   // highlight-next-line
   @StateObject var appState = AppState()

   var body: some Scene {
      WindowGroup {
         ZStack {
            // highlight-start
            if appState.userState == .loggedIn {
                  ContentView()
            } else {
                  LoginView(appState: appState)
            }
            // highlight-end
         }
      }
   }
}
```

You have changed two things here. First, you added a `@StateObject` for the `appState` and initialize it here. Then, depending on whether the user is logged in (indicated by `appState.userState`) you conditionally show either the `ContentView` or the `LoginView`.

The latter one does not exist yet, so create a new file, select _SwiftUI View_ for the type and name it `LoginView`. At the top, add an `@ObservedObject` for the `appState` like this:

```swift
@ObservedObject var appState: AppState
```

Now, this code compiles but it doesn't do anything useful yet. What you'll show in the `LoginView` is a list of pre-built users that can be tapped to log the selected user in. For that, you need a list of user credentials. We have created a static variable called `builtInUsers` in the `UserCredentials` file, that you can re-use. The code is extensive and you can find the [full version here](https://github.com/GetStream/stream-video-ios-examples/blob/main/AudioRooms/AudioRooms/Model/UserCredentials.swift). It takes a list of users and maps their `id`, `name`, `imageUrl`, and `token` to a `UserCredentials` object so that you can iterate through it.

With that in place you can add the view code for the `LoginView`, so put this code into your `body`:

```swift
VStack {
   Text("Select a user")
      .font(.title)
      .bold()

   List(UserCredentials.builtInUsers) { user in
      Button {
         appState.login(user)
      } label: {
         Text(user.userInfo.name)
      }
      .padding(.all, 8)
   }
}
.foregroundColor(.primary)
```

This code wraps the `builtInUsers` in a list and shows a button to tap for the user which in turn calls the `login` function on the `appState` that you created previously. With that, the view code is done and you can take a look at the `login` function of the `appState`.

You will add more functionality to it as it will do three things:

1. save the selected user to be able to remember it for future app starts
2. initialize the `StreamVideo` object (you added this code already)
3. update the `userState` to be `.loggedIn`

So, to do this, jump to the `AppState.swift` file and replace the current content of the `login` function with this (see the comments in the code to find each step):

```swift
func login(_ user: UserCredentials) {
   // 1. save the selected user
   UnsecureUserRepository.shared.save(user: user)
   currentUser = user.userInfo

   // 2. initialize StreamVideo
   let streamVideo = StreamVideo(
      apiKey: "us83cfwuhy8n",
      user: user.userInfo,
      token: user.token,
      videoConfig: VideoConfig(),
      tokenProvider: { result in
            result(.success(user.token))
      }
   )
   self.streamVideo = streamVideo

   // 3. update the login state
   userState = .loggedIn
}
```

For this to work, you'll need to add a `currentUser` variable to your `AppState` object:

```swift
var currentUser: User?
```

You might have caught that to save the current user, you are accessing a `UnsecureUserRepository` object. We didn't discuss this yet, but we implemented a convenience class for this. The full code can be found [here](https://github.com/GetStream/stream-video-ios-examples/blob/main/AudioRooms/AudioRooms/Helpers/LocalStorage.swift), so please create a new Swift file, call it `LocalStorage` and copy the code from the file there.

:::warning
It is also mentioned in the source code, but in a production app you should not save user-sensitive data in `UserDefaults`. For the sake of this guide and because we are using hard-coded credentials anyways we went that route, but in a production app, you should treat your user data with a very high sense of privacy.
:::

What the code does can be seen from the protocol it conforms to:

```swift
protocol UserRepository {

    func save(user: UserCredentials)

    func loadCurrentUser() -> UserCredentials?

    func removeCurrentUser()

}
```

It provides functionality to `save` the selected user, `loadCurrentUser` (which you will add in your code next), and to `removeCurrentUser`. This works by saving the user to `UserDefaults`.

The final step in the login process is to check on startup whether there is a user available and if yes set it in our `AppState` to skip the log in process.

For this, add a new function to the `AppState` which checks if a user is saved and calls the `login` function if that is the case:

```swift
func checkLoggedInUser() {
   if let user = UnsecureUserRepository.shared.loadCurrentUser() {
      login(user)
   }
}
```

You'll call this function inside of your application's main file, again in our case this is `AudioRoomsApp` (but yours might have a different name). Add an `onAppear` modifier to the previously created `ZStack`, and inside of it call the `checkLoggedInUser` function of the `appState`:

```swift
ZStack {
   if appState.userState == .loggedIn {
      ContentView()
   } else {
      LoginView(appState: appState)
   }
}
// highlight-start
.onAppear {
   appState.checkLoggedInUser()
}
// highlight-end
```

With that, the login process is finished.

## Show a list of audio rooms

The next thing to do is to show a list of the available audio rooms. From there on the user can tap on a room and join it and, depending on their role will be entering the room as a speaker or a listener.

But let's first think about the data you need for an audio room. A room needs four properties:

1. `id`: a `String` that uniquely identifies this room
2. `title`: the name of the room (also a `String`)
3. `subtitle`: a more detailed description `String` of what this room is about
4. `hosts`: this array of `User` objects will define who can speak in the room

Create a new `Swift` file, call it `AudioRoom`, and add the following code:

```swift
import Foundation
import StreamVideo

struct AudioRoom: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let hosts: [User]
}
```

The audio rooms we can load from our API by performing a `CallsQuery` and implementing an observation on the results.

Create an `AudioRoomsViewModel`; it will take care of the data flow. Please create a new Swift file and call it `AudioRoomsViewModel`. This will contain two `@Published` properties: `audioRooms` (an array of `AudioRoom` objects) and an optional `selectedAudioRoom` set when a room is entered to open up a sheet. Initially, it will load the available rooms from our API and assign them to its `audioRooms` property. On top of that, the loading of the rooms is implemented in such a way that it is an observation of the calls available on our API. Our model will be informed when adding a new room and update the `audioRooms` property accordingly.

Here is the full code of the `AudioRoomsViewModel`:

```swift
import SwiftUI
import StreamVideo
import Combine

@MainActor
class AudioRoomsViewModel: ObservableObject {
    
    @Published var audioRooms = [AudioRoom]()
    @Published var selectedAudioRoom: AudioRoom?
    
    @Injected(\.streamVideo) var streamVideo
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            let callsQuery = CallsQuery(sortParams: [], filters: ["audioRoomCall": .bool(true)], watch: true)
            let controller = streamVideo.makeCallsController(callsQuery: callsQuery)
            controller.$calls
                .sink { retrievedAudioRooms in
                    DispatchQueue.main.async {
                        self.audioRooms = retrievedAudioRooms.compactMap { callData in
                            if let _ = callData.endedAt { return nil }
                            return AudioRoom(from: callData.customData, id: callData.callCid)
                        }
                    }
                }
                .store(in: &cancellables)
            try? await controller.loadNextCalls()
        }
    }
    
    deinit {
        self.cancellables.removeAll()
    }
}
```

We are now able to fetch existing and new audio rooms. But we will also need a way to create room. To do that, we can create a model called `CreateRoomViewModel`. Start by creating a file with the same name and make sure the contents of the file look like this:

```swift
import Foundation
import StreamVideo

class CreateRoomViewModel: ObservableObject {
    
    @Injected(\.streamVideo) var streamVideo
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func createRoom(title: String, description: String) {
        Task {
            let call = self.streamVideo.makeCall(callType: .audioRoom, callId: UUID().uuidString)
            let data = try await call.getOrCreate(
                members: [user.asAdmin],
                customData: [
                    "title": .string(title),
                    "description": .string(description),
                    "hosts": .array([
                        .dictionary(user.toDict())
                    ]),
                    "audioRoomCall": .bool(true)
                ],
                ring: false
            )
            print("Audio room created at \(data.createdAt)")
        }
    }
}
```

It is a straightforward model that allows us to create a new audio room on our API.

With that, you can start the implementation of the view code. Create a new SwiftUI view and call it `AudioRoomsView`. It will have a `@StateObject` for the `AudioRoomsViewModel` and an `@ObservedObject` of type `AppState` that will be handed down from the parent. Next to that, it will obtain a reference to the `StreamVideo` client through injection. We also add a way to initiate the creation of a new audio room. It will then create a scrollable list of all `AudioRoom` elements that act as buttons to join a room. It will also have a logout button in the `toolbar`.

Before you start with the list, you will create a helper view that creates the UI for a single `AudioRoom` element in the list. This makes the code a little more structured. Create a new SwiftUI view called `AudioRoomCell`. Its code will lay out all the properties vertically and not do much else, so here it is:

```swift
struct AudioRoomCell: View {
    
    let audioRoom: AudioRoom
    
    let imageOffset: CGFloat = 10
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(audioRoom.title)
                    .font(.headline)
                
                Text(audioRoom.subtitle)
                    .font(.caption)
                
                HStack(spacing: 30) {
                    ZStack {
                        ForEach(Array(audioRoom.hosts.enumerated()), id: \.offset) { (index, host) in
                            ImageFromUrl(
                                url: host.imageURL,
                                size: 40,
                                offset: -imageOffset * CGFloat(index)
                            )
                        }
                    }
                    .frame(height: 80)
                    .padding(.leading, imageOffset)
                    
                    VStack(alignment: .leading, spacing: imageOffset / 2) {
                        ForEach(audioRoom.hosts) { host in
                            Text(host.name)
                                .font(.headline)
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .foregroundColor(.primary)
        .background(Color.backgroundColor)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

extension Color {
    static var backgroundColor: Color = Color(.displayP3, red: 242.0 / 255.0, green: 243.0 / 255.0, blue: 235.0 / 255.0, opacity: 1)
}
```

:::note
For the preview to work you can hand in the `.preview` that we defined in the `AudioRoom` file. So this should be the view in your preview element: `AudioRoomCell(audioRoom: .preview)`.
:::

Now, you can finally tackle the `AudioRoomsView`. Create a new SwiftUI view and give it the name `AudioRoomsView`. It will have a `NavigationView` at the root with a `ScrollView` that contains the `AudioRoomCell` views that are constructed from the `audioRooms` of the `AudioRoomsViewModel`.

You'll attach a `.sheet` that will open once the optional `selectedAudioRoom` of the `AudioRoomsViewModel` is set on tap of an `AudioRoomCell` element wrapped in a button. And finally, we will add a toolbar button that shows a `.sheet` to display the UI to create an audio room.

Here is the code for the component:

```swift
struct AudioRoomsView: View {
    
    @StateObject var viewModel = AudioRoomsViewModel()
    
    @ObservedObject var appState: AppState
    
    @Injected(\.streamVideo) var streamVideo
    
    @State private var showCreateRoom = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.audioRooms) { audioRoom in
                            Button {
                                viewModel.selectedAudioRoom = audioRoom
                            } label: {
                                AudioRoomCell(audioRoom: audioRoom)
                            }
                        }
                    }
                    .sheet(item: $viewModel.selectedAudioRoom) { audioRoom in
                        AudioRoomView(audioRoom: audioRoom)
                    }
                }
                
                if let _ = appState.currentUser {
                    Button {
                        showCreateRoom = true
                    } label: {
                        Label("Create", systemImage: "plus")
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(in: Capsule())
                    .overlay(Capsule().stroke(Color.secondary, lineWidth: 1))
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 4)
                    .padding(20)
                }
            }
            .navigationTitle("Audio Rooms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appState.logout()
                    } label: {
                        HStack {
                            Text("Logout")
                                .foregroundColor(.primary)
                            
                            ImageFromUrl(
                                url: streamVideo.user.imageURL,
                                size: 32
                            )
                        }
                        .padding(8)
                        .overlay(Capsule().stroke(Color.secondary, lineWidth: 1))
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showCreateRoom) {
                if let user = appState.currentUser {
                    CreateRoomForm(user: user)
                } else {
                    Text("No user found.")
                }
            }
        }
    }
}
```

Let's not forget to add the `CreateRoomForm`. We need a way to allow the user to collect some input before we can create an audio room using the `CreateRoomViewModel`.

Create a Swift file named `CreateRoomForm`. And add the following contents:
You will add one more feature to this view: log out the current user. Let's first implement a function in the `AppState` that does the work and then cover the UI for it. Go to the `AppState` file and add the `logout` function:

```swift
func logout() {
   if let userToken = UnsecureUserRepository.shared.currentVoipPushToken(),
      let controller = streamVideo?.makeVoipNotificationsController() {
      controller.removeDevice(with: userToken)
   }
   UnsecureUserRepository.shared.removeCurrentUser()
   Task {
      await streamVideo?.disconnect()
      streamVideo = nil

      withAnimation {
         userState = .notLoggedIn
      }
   }
}
```

Next, go back to the `AudioRoomsView` file and add the following code below the `.navigationTitle("Audio Rooms")` modifier:

```swift
.toolbar {
   // highlight-next-line
   // 1. Add a ToolbarItem
   ToolbarItem(placement: .navigationBarTrailing) {
      Button {
         // highlight-next-line
         // 2. Call logout on the AppState
         appState.logout()
      } label: {
         // highlight-next-line
         // 3. Show a text and the user image
         HStack {
            Text("Logout")
               .foregroundColor(.primary)

            ImageFromUrl(
               url: streamVideo.user.imageURL,
               size: 32
            )
         }
         .padding(8)
         .overlay(Capsule().stroke(Color.secondary, lineWidth: 1))
      }
      .padding()
   }
}
```

The code does three exciting things:

1. It adds a `ToolbarItem` and places it on the trailing side (with `placement: .navigationBarTrailing`)
2. Call the previously created `.logout` function when the user taps the button
3. Show a `Logout` text and load the user icon to display it in the toolbar

The only thing remaining is to show the view in our app flow. To do this, go to your app file (again: for us it's `AudioRoomsApp` but yours might be different) and replace the line that contains `ContentView()` with `AudioRoomsView(appState: appState)`. You can delete the `ContentView` file since you no longer need it now.

Go ahead and run the app and you will be able to log in and then see a list of the available rooms to join. On tap of a room, a sheet will appear with a dummy Text that you will replace in the next chapter.

## Create a room and join the call

The last remaining thing to do is to create the UI and logic for the audio room itself. This is the most exciting part, so let's start by creating a new Swift file and calling it `AudioRoomViewModel`. It takes care of the logic behind a call and will do a few things. Let's first discuss what it does and then look at the code.

It gets initialized with the `AudioRoom` object that the user has selected to join. The first thing it does is to check whether the user has permission to speak or is joining as a listener. Then, the user joins the call by using the `CallViewModel` that the `StreamVideo` SDK provides. This offers a lot of functionality around calls (as the name suggests) and makes interaction with the SDK simple.

After joining the call, the user will be subscribed to three things:

- changes to the participants of the call (listening to changes in the `callParticipants` property of the `CallViewModel`)
- audio changes, like muting and un-muting (by subscribing to the `callSettings` object in the `CallViewModel`)
- updates to the call state (you guessed it, there's a `callingState` property of the `CallViewModel`)

With all this logic, there are a few properties that the `AudioRoomViewModel` needs, so add those first:

```swift
import Combine
import SwiftUI
import StreamVideo

@MainActor
class AudioRoomViewModel: ObservableObject {

   @Injected(\.streamVideo) var streamVideo

       @Published var callViewModel = CallViewModel()
    
    @Published var hosts = [CallParticipant]()
    @Published var otherUsers = [CallParticipant]()
    
    @Published var hasPermissionsToSpeak = false
    @Published var isUserMuted = true
    @Published var loading = true
    @Published var permissionPopupShown = false
    @Published var revokePermissionPopupShown = false
    @Published var activeCallPermissions = [String: [String]]() {
        didSet {
            hasPermissionsToSpeak = activeCallPermissions[streamVideo.user.id]?.contains("send-audio") == true
                || isCurrentUserHost
        }
    }
    @Published var isCallLive = false
    @Published var callEnded = false
    var revokingParticipant: CallParticipant? {
        didSet {
            if revokingParticipant != nil {
                revokePermissionPopupShown = true
            }
        }
    }
    
    var permissionRequest: PermissionRequest? {
        didSet {
            permissionPopupShown = permissionRequest != nil
        }
    }
    
    private let audioRoom: AudioRoom
    private var cancellables = Set<AnyCancellable>()
    private var call: Call {
        get throws {
            if let call = callViewModel.call {
                return call
            } else {
                throw ClientError.Unknown()
            }
        }
    }
}
```

```note
The `cancellables` object is used to make sure subscriptions are handled correctly and released once the object itself is destroyed. If you are unsure what it does, a refresher in `Combine` is probably a good idea, you can find Apple's docs [here](https://developer.apple.com/documentation/combine).
```

As mentioned before you'll do a few steps in the initializer. Let's create helper functions for each of them, starting with the check of the audio settings. This is used to determine whether a user is part of the speakers or listeners and configuring the `CallSettings` accordingly:

```swift
private func checkAudioSettings() {
    hasPermissionsToSpeak = isCurrentUserHost
    isUserMuted = !isCurrentUserHost
    callViewModel.callSettings = CallSettings(audioOn: isCurrentUserHost, videoOn: false)
}
```

Next, to keep the list of the participants of a call up-to-date you'll subscribe to the `callParticipants` and update the `hosts` and `otherUsers` properties accordingly:

```swift
private func subscribeForParticipantChanges() {
    callViewModel.$callParticipants.sink { [weak self] participants in
        guard let self = self else { return }
        self.update(participants: participants)
    }
    .store(in: &cancellables)
}

private func update(participants: [String: CallParticipant]) {
    var hostIds = self.audioRoom.hosts.map { $0.id }
    self.hosts = participants.filter { (key, participant) in
        hostIds.contains(participant.userId)
    }
    .map { $0.value }
    .sorted(by: { $0.name < $1.name })
    
    for (userId, capabilities) in activeCallPermissions {
        if capabilities.contains("send-audio"),
            let participant = findUser(with: userId, in: participants) {
            hosts.append(participant)
            hostIds.append(userId)
        }
    }
    
    self.otherUsers = participants.filter { (key, participant) in
        !hostIds.contains(participant.userId)
    }
    .map { $0.value }
    .sorted(by: { $0.name < $1.name })
}
```

The next two functions are very straightforward, so you'll implement them together. First, you subscribe to audio changes with the `callSettings` object and update the `isUserMuted` object. Second, the `callingState` is observed, and the `loading`` state is updated.

Here is the code:

```swift
private func subscribeForAudioChanges() {
    callViewModel.$callSettings.sink { [weak self] callSettings in
        guard let self = self else { return }
        self.isUserMuted = !callSettings.audioOn
    }
    .store(in: &cancellables)
}

private func subscribeForCallStateChanges() {
    callViewModel.$callingState.sink { [weak self] callState in
        guard let self = self else { return }
        self.loading = callState != .inCall
        if callState == .inCall {
            self.isCallLive = self.callViewModel.call?.callInfo?.backstage == false
            self.subscribeForCallUpdates()
            self.subscribeForPermissionsRequests()
            self.subscribeForPermissionUpdates()
        }
    }
    .store(in: &cancellables)
}
```

In audio rooms, usually you would need the hosts to be able to control who is able to speak and who should be only a listener. In order to do that, you will need to use the `Call`'s permission features. Additionally, you will need to listen to permission requests and permission updates, so you can update your UI accordingly.

Let's first add a method that will listen to permission requests. These are events triggered by user actions such as "raising a hand."

```swift
private func subscribeForPermissionsRequests() {
    Task {
        for await request in try call.permissionRequests() {
            self.permissionRequest = request
        }
    }
}
```

In this method, we are subscribing to the `Call`'s async stream of permission requests. Whenever there's one, we store it and present an alert to the user, which we will check later on.

Finally, we also need to handle permission updates - events that happen after the hosts have granted a permission based on a user request.

```swift
private func subscribeForPermissionUpdates() {
    Task {
        for await update in try call.permissionUpdates() {
            let userId = update.user.id
            self.activeCallPermissions[userId] = update.ownCapabilities
            if userId == streamVideo.user.id
                && !update.ownCapabilities.contains("send-audio")
                && callViewModel.callSettings.audioOn {
                changeMuteState()
            }
            self.update(participants: callViewModel.callParticipants)
        }
    }
}
```

In this method, we are subscribing to another async stream from the `Call`, which publishes permission updates. We store the updated permissions for the listeners, in the `activeCallPermissions` dictionary. We do this so we can move them from the listeners to the speakers section, and also to be able to easily revoke them if needed.

With all these helpers in place, you can implement the `init` function of the `AudioRoomViewModel` that simply calls all the helpers you just created:

```swift
init(audioRoom: AudioRoom) {
    self.audioRoom = audioRoom
    checkAudioSettings()
    callViewModel.startCall(
        callId: audioRoom.id,
        type: callType,
        participants: audioRoom.hosts
    )
    subscribeForParticipantChanges()
    subscribeForAudioChanges()
    subscribeForCallStateChanges()
}
```

### Backstage

When you create a call with the call type `audio_room`, by default, it goes to a backstage. Backstage means that only hosts or users with elevated permissions can join the call. In order to make it available for everyone, you will need to go live. 

To do that, you should use the corresponding method from the `Call`:

```swift
func goLive() {
    Task {
        try await call.goLive()
    }
}
```

With this, the call is live and anyone can join it. You can also go back to backstage (and remove all participants that are not hosts), by calling the method `stopLive` in the `Call` object:

```swift
func stopLive() {
    Task {
        try await call.stopLive()
    }
}
```

### Raising a hand

Next, let's see how users can "raise their hand" to speak, which is basically asking for a permission to send audio:

```swift
func raiseHand() {
    Task {
        try await call.request(
            permissions: [.sendAudio]
        )
    }
}
```

When this method is called, a new permission request will be send to the users who can grant these permissions. We have already seen above how to listen to these requests, by calling the method `subscribeForPermissionsRequests`. Next, let's see how to handle these events. 

After a request is stored in the view model, it automatically updates a variable that controls the presentation of an alert:

```swift
var permissionRequest: PermissionRequest? {
    didSet {
        permissionPopupShown = permissionRequest != nil
    }
}
```

Then, in our UI code, we can use this value to present an alert:

```swift
.alert(isPresented: $viewModel.permissionPopupShown) {
    Alert(
        title: Text("Permission request"),
        message: Text("\(viewModel.permissionRequest?.user.name ?? "Someone") raised their hand to speak."),
        primaryButton: .default(Text("Allow")) {
            viewModel.grantUserPermissions()
        },
        secondaryButton: .cancel()
    )
}
```

The interesting part here is the `grantUserPermissions` call, which accepts the user's permission to send audio:

```swift
func grantUserPermissions() {
    guard let permissionRequest else { return }
    Task {
        try await call.grant(
            permissions: permissionRequest.permissions.compactMap { Permission(rawValue: $0) },
            for: permissionRequest.user.id
        )
    }
}
```

When this method is called, a new permission update will be sent (which we are listening to by calling the `subscribeForPermissionUpdates`) and the capabilities of the user are updated.

Lastly, you'll add two more functions that listen to user interactions and call functions of the `callViewModel` accordingly, namely one to leave a call and one to toggle the mute state of the current user. Add these two and you're done with the `AudioRoomViewModel`:

```swift
func leaveCall() {
   callViewModel.hangUp()
}

func changeMuteState() {
   callViewModel.toggleMicrophoneEnabled()
}
```

The logic is in place, let's get started with the UI. As before you'll first create three helper views, which will help make the view code more neatly arranged.

The first helper will be to display images from a URL. You'll make use of Apple's `AsyncImage` to load the image and show a placeholder while waiting for the network response.

:::note
This requires the app to have a minimum target of iOS 15. If you want to support older iOS versions, there is the great [Nuke package](https://github.com/kean/Nuke) which adds a similar component called `LazyImage`. We didn't want to add it here to avoid having more dependencies but can highly recommend the package.
:::

Create a new SwiftUI view and call it `ImageFromUrl`. As parameters it will have an optional `url` to load the image from, the `size` of the image and an optional `offset` so that you can re-arrange the image if needed.

Here is the code for the view:

```swift
struct ImageFromUrl: View {

    var url: URL?
    var size: CGFloat
    var offset: CGFloat?

    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable()
                .frame(width: size, height: size)
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .offset(x: offset ?? 0, y: offset ?? 0)
        } placeholder: {
            ProgressView()
                .frame(width: size, height: size)
                .offset(x: offset ?? 0, y: offset ?? 0)
        }
    }
}

struct ImageFromUrl_Previews: PreviewProvider {
    static var previews: some View {
        ImageFromUrl(
            url: URL(string: "https://getstream.io/static/237f45f28690696ad8fff92726f45106/c59de/thierry.webp"),
            size: 40
        )
    }
}
```

The second helper view is the `ParticipantsView` which will hold a list of `CallParticipant` objects (taken from the `StreamVideo` SDK).

Please create a new SwiftUI view and call it `ParticipantsView`. The participants will be arranged horizontally (in an `HStack`), and you'll show each participant's photo (gladly, you already created a helper view for that) and text in a `VStack`.

Fill in the following code in the `ParticipantsView`:

```swift
import SwiftUI
import StreamVideo

struct ParticipantsView: View {

   var participants: [CallParticipant]

   var body: some View {
      HStack {
         ForEach(participants) { participant in
            VStack {
               ZStack(alignment: .bottomTrailing) {
                  ImageFromUrl(
                     url: participant.profileImageURL,
                     size: 64
                  )
                  .overlay(
                     Circle()
                        .stroke(
                           Color.blue,
                           lineWidth: participant.isSpeaking ? 1 : 0
                        )
                  )

                  if !participant.hasAudio {
                     IconView(imageName: "mic.slash")
                        .frame(width: 12, height: 12)
                  }
               }

               Text(participant.name)
            }
         }
      }
   }
}
```

Note, that the `ImageFromUrl` has an overlay (a `Circle` with a stroke border) to indicate whether or not the participant is speaking. You're also indicating when a user is either muted or is not allowed to speak (indicated by the `participant.hasAudio` property) by showing an image in that case.

Next, since you'll show a few images in the main `AudioRoomView` you'll create a helper view for that. Create a new SwiftUI view and call it `IconView`. It'll receive an `imageName` as the only parameter and use the `systemImage` for it. Here is the code:

```swift
struct IconView: View {

   let imageName: String

   var body: some View {
      Image(systemName: imageName)
         .foregroundColor(.primary)
         .padding(8)
         .background(Color.backgroundColor, in: Circle())
   }

}
```

Now, everything is in place and you can finally create a new SwiftUI view and name it `AudioRoomView`. You'll first add the `AudioRoomViewModel` to it which is being initialized with an `AudioRoom` object.

Add this code inside of your `AudioRoomView` struct:

```swift
@Environment(\.presentationMode) var presentationMode
@StateObject var viewModel: AudioRoomViewModel

private let audioRoom: AudioRoom

init(audioRoom: AudioRoom) {
   self.audioRoom = audioRoom
   _viewModel = StateObject(
      wrappedValue: AudioRoomViewModel(audioRoom: audioRoom)
   )
}
```

The `presentationMode` variable is needed since the `AudioRoomView` is shown inside a sheet. When the user wants to leave the room you can close the sheet using the `dismiss()` function of the `presentationMode`.

Add the following code to the `body` of your `AudioRoomView`:

```swift
VStack(alignment: .leading, spacing: 16) {
   // highlight-next-line
   // 1. Button to leave the room and close the sheet
   HStack {
      Spacer()
      Button {
         presentationMode.wrappedValue.dismiss()
      } label: {
         Text("Leave quitely")
      }
   }
   .padding(.bottom, 16)

   // highlight-next-line
   // 2. Description and hosts of the room
   Text(audioRoom.title)
      .font(.headline)

   Text(audioRoom.subtitle)
      .font(.subheadline)
      .foregroundColor(.gray)

   ParticipantsView(participants: viewModel.hosts)

   // highlight-next-line
   // 3. If there are listeners, show them
   if viewModel.otherUsers.count > 0 {
      Text("Listeners")
      ParticipantsView(participants: viewModel.otherUsers)
   }

   Spacer()

   // highlight-next-line
   // 4. Allow speakers to toggle their mute state
   HStack {
      Spacer()
      if viewModel.hasPermissionsToSpeak {
         Button {
            viewModel.changeMuteState()
         } label: {
            IconView(imageName: viewModel.isUserMuted ? "mic.slash" : "mic")
         }
      }
   }
}
.opacity(viewModel.loading ? 0 : 1)
.overlay(
   viewModel.loading ? ProgressView() : nil
)
.padding()
```

Looking at the comments in the code, the different sections do the following:

1. Allow users to leave the room and when doing that, call the `presentationMode`'s dismiss function on its wrapped value
2. Add a quick description of the room and show the hosts
3. If there are listeners, show these listeners
4. If the current user is a speaker, add a button to toggle their mute state

With that, all view code is finished. The last remaining thing is to show the `AudioRoomView` in the sheet. For that, you need to open `AudioRoomsView` again. Find the code section where it says:

```swift
// This will be replaced soon:
Text(audioRoom.title)
```

Replace this with:

```swift
AudioRoomView(audioRoom: audioRoom)
```

You are done. Run the app and you can enter rooms and speak with other people (or just listen to great minds talking). 🎉

## Summary

In this guide, you have built an application that is similar to Clubhouse or Twitter Spaces using the `StreamVideo` SDK from scratch. You've only used the low-level client and built out the UI completely on your own.

There are other options that you have with the `StreamVideo` SDK. You can add video functionality to your application as easily as adding one modifier. Don't believe us? Check out our [guide here](./video-call.md). Want to add live streaming to your application? There is [a guide](./livestream.md) for that as well.

The `StreamVideo` SDK is built to be flexible and adjustable to your use case. This might be using the built-in components that have been carefully designed and engineered by our fantastic team. Or this might be a completely custom UI and only use the low-level client for the logic (as you've done in this guide).

Whatever it might be, we're excited to hear about your ideas and use cases. Have something interesting to share? We're always happy to hear from you over on [Twitter](https://twitter.com/getstream_io).