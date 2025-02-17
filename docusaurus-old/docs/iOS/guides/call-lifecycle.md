---
title: Call Lifecycle
---

## Call

The `Call` object manages everything related to a particular call, such as creating, joining a call, performing actions for a user (mute/unmute, camera change, invite, etc) and listening to events.

When a call starts, the iOS SDK communicates with our backend infrastructure, to find the best Selective Forwarding Unit (SFU) to host the call, based on the locations of the participants. It then establishes the connection with that SFU and provides updates on all events related to a call.

You can create a new call via the `StreamVideo`'s method `func makeCall(callType: String, callId: String, members: [User])`.

It's a lower-level component than the stateful `CallViewModel`, and it's suitable if you want to create your own presentation logic and state handling. 

The `Call` object should exist while the call is active. Afterwards, you should clean up all the state related to the call (provided you don't use our `CallViewModel`), by calling the `leave` method and de-allocating the instance.

Every call has a call id and type. You can join a call with the same id as many times as you need. However, the call sends ringing events only the first time. If you want to receive ring events, you should always use a unique call id.

## Web Socket Connection

The web socket connection with our backend is established by calling the `connect` method in the `StreamVideo` object. If you go into the background, and come back, the SDK tries to re-establish this connection. The web socket connection is persisted in order to listen to events such as incoming calls, that can be presented in-app (if you're not using CallKit).