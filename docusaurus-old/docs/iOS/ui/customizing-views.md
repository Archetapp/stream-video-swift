---
title: View Customizations
---

## Injecting Your Views

The SwiftUI SDK allows complete view swapping of some of its components. This means you can, for example, create your own (different) outgoing call view and inject it in the slot of the default one. For most of the views, the SDK doesn't require anything else than the view to conform to the standard SwiftUI `View` protocol and return a view from the `body` variable. You don't need to implement any other lifecycle related methods or additional protocol conformance.

### How the View Swapping Works

All the views that allow slots that your implementations can replace are generic over those views. This means that view type erasure (AnyView) is not used. The views contain default implementations, and in general, you don't have to deal with the generics part of the code. Using generics over type erasure allows SwiftUI to compute the diffing of the views faster and more accurately while boosting performance and correctness.

### View Factory

To abstract away the creation of the views, a protocol called `ViewFactory` is used in the SDK. This protocol defines the swappable views of the video experience. There are default implementations for all the views used in the SDK. If you want to customize a view, you will need to provide your own implementation of the `ViewFactory`, but you will need to implement only the view you want to swap.

For example, if we want to change the outgoing call view, we will need to implement the `makeOutgoingCallView(viewModel: CallViewModel) -> OutgoingCallViewType` in the `ViewFactory`:

```swift
class CustomViewFactory: ViewFactory {
    
	func makeOutgoingCallView(viewModel: CallViewModel) -> some View {
        CustomOutgoingCallView(viewModel: viewModel)
    }

}
```
Next, when you attach the `CallModifier` to your hosting view, you need to inject the newly created `CustomViewFactory`. The SDK will use the views you have provided in your custom implementation, while it will default back to the ones from the SDK in the slots where you haven't provided any implementation.

```swift
var body: some View {
    YourHostingView()
        .modifier(CallModifier(viewFactory: CustomViewFactory(), viewModel: viewModel))
}
```

For the full list of supported view slots that can be swapped, please refer to this [page](./view-slots.md).