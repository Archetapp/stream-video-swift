---
title: Architecture Overview
---

## Introduction

The StreamVideo product consists of three separate SDKs:

- low-level client - responsible for establishing calls, built on top of WebRTC.
- SwiftUI SDK - SwiftUI components for different types of call flows.
- UIKit SDK - UIKit wrapper over the SwiftUI components, for easier usage in UIKit based apps.

The low-level client is used as a dependency in the UI frameworks, and can also be used standalone if you plan to build your own UI. The UI SDKs depend on the low-level client.

### Main Principles

- Progressive disclosure: The SDK can be used easily with very minimal knowledge of it. As you become more familiar with it, you can dig deeper and start customizing it on all levels.
- Swift native API: Uses Swift's powerful language features to make the SDK usage easy and type-safe.
- Familiar behavior: The UI elements are good platform citizens and behave like native elements; they respect `tintColor`, padding, light/dark mode, dynamic font sizes, etc.
- Fully open-source implementation: You have access to the complete source code of the SDK on GitHub.

## Low-Level Client

The low-level client is used for establishing audio and video calls. It integrates with Stream's backend infrastructure, and implements the WebRTC protocol.

Here are the most important components that the low-level client provides:

- `StreamVideo` - the main SDK object.
- `Call` - observable object that provides info about the call state, as well as methods for updating it.
- `CallViewModel` - stateful ViewModel that contains presentation logic.

### StreamVideo

This is the main object for interfacing with the low-level client. It needs to be initialized with an API key and a user/token, before the SDK can be used.

```swift
let streamVideo = StreamVideo(
    apiKey: "key1",
    user: user.userInfo,
    token: user.token,
    videoConfig: VideoConfig(),
    tokenProvider: { result in
    	yourNetworkService.loadToken(completion: result)
    }
)
```

Here are parameters that the `StreamVideo` class expects:

- `apiKey` - your Stream Video API key
- `user` - the logged in user, represented by the `User` struct.
- `token` - the user's token.
- `videoConfig` - configuration for the type of calls.
- `tokenProvider` - called when the token expires. Use it to load a new token from your networking service.

The `StreamVideo` object should be kept alive throughout the app lifecycle. You can store it in your `App` or `AppDelegate`, or any other class whose lifecycle is tied to the one of the logged in user.

When the object is created, you should connect the user to our backend. This can be done whenever you plan on using the video features.

```swift
private func connectUser() {
    Task {
        try await streamVideo?.connect()
    }
}
```

### Call

The `Call` observable class provides all the information about the call, such as its participants, whether the call is being recorded, etc. It also provides methods to perform standard actions available during a call, such as muting/unmuting users, sending reactions, changing the camera input, granting permissions, recording, etc.

If you want to build your own presentation layer around video calls (ViewModel / Presenter), you should listen to the updates of this class.

When a call starts, the iOS SDK communicates with our backend infrastructure, to find the best Selective Forwarding Unit (SFU) to host the call, based on the locations of the participants. It then establishes the connection with that SFU and provides updates on all events related to a call.

You can create a new `Call` via the `StreamVideo`'s method `func makeCall(callType: String, callId: String, members: [User])`.

### CallViewModel

The `CallViewModel` is a presentation object that can be used directly if you need to implement your custom UI. It contains a `callState`, which provides information about whether the call is in a ringing mode, inside a call, or it's about to be closed. It also publishes events about the call participants, which you can use to update your UI.

The view model provides methods for starting and joining a call. It also wraps the call-related actions such as muting audio/video, changing the camera input, hanging up, for easier access from the views.

You should use this class directly, if you want to build your custom UI components.

On the next page, we'll describe how we approach the everlasting [SwiftUI vs. UIKit](./swiftui-vs-uikit.md) debate.

(Spoiler alert: we support both.)
