//
//  BaseCoordinator.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 21.03.2025.
//

import UIKit
import Combine

@MainActor
open class BaseCoordinator {
    public var transition: any Transition {
        guard let last = transitions.last else { fatalError("There should always be one transition in a coordinator") }
        return last
    }
    
    public weak var parentCoordinator: BaseCoordinator?
    
    ///
    /// View controllers managed within the current coordinator's flow.
    ///
    /// These view controllers are part of the active navigation flow, which may
    /// involve navigation stacks or modal presentations. Regardless of their
    /// presentation style, they are all part of the current coordinator's flow
    /// and will be removed when the coordinator completes its lifecycle.
    ///
    private var childControllers: [UIViewController] = []
    
    ///
    /// Child coordinators that manage independent flows within this coordinator.
    ///
    /// Each child coordinator represents a separate navigation flow that is
    /// still under the control of this parent coordinator. When a child
    /// coordinator finishes, it should notify the parent to clean up references.
    ///
    private var childCoordinators: [BaseCoordinator] = []
    
    ///
    /// Active transitions within the coordinator's flow.
    ///
    /// A single navigation flow can involve multiple transitions (e.g., push,
    /// modal, or custom transitions). The coordinator keeps track of them to
    /// handle dismissals and navigation events correctly.
    ///
    private var transitions: [any Transition] = []
    
    public init(transition: (any Transition)? = nil) {
        if let transition = transition {
            self.transitions.append(transition)
        }
        print("init \(Self.self) with memory \(Unmanaged.passUnretained(self).toOpaque())")
    }
    
    ///
    /// Starts the coordinator's lifecycle and initializes its flow.
    ///
    /// This method must be implemented by subclasses (e.g., feature coordinators)
    /// to define how the navigation should begin. Typically, it involves presenting
    /// an initial view controller using `open(controller:with:)` or starting another
    /// coordinator.
    ///
    /// Calling this method marks the beginning of the coordinator's responsibility
    /// for managing a specific part of the app's navigation.
    ///
    open func start() {
        fatalError("Subclasses must implement start()")
    }
    
    ///
    /// Presents a view controller within the same coordinator’s flow.
    ///
    /// This method ensures that the coordinator properly tracks presented controllers
    /// and their associated transitions. It automatically adds the controller and
    /// transition to the coordinator’s internal lists, so the caller (feature coordinator)
    /// doesn’t need to manage them manually.
    ///
    /// Additionally, it assigns the coordinator as both the delegate and owner of the transition,
    /// allowing it to respond to dismissal or pop events.
    ///
    /// - Parameters:
    ///   - controller: The `UIViewController` to be presented.
    ///   - transition: The transition that handles how the controller is displayed.
    ///
    public func open(controller: UIViewController, with transition: some Transition) {
        childControllers.append(controller)
        
        if !transitions.contains(where: { $0 === transition }) {
            transitions.append(transition)
        }
        
        transition.delegate = self
        transition.coordinator = self
        transition.open(controller)
    }
    
    ///
    /// Opens a new coordinator, establishing a parent-child relationship.
    ///
    /// This method ensures that the new coordinator is retained by adding it to `childCoordinators`.
    /// Setting `self` as its `parentCoordinator` allows proper cleanup when the child finishes.
    /// Finally, `start()` is called to begin the coordinator's lifecycle.
    ///
    /// - Parameter coordinator: The child coordinator to be started.
    ///
    public func open(coordinator: BaseCoordinator) {
        childCoordinators.append(coordinator)
        
        if !transitions.contains(where: { $0 === coordinator.transition }) {
            transitions.append(coordinator.transition)
        }
        
        coordinator.parentCoordinator = self
        coordinator.start()
    }
    
    ///
    /// Ends the lifecycle of the current coordinator.
    ///
    /// The parent coordinator will handle cleanup by removing any associated
    /// view controllers from the navigation stack and removing this coordinator
    /// from its list of child coordinators.
    ///
    /// Call this method when the coordinator has completed its flow and
    /// should be deallocated.
    ///
    public func finish() {
        parentCoordinator?.removeControllers(from: self)
        coordinatorDidFinish()
    }
    
    ///
    /// Cleans up and notifies the parent coordinator that this coordinator has finished.
    ///
    /// Typically, this method is used when the user navigates back using a pop or dismissal that is not handled by the coordinator itself.
    /// This method will be called automatically when the coordinator doesn't have child controllers
    /// or coordinators to manage and is ready to be deallocated.
    ///
    /// Additionally, if the coordinator was managed by a parent coordinator, it
    /// notifies the parent so it can remove this instance from its tracking list.
    ///
    /// You can override this method in order to send some value to the parent coordinator
    /// **but don't forget to call**
    ///
    /// ```
    /// super.coordinatorDidFinish()
    /// ```
    ///
    open func coordinatorDidFinish() {
        childControllers.removeAll()
        childCoordinators.removeAll()
        parentCoordinator?.childDidFinish(self)
    }
    
    ///
    /// Cleans up view controllers and transitions when a child coordinator finishes.
    ///
    /// - If the last transition in the parent coordinator is a `PushTransition`,
    ///   the navigation stack is popped to the last known controller, and ownership
    ///   of the transition is reassigned to the parent coordinator.
    ///
    /// - If the last transition is a `PresentTransition`:
    ///   - If the first controller of the parent coordinator is still in the child's
    ///     navigation stack, the transition pops to the last controller of the parent.
    ///   - Otherwise, the transition is dismissed, and the transition is removed
    ///     from the coordinator's stack.
    ///
    /// This ensures that navigation and memory management are handled properly when
    /// a child coordinator completes its flow.
    ///
    /// **⚠️ This method is called automatically when a child coordinator finishes.
    /// Never call it manually.**
    ///
    private func removeControllers(from childCoordinator: BaseCoordinator) {
        if transition is PushTransition {
            if let lastController = childControllers.last {
                transition.pop(to: lastController)
                transition.coordinator = childCoordinator.parentCoordinator
                transition.delegate = childCoordinator.parentCoordinator
            }
        } else if transition is PresentTransition {
            // Get the first controller managed by the parent coordinator
            if let firstController = childControllers.first {
                // If the first controller of the parent is in the navigation controller of the child, then we need to pop to the last controller of the parent
                if transition.navigationController.viewControllers.contains(where: { $0 === firstController }), let lastController = childControllers.last {
                    transition.pop(to: lastController)
                    transition.coordinator = childCoordinator.parentCoordinator
                    transition.delegate = childCoordinator.parentCoordinator
                } else {
                    // otherwise, dismiss and remove the transition
                    transition.dismiss()
                    transitions.removeLast()
                }
            }
        }
    }
    
    ///
    /// Removes a finished child coordinator from the list.
    ///
    /// This method ensures that once a child coordinator completes its flow,
    /// it is properly deallocated by removing its reference from `childCoordinators`.
    /// This prevents memory leaks and keeps the coordinator hierarchy clean.
    ///
    /// - Parameter coordinator: The child coordinator that has finished its lifecycle.
    ///
    private func childDidFinish(_ childCoordinator: BaseCoordinator) {
        childCoordinators.removeAll { $0 === childCoordinator }
    }
    
    deinit {
        print("deinit \(Self.self) with memory \(Unmanaged.passUnretained(self).toOpaque())")
    }
}

extension BaseCoordinator: TransitionDelegate {
    ///
    /// Handles the transition when a view controller is popped from the navigation stack.
    ///
    /// This method is triggered when the user taps the native back button or when
    /// the view controller is popped programmatically. The controller is removed
    /// from the `childControllers` array, and if no child controllers remain in
    /// the coordinator, the coordinator's lifecycle is considered complete.
    ///
    /// If the coordinator has no more child controllers is likely managed by a parent coordinator.
    /// The transition delegate is reassigned to this parent coordinator, and the
    /// current coordinator finishes its execution.
    ///
    public func transitionDidPop(_ transition: any Transition, controller: UIViewController, coordinator: BaseCoordinator) {
        coordinator.childControllers.removeAll(where: { $0 === controller })
        
        if coordinator.childControllers.isEmpty {
            transition.coordinator = coordinator.parentCoordinator
            transition.delegate = coordinator.parentCoordinator
            coordinator.coordinatorDidFinish()
        }
    }
    
    ///
    /// Handles the transition when a view controller is popped to the root view controller.
    /// The method performs the following:
    ///
    /// - Checks if the root controller of the navigation is part of the current coordinator’s managed child controllers.
    /// - If the root controller is part of the coordinator’s flow, it removes all controllers after it in the stack.
    /// - If the root controller is not part of the current coordinator's flow, the transition delegate is reassigned
    ///   to the parent coordinator, and the current coordinator finishes its lifecycle.
    /// - Finally, it calls this method on the parent coordinator to evaluate its flow and perform any necessary cleanup.
    ///
    public func transitionDidPopToRoot(_ transition: any Transition,
                                navigationController: UINavigationController,
                                coordinator: BaseCoordinator) {
        guard let rootController = navigationController.viewControllers.first else {
            fatalError("NavigationController should maintain the root")
        }
        
        if coordinator.childControllers.contains(where: { $0 === rootController }) {
            while coordinator.childControllers.last !== rootController {
                coordinator.childControllers.removeLast()
            }
        } else {
            transition.coordinator = coordinator.parentCoordinator
            transition.delegate = coordinator.parentCoordinator
            coordinator.coordinatorDidFinish()
            
            if let parent = coordinator.parentCoordinator {
                parent.transitionDidPopToRoot(
                    transition,
                    navigationController: navigationController,
                    coordinator: parent
                )
            }
        }
    }
    
    ///
    /// Handles the transition when a presented view controller or flow is dismissed.
    ///
    /// This method is called when the user swipes down a presented controller or when the flow
    /// is dismissed programmatically. The following steps are performed:
    ///
    /// - First, the corresponding transition is removed from the `transitions` array in the coordinator,
    ///   as it may be part of the current flow and retaining it could result in a reference cycle.
    /// - Then, all view controllers in the navigation stack of the presented flow are removed from the
    ///   `childControllers` array to ensure they are no longer part of the coordinator's active flow.
    /// - If there are no child controllers remaining, it indicates that the current coordinator was managed by
    ///   a parent flow, so the `coordinatorDidFinish()` method is called to clean up the coordinator.
    /// - Finally, if the coordinator has a parent, the method recursively calls `transitionDidDismiss`
    ///   on the parent coordinator to handle dismissal in the parent flow.
    ///
    ///   Here, we don't have to reassign the transition delegate to the parent since the transition
    ///   is being removed, and the parent coordinator likely has its own `PresentTransition` delegate.
    ///
    public func transitionDidDismiss(_ transition: any Transition, navigationController: UINavigationController, coordinator: BaseCoordinator) {
        coordinator.transitions.removeAll(where: { $0 === transition })
        
        for controller in navigationController.viewControllers {
            coordinator.childControllers.removeAll(where: { $0 === controller })
        }
        
        if coordinator.childControllers.isEmpty {
            coordinator.coordinatorDidFinish()
            
            if let parent = coordinator.parentCoordinator {
                parent.transitionDidDismiss(transition, navigationController: navigationController, coordinator: parent)
            }
        }
    }
}
