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
    ///
    /// This property is used to determine if the coordinator is the root coordinator.
    /// It means it only manages coordinators and not view controllers.
    ///
    /// E.g.
    /// - `AppCoordinator` is a root coordinator because it manages the navigation flow of the app.
    /// - `TabBarCoordinator` is a root coordinator because it mainly manages only tab item coordinators.
    ///
    open var isRootCoordinator: Bool { return false }
    
    public var transition: any Transition {
        guard let last = transitions.last else {
            fatalError("Error in \(Self.self) where there should always be one transition in a coordinator")
        }
        return last
    }
    
    ///
    /// Setup this closure to know when the child coordinator finished.
    /// The child can send any type of value, however you need to cast it in order to use it.
    ///
    /// Working with generics imply making multiple changes to transition, transitionDelegate, etc.
    ///
    public var finished: ((Any?) -> Void)?
    
    public weak var parentCoordinator: BaseCoordinator?
    
    /// This property indicates the coordinator that started the creation of the the new coordinator. Is not necessarilly the parent.
    ///
    /// E.g.
    /// HomeCoordinator wants to open a coordinator from a module that it doesn't know.
    /// It will tell to his parent (in this case a TabBarCoordinator) to open the new coordinator for him.
    /// We set the source Coordinator as Home since at some point if we want to go back, tabBar needs to know who opened the new coordinator.
    /// We will use this property in removeControllers when the coordinator is finishing. In case of a PushTransition I need to pop back to the last controller
    /// which will be the last controller of the sourceCoordinator.
    public weak var sourceCoordinator: BaseCoordinator?
    
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
    
    ///
    /// We will send this property in the finished closure
    ///
    private var finishedValue: Any?
    
    public init(transition: (any Transition)? = nil) {
        if let transition = transition {
            self.transitions.append(transition)
        }
        logging?.log("Init \(Self.self) with memory \(Unmanaged.passUnretained(self).toOpaque())")
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
        if !isRootCoordinator {
            /// There can be edge cases where the user taps a button to fast and it tries to present a coordinator, but the current transition is in the process of been dismiss.
            /// If that's the case, we just return so we don't have zombie coordinators.
            
            var parentCoordinatorTransitionIsDismissing = false
            
            if parentCoordinator?.transitions.isEmpty == false {
                parentCoordinatorTransitionIsDismissing = parentCoordinator?.transition.isDismissing ?? false
            }
            
            if transition.isDismissing || parentCoordinatorTransitionIsDismissing {
                logging?.log("Opening coordinator \(type(of: coordinator)) from \(type(of: self)) but the last transition \(type(of: transition)) has a dismissing state of \(transition.isDismissing)")
                logging?.log("Failed to open the coordinator")
                return
            }
        }
        
        logging?.log("Opening coordinator \(type(of: coordinator)) from \(type(of: self))")
        
        childCoordinators.append(coordinator)
        
        if !transitions.contains(where: { $0 === coordinator.transition }), !coordinator.isRootCoordinator {
            transitions.append(coordinator.transition)
        }
        
        coordinator.parentCoordinator = self
        coordinator.start()
    }
    
    ///
    /// Cleans up the coordinator and notifies the parent.
    ///
    /// This method removes the coordinator from its associated transition, clears child controllers and coordinators,
    /// and informs the parent coordinator to clean up the navigation stack accordingly.
    ///
    /// Finally, it notifies the parent to remove this coordinator from its list of child coordinators and sends a notification
    /// for any interested observers.
    ///
    /// Call this method when the coordinator should be fully cleaned up and deallocated.
    ///
    public func finish(with value: Any? = nil) {
        finishedValue = value
        transition.delegate = nil
        transition.coordinator = nil
        transitions.removeAll()
        childControllers.removeAll()
        childCoordinators.removeAll()
        
        let didChildPresentedController = transitions.contains(where: { $0 is PresentTransition })
        parentCoordinator?.removeControllers(
            from: self,
            didChildPresentedController: didChildPresentedController
        ) {
            self.parentCoordinator?.childDidFinish(self)
            self.notifyThatCoordinatorFinished()
        }
    }

    ///
    /// This method will be called automatically whenever the coordinator finishes.
    ///
    private func coordinatorDidFinish() {
        finished?(finishedValue)
    }
    
    ///
    /// The parent coordinator is cleaning up the view controllers and transitions of a child coordinator when finishes.
    ///
    /// - If the last transition in the parent coordinator is a `PushTransition`.
    ///
    ///   We check if the child presented a controller modally at some point during it's lifetime. If yes,
    ///   the transition is dismissed (which wil make the NavigationController dismiss the presented controller)
    ///   and the navigation  stack is popped to the last known controller.
    ///
    ///   Otherwise, the navigation stack is popped to the last known controller.
    ///
    ///   In both cases we call `reassignNavigationDelegate()` because the navigation delegate
    ///   was assign to the last transition and we need to current one to become the delegate again to react
    ///   to possible pop events.
    ///
    /// - If the last transition is a `PresentTransition`:
    ///   The transition is dismissed.
    ///
    /// In both cases, we set the delegate to nil first to avoid triggering logic twice since the delegate methods
    /// in this coordinator might get called.
    ///
    /// **⚠️ This method is called automatically when a child coordinator finishes.
    /// Never call it manually.**
    ///
    private func removeControllers(from childCoordinator: BaseCoordinator,
                                   didChildPresentedController: Bool,
                                   completion: @escaping () -> Void) {
        if isRootCoordinator, sourceCoordinator == nil {
            logging?.log("Deleting child coordinator of a RootCoordinator. If you expected some transition to happen check if you set sourceCoordinator for the child coordinator that is been dismiss.")
            /// this is a root coordinator that is working with window and just changing between two coordinators when they finish
            /// E.g. AuthCoordinator and HomeCoordinator
            /// It will only have one childCoordinator all the time
            completion()
            return
        }
        
        if let pushTransition = transition as? PushTransition {
            var lastController: UIViewController?
            if isRootCoordinator {
                /// since is a root coordinator it means that itself doesn't have child controllers so we need the last controller of the sourceCoordinator that
                /// should have been setup as some child coordinator of the tabBar (where this is coming from).
                ///
                /// E.g. TabBar has 2 coordinators. Home and Profile. Profile want's to open a new module, so it tells TabBar to do it, but it put the
                /// source coordinator of this new module as Profile. So then, when tab Bar finishes the new module, it know it came from Profile
                ///
                if let sourceCoordinator = childCoordinator.sourceCoordinator {
                    lastController = sourceCoordinator.childControllers.last
                }
            } else {
                /// if is not a root coordinator, we can just grab the last controller the coordinator has.
                lastController = childControllers.last
            }

            if lastController == nil {
                fatalError("We don't have a last controller to go back to. This should never happened.")
            }
            
            if let lastController {
                pushTransition.delegate = nil
                
                if didChildPresentedController {
                    pushTransition.dismiss {
                        pushTransition.pop(to: lastController, completion: nil)
                        self.transitions.removeLast()
                        self.transition.reassignNavigationDelegate()
                        completion()
                    }
                } else {
                    pushTransition.pop(to: lastController) {
                        self.transitions.removeLast()
                        self.transition.reassignNavigationDelegate()
                        completion()
                    }
                }
            }
        } else if let presentTransition = transition as? PresentTransition {
            transition.delegate = nil
            presentTransition.close {
                self.transitions.removeLast()
                /// we don't need to reassign the delegate, because the last transition was a presentation and that had it's own navigation controller
                completion()
            }
        } else {
            fatalError("this should never happen")
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
        logging?.log("Deinit \(Self.self) with memory \(Unmanaged.passUnretained(self).toOpaque())")
    }
}

extension BaseCoordinator: TransitionDelegate {
    ///
    /// Handles the transition when a view controller is popped from the navigation stack.
    ///
    /// This method is triggered when the user taps the native back button or when
    /// the view controller is popped programmatically.
    ///
    public func transitionDidPop(_ transition: some Transition,
                                 controller: UIViewController,
                                 navigationController: UINavigationController,
                                 coordinator: BaseCoordinator) {
        /// we clean the coordinator a bit. First, we remove the last transition
        /// then we remove controller from the list of child controllers
        coordinator.transitions.removeLast()
        coordinator.childControllers.removeAll(where: { $0 === controller })
        
        /// if there is no more controllers, we can remove this coordinator
        if coordinator.childControllers.isEmpty {
            coordinator.childCoordinators.removeAll()
            coordinator.parentCoordinator?.transitions.removeLast()
            coordinator.parentCoordinator?.childDidFinish(self)
            parentCoordinator?.transition.reassignNavigationDelegate()
            
            notifyThatCoordinatorFinished()
        } else {
            /// it the coordinator still have child controllers to manage, then we reassign the navigation delegate to the current transition.
            coordinator.transition.reassignNavigationDelegate()
        }
    }
    
    ///
    /// Handles the transition when a view controller is popped to the root view controller.
    ///
    public func transitionDidPopToRoot(_ transition: some Transition,
                                       navigationController: UINavigationController,
                                       coordinator: BaseCoordinator) {
        guard let firstController = navigationController.viewControllers.first else { return }
        
        /// when is the root coordinator, we only need to remove the last transition since it doesn't have child controllers
        if isRootCoordinator {
            transitions.removeLast()
            return
        }
        
        let isCoordinatorMainRootOfNavigation = coordinator.childControllers.contains(where: { $0 === firstController })
        
        /// if the current coordinator has the first controller of the navigation we can assure that this is the one that will be remaining after the popToRoot.
        if isCoordinatorMainRootOfNavigation {
            /// delete all transitions and controllers but the first one, which is the one that started (pushed) the navigation controller
            coordinator.transitions.removeSubrange(1...)
            coordinator.childControllers.removeSubrange(1...)
            
            /// we need the current transition to be the delegate again
            coordinator.transition.reassignNavigationDelegate()
        } else {
            /// this coordinator will must likely be remove from the parent so we clean and finish it.
            coordinator.transitions.removeAll()
            coordinator.childControllers.removeAll()
            coordinator.childCoordinators.removeAll()
            coordinator.parentCoordinator?.childDidFinish(self)
            
            /// we call the parent to make sure we get to the root
            if let parent = coordinator.parentCoordinator {
                parent.transitionDidPopToRoot(
                    transition,
                    navigationController: navigationController,
                    coordinator: parent
                )
            }
            
            notifyThatCoordinatorFinished()
        }
    }
    
    ///
    /// Handles the transition when a presented view controller or flow is dismissed.
    ///
    /// This method is called when the user swipes down a presented controller or when the flow
    /// is dismissed programmatically.
    ///
    public func transitionDidDismiss(_ transition: some Transition, navigationController: UINavigationController, coordinator: BaseCoordinator) {
        /// we delete all possible PushTransitions after the PresentTransition
        if let index = coordinator.transitions.firstIndex(where: { $0 === transition }) {
            coordinator.transitions.removeSubrange(index...)
        }
        
        /// we remove all the controllers from the navigation that are part of the child controllers of this coordinator
        for controller in navigationController.viewControllers {
            coordinator.childControllers.removeAll(where: { $0 === controller })
        }
        
        /// if there is no more child controllers, we clean and finish the coordinator
        if coordinator.childControllers.isEmpty && !coordinator.isRootCoordinator {
            coordinator.childCoordinators.removeAll()
            coordinator.parentCoordinator?.childDidFinish(self)

            if let parent = coordinator.parentCoordinator {
                parent.transitionDidDismiss(transition, navigationController: navigationController, coordinator: parent)
            }
            
            notifyThatCoordinatorFinished()
        }
    }
    
    private func notifyThatCoordinatorFinished() {
        /// This is a workaround to avoid a bug when presenting a controller after the child coordinator finished.
        /// We need a delay to ensure that the coordinator is no longer visible before trying to present something in the parent coodinator.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.coordinatorDidFinish()
        }
    }
}
