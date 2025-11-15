# Intro

If you use flow coordinators in your app, this package helps you manage navigation in a clean and simple way. We handle the heavy lifting—your job is just to tell us what to open and how.

# Getting started

## Coordinator types

Any class that represents a coordinator and manages a navigation flow must subclass `BaseCoordinator`.

Any class that manages other coordinators but does not display any UI itself (e.g. an AppCoordinator) must subclass `BaseRootCoordinator`.

To instantiate a coordinator, you must pass a transition that describes how to open its initial screen.

## Transitions

A transition defines how a view is opened.

In iOS we can push a screen or present it (as a sheet or full screen).
This package follows the same idea and provides two transition types:
- PushTransition
- PresentTransition

## Opening a screen

There are two main methods to control navigation:

1. Open a view controller within the same flow
```swift
func open(controller: UIViewController, with transition: some Transition)
```

2. Start a new flow using a new coordinator
```swift
func open(coordinator: some Coordinator)
```

Every time you open something, you must create and pass a new transition.
After that, you can forget about navigationController.pop, gesture-based dismissals, and other cleanup logic—we manage the entire lifecycle and clean up coordinators automatically.

# Reacting to the Finish State

When a coordinator has completed its job, call:
```swift
func finish(with value: Any?)
```
You can pass any value back to the parent coordinator.

On the parent side:
```swift
coordinator.finished = { [weak self] value in
    guard let self else { return }
    // Handle the result
}
```

# Closing views

Users can close screens natively (swipe to dismiss, back button, etc.), and we’ll automatically detect it and deallocate the coordinator.

If you want explicit control:
```swift
transition.close()
```

It works regardless of whether the screen was opened using a push or a present transition.
The transition object is always kept up to date as new screens are opened.

## Important: Be Careful with Toolbar Buttons

When you pass a reference type (like a view model) into a SwiftUI view, regular SwiftUI Button actions are safe, for example:
```swift
Button("Close") {
    viewModel.close()
}
```

This is safe because the button is part of the SwiftUI view hierarchy.
When SwiftUI destroys the view, the button disappears too—along with the closure that captured the view model.

**But this is not true for Toolbar buttons:**
```swift
.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        Button {
            viewModel.close()
        } label: {
            Text("Dismiss")
        }
    }
}
```

Toolbar items are not part of the SwiftUI view hierarchy.
They are passed down to a UIKit UINavigationItem, which can outlive the SwiftUI view.
This causes the closure—and therefore the captured view model—to stay alive, creating a memory leak.

**Solution: capture the viewModel weakly**
```swift
.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        Button { [weak viewModel] in
            viewModel?.close()
        } label: {
            Text("Dismiss")
        }
    }
}
```

This prevents the toolbar button from strongly retaining the view model.