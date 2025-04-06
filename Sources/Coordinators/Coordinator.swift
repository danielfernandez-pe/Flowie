//
//  Coordinator.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 04.04.2025.
//

import UIKit

@MainActor
public protocol Coordinator: AnyObject {
    var id: UUID { get }
    
    ///
    /// We will send this property in the finished closure
    ///
    var finishedValue: Any? { get set }
    
    ///
    /// Setup this closure to know when the child coordinator finished.
    /// The child can send any type of value, however you need to cast it in order to use it.
    ///
    /// Working with generics imply making multiple changes to transition, transitionDelegate, etc.
    ///
    var finished: ((Any?) -> Void)? { get set }
    
    var parentCoordinator: (any Coordinator)? { get set }
    
    ///
    /// Child coordinators that manage independent flows within this coordinator.
    ///
    /// Each child coordinator represents a separate navigation flow that is
    /// still under the control of this parent coordinator. When a child
    /// coordinator finishes, it should notify the parent to clean up references.
    ///
    var childCoordinators: [any Coordinator] { get set }
    
    ///
    /// Starts the coordinator's lifecycle and initializes its flow.
    ///
    /// This method must be implemented by all coordinators
    /// to define how the navigation should begin. Typically, it involves presenting
    /// an initial view controller using `open(controller:with:)` in case of UICoordinator
    /// or starting another another coordinator.
    ///
    /// Calling this method marks the beginning of the coordinator's responsibility
    /// for managing a specific part of the app's navigation.
    ///
    func start()
    
    ///
    /// Opens a new coordinator, establishing a parent-child relationship.
    ///
    /// This method ensures that the new coordinator is retained by adding it to `childCoordinators`.
    /// Setting `self` as its `parentCoordinator` allows proper cleanup when the child finishes.
    /// Finally, `start()` is called to begin the coordinator's lifecycle.
    ///
    /// - Parameter coordinator: The child coordinator to be started.
    ///
    func open(coordinator: some Coordinator)
    
    ///
    /// Cleans up the coordinator and notifies the parent.
    /// Call this method when the coordinator should be fully cleaned up and deallocated.
    ///
    func finish(with value: Any?)
    
    ///
    /// The parent coordinator is cleaning up the view controllers and transitions of a child coordinator when finishes.
    ///
    /// **⚠️ This method is called automatically when a child coordinator finishes.
    /// Never call it manually.**
    ///
    func removeControllers(from childCoordinator: some Coordinator,
                           didChildPresentedController: Bool,
                           completion: @escaping () -> Void)
    
    ///
    /// Removes a finished child coordinator from the list.
    ///
    /// This method ensures that once a child coordinator completes its flow,
    /// it is properly deallocated by removing its reference from `childCoordinators`.
    /// This prevents memory leaks and keeps the coordinator hierarchy clean.
    ///
    /// - Parameter childCoordinator: The child coordinator that has finished its lifecycle.
    ///
    func childDidFinish(_ childCoordinator: some Coordinator)
}

public extension Coordinator {
    func finish() {
        finish(with: nil)
    }
    
    func isAnyTransitionDismissing() -> Bool {
        // Check if this coordinator has a dismissing transition
        if let uiCoordinator = self as? UICoordinator {
            if uiCoordinator.transition.isDismissing {
                return true
            }
        }
        
        // Check if this coordinator (if it's a root coordinator) has any dismissing transitions
        if let rootCoordinator = self as? RootCoordinator {
            if rootCoordinator.lastChildTransitions.values.contains(where: { $0.isDismissing }) {
                return true
            }
        }
        
        // Check if this coordinator's parent has any dismissing transitions
        if let rootParent = parentCoordinator as? RootCoordinator {
            if rootParent.lastChildTransitions.values.contains(where: { $0.isDismissing }) {
                return true
            }
        }
        
        // Recursively check parent
        return parentCoordinator?.isAnyTransitionDismissing() ?? false
    }
}

///
/// This coordinator should be use for coordinators that will manage only child coordinators.
/// E.g. AppCoordinator, TabBarCoordinator.
///
public protocol RootCoordinator: Coordinator {
    ///
    /// Every time the root coordinator opens any coordinator, we will save it's last transition.
    /// Having the last transition is useful to delete properly controllers of possible UICoordinators or just checking if
    /// the last transition is dismissing before trying to present something again.
    ///
    var lastChildTransitions: [UUID: (any Transition)] { get set }
}

///
/// This coordinator should be use for coordinators that will manage coordinators and controllers using transitions.
/// E.g. feature coordinators like AuthCoordinator, SettingsCoordinator, BuyProductCoordinator, etc.
///
public protocol UICoordinator: Coordinator {
    ///
    /// This property indicates the coordinator that started the creation of the the new coordinator. Is not necessarilly the parent.
    ///
    /// E.g.
    /// HomeCoordinator wants to open a coordinator from a module that it doesn't know.
    /// It will tell to his parent (in this case a TabBarCoordinator) to open the new coordinator for him.
    /// We set the source Coordinator as Home since at some point if we want to go back, tabBar needs to know who opened the new coordinator.
    /// We will use this property in `removeControllers` method when the coordinator is finishing.
    ///
    /// In case of a PushTransition it need to pop back to the last controller
    /// which will be the last controller of the sourceCoordinator.
    ///
    var sourceCoordinator: (any UICoordinator)? { get }
    
    ///
    /// Last transition the coordinator used.
    ///
    var transition: any Transition { get }
    
    ///
    /// Active transitions within the coordinator's flow.
    ///
    /// A single navigation flow can involve multiple transitions (e.g., push,
    /// modal, or custom transitions). The coordinator keeps track of them to
    /// handle dismissals and navigation events correctly.
    ///
    var transitions: [any Transition] { get set }
    
    ///
    /// View controllers managed within the current coordinator's flow.
    ///
    /// These view controllers are part of the active navigation flow, which may
    /// involve navigation stacks or modal presentations. Regardless of their
    /// presentation style, they are all part of the current coordinator's flow
    /// and will be removed when the coordinator completes its lifecycle.
    ///
    var childControllers: [UIViewController] { get set }
    
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
    func open(controller: UIViewController, with transition: some Transition)
}
