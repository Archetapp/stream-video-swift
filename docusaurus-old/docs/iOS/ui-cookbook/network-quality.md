---
title: Network Quality
---

Network quality can impact the video experience a lot. Therefore, it's always a good idea to display the network quality of the participants in the call.

### Before joining a call

Before the user joins the call, the network quality is determined on the client side, from the SDK, by sending latency checks to the SFU that will host the call for the user. 

This is already handled in our `LobbyView`. However, if you want to create your own version of a lobby view, you can use our `LobbyViewModel`, for getting information about the current user's network quality.

This information is available via the `connectionQuality` property in the `LobbyViewModel`. The connection quality property can have the following values:

```swift
public enum ConnectionQuality: Sendable {
    case unknown
    case poor
    case good
    case excellent
}
```

You can build your own UI to display this value, or use our default `ConnectionQualityIndicator` view. The `ConnectionQualityIndicator` view expects the `connectionQuality` parameter, and changes its UI depending on the value. Here's an example usage:

```swift
ConnectionQualityIndicator(connectionQuality: viewModel.connectionQuality)
```

Additionally, you can change the size and the width of the connection quality ticks, by passing the `size` and `width` parameters to the `ConnectionQualityIndicator` view.

### Network quality in a call

When you are in a call, the network quality for each participant is delivered from the server. It's available via the `connectionQuality` property for each `CallParticipant`.

By default, the SwiftUI SDK displays this information in the `VideoCallParticipantModifier`, via the same `ConnectionQualityIndicator` as above.

If you wish to change this behaviour, you should implement the `makeVideoCallParticipantModifier` method and provide your own implementation that can modify or hide this view.
