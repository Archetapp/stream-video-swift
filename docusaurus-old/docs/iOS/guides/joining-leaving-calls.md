---
title: Joining and leaving calls
---

### Joining calls

There are several ways to join a call:
- if you know the call id and type
- if you receive an incoming call event and decide to join it
- if you have a link to the call (deep linking support required, more info [here](./deep-linking.md))

#### Join with call id and type

You can join a call via the `Call` object's method `join()`. First, you need to create an instance of the `Call` object, from your main `StreamVideo` object:

```swift
let call = streamVideo.makeCall(callType: type, callId: callId, members: members)
```

Note that this creates a local instance of the call and it is not synced with the server (unless it was already created before).

In order to join the call, you need to call the `join()` method, which also creates the call if it was not already created.

```swift
try await call.join(ring: ring, callSettings: callSettings)
```

The `join` method has two optional parameters:
- `ring` - whether the call should ring
- `callSettings` - the current user's call settings (whether audio/video is on and camera position).

If you want to just create the call on the server (and not join it), you should use the `getOrCreate` method:

```swift
let callData = try await call.getOrCreate(members: members, startsAt: Date(), customData: [:], membersLimit: 100, ring: false)                
```

This method will either get an already existing call with the call id and call type, or create a new one.

All parameters are optional in this method:
- `members` - the list of members in the call
- `startsAt` - the starting date of the call
- `customData` - any custom data you want to pass to the call
- `membersLimit` - limit of the members in the call
- `ring` - whether the call should ring.

#### Joining a call via the CallViewModel

If you are using the `CallViewModel`, the call creation and joining methods above are abstracted away via the `startCall` and `joinCall` methods, which take care of creating the call and joining it, while also considering the current state of the call.

If you receive an incoming call event, you can join it via the `acceptCall` method:

```swift
viewModel.acceptCall(callId: "call_id", type: "default")
```

Similarly, you can reject the call via the `rejectCall` method:

```swift
viewModel.rejectCall(callId: "call_id", type: "default")
```

### Leaving calls

If you want to leave a call, you should call the `leave` call on the `Call` object:

```swift
call.leave()
```

If you are using the `CallViewModel`, you should call the `hangUp` method, which also clears the call state.

```swift
viewModel.hangUp()
```