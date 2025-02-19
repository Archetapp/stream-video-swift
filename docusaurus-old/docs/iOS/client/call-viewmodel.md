---
title: Call View Model
---

## Introduction

The `CallViewModel` is a stateful component, that can be used as a presentation layer in your custom views that present video. It can live throughout the whole app lifecycle (if you want to react to incoming call events), or it can be created per call.

The `CallViewModel` is an observable object, and it can be used with both SwiftUI and UIKit views. It provides information about the call state, events, participants, as well as different actions that you can perform while on a call (muting/unmuting yourself, changing camera source, etc).

## Available functionalities

### Calling State

The `CallViewModel` exposes a `@Published` `callingState` variable, that can be used to track the current state of a call. It should be used to show different UI in your views. You can find more information about the `callingState` [here](./call-state.md).

### Starting a call

You can start a call using the method `startCall(callId: String, type: String, members: [UserInfo])`, where the parameters are:

- `callId` - the id of the call. If you use the ringing functionality, this should be always a unique value.
- `type` - the call type.
- `members` - the list of members in the call.

Here's an example usage:

```swift
Button {
    viewModel.startCall(callId: callId, type: "default", members: members)
} label: {
    Text("Start a call")
}
```

After you call this method (or the other ones below), the `callingState` will change accordingly.

### Joining a call

You can join an existing call using the method `joinCall(callId: String, type: String)`, where the parameters are:

- `callId` - the id of the call. If you use the ringing functionality, this should be always a unique value.
- `type` - the type of the call.

Here's an example usage:

```swift
Button {
    viewModel.joinCall(callId: callId, type: "default")
} label: {
    Text("Join a call")
}
```

### Entering the lobby

If you want to display a lobby screen before the user joins the call, you should use the `enterLobby(callId: String, type: String, members: [User])` method. This will change the calling state to `.lobby`. When that happens, you can either display your custom implementation of a lobby view, or use the one from the SDK.

When the user decides to join the call, you should call the `joinCallFromLobby(callId: String, type: String, members: [User])` method.

### Accepting a call

When you are receiving an incoming call, you can either accept it or reject it. If you don't perform any of these actions after a configurable timeout, the call is canceled.

In order to accept a call, you need to use the method `acceptCall(callId: String, type: String)`, where the parameters are:

- `callId` - the id of the call.
- `type` - the type of the call.

### Rejecting a call

In order to reject a call, you need to use the method `rejectCall(callId: String, type: String)`, where the parameters are:

- `callId` - the id of the call.
- `type` - the type of the call.

### Hanging up

If you want to hangup a call in progress, you should call the `hangUp()` method. This will notify other users that you've left the call.

### Participants

The call participants are available as a `@Published` property called `callParticipants`. You can use this to present your custom UI that displays their video feeds.

### Call Settings

The `CallViewModel` provides information about the current call settings, such as the camera position and whether there's an audio and video turned on. This is available as a `@Published` property called `callSettings`.

If you are building a custom UI, you should use the values from this struct to show the corresponding call controls and camera (front or back).

The `callSettings` are updated by performing the following actions from the view model.

#### toggleCameraPosition

You can toggle the camera position by calling the method `toggleCameraPosition`. The method takes into consideration the current camera state (front or back), and it updates it to the new one.

The video view will automatically update itself and send the new feed to the backend.

#### toggleCameraEnabled

You can also show/hide the camera during a call. This is done by calling the method `toggleCameraEnabled`. If you're not using our default view components, you will need to handle this state change from the `callSettings` and show a fallback view when the camera is turned off.

#### toggleMicrophoneEnabled

You can mute/unmute the audio during a call, using the `toggleMicrophoneEnabled` method. The change will be published to the views via the `callSettings`.

### Capturing local video

The view model also has support for explicitly asking to capture the current user's local video. To do this, you will need to call `startCapturingLocalVideo`.

### Other properties

Here are some other useful properties from the view model that you can use to build custom calling experiences:
- `error` - optional, has a value if there was an error. You can use it to display more detailed error messages to users.
- `errorAlertShown` - if the error has a value, it's true. You can use it to control the visibility of an alert presented to the user.
- `participantsShown` - whether the list of participants is shown during the call.
- `outgoingCallMembers` - list of the outgoing call members.
- `participantEvent` - published variable that contains info about a participant event. It's reset to nil after 2 seconds.
- `isMinimized` - whether the call is in minimized mode.
- `localVideoPrimary` - `false` by default. It becomes `true` when the current user's local video is shown as a primary view.
- `hideUIElements` - whether the UI elements, such as the call controls should be hidden (for example while screen sharing).
- `blockedUsers` - a list of the blocked users in the call.
- `recordingState` - the current recording state of the call.
- `localParticipant` - returns the local participant of the call.
