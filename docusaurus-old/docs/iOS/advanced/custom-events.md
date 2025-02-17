---
title: Custom Events
---

### Introduction

In some cases, you might want to send custom events during a call. For example, if you want to build a collaborative drawing board while the call is in progress, you will need a mechanism for syncing the data between the devices. Or if you want to send some custom reactions, or even play a game, you would need an easy mechanism for passing this data to all participants in the call.

The StreamVideo SDK has support for sending both custom events and reactions and listening to them.

### Call's event features

In order to send custom events, you should use the event based features from the `Call` object, which are available as soon as you join a call.

#### Sending call reactions

In order to send call reactions, you need to create a `CallReactionRequest`, where you need to provide the call information, as well as the reaction data. Then, you can send the request to our backend using the `Call`'s `send(reaction:)` method:

```swift
let reactionRequest = CallReactionRequest(
    callId: callId,
    callType: callType,
    reactionType: "your_custom_type", // e.g. "raiseHand"
    emojiCode: "emoji_code", //
    customData: [
        "id": .string("some_id"),
        "duration": .number(duration),
        "sound": .string(sound),
        "isReverted": .bool(false)
    ]
)
try await call.send(reaction: reactionRequest)
```

Note that in the `customData` dictionary, you can provide additional information to help you handle the reaction better. For example, you can pass a duration, to control how long the reaction is displayed on the screen, or sound filenames that can be played while the reaction is shown. Additionally, you can use boolean flags like for example `isReverted`, to check whether the user is sending the reaction, or wants it reverted.

#### Listening to reaction events

The reaction events are available via the `reactions` async stream in the `Call` object. Here's an example how to listen to the events:

```swift
private func subscribeToReactionEvents() {
    Task {
        for await event in call.reactions() {
            log.debug("received an event \(event)")
            handleReaction(with: event.customData, from: event.user)
        }
    }
}
```

The `handleReaction` method would be your own handling of the reaction. 

#### Sending custom events

You can also send custom events for cases where you need something different than reactions. The steps are very similar to sending reactions above.

For example, let's see how we can send some broadcasting event to all participants in the call, like starting a game.

First, let's create a new event type:

```swift
extension EventType {
    static let gameStarted: Self = "gameStarted"
}
```

Then, let's create a new model that will represent this event:

```swift
struct GameEvent: Identifiable, Codable {
    var id: String
    var name: String
}
```

Next, let's see how we can send the event, using the `Call`'s method `send(event:)`:

```swift
func send(event: GameEvent) {
    guard let callId, let callType else { return }
    Task {
        let customEvent = CustomEventRequest(
            callId: callId,
            callType: callType,
            type: .gameStarted,
            customData: [
                "id": .string(event.id),
                "name": .string(event.name)
            ]
        )
        try await call.send(event: customEvent)
    }
}
```

In the code above, we are creating a `CustomEventRequest`, with the call id and call type where the user is a participant. We also provide the newly defined `gameStarted` event type. Finally, we are providing our custom event info in the `customData` parameter.

#### Listening to custom events

You can listen to custom events using the `customEvents()` async stream in the `Call`:

```swift
private func subscribeToCustomEvents() {
    Task {
        for await event in call.customEvents() {
            log.debug("received an event \(event)")
            if event.type == EventType.gameStarted.rawValue {
                handleEvent(with: event.customData, from: event.user)
            }            
        }
    }        
}
```