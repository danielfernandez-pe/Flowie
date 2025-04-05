//
//  BaseCoordinator.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 05.04.2025.
//

import UIKit

open class BaseCoordinator: UICoordinator {
    public var id: UUID = UUID()
    
    public var transition: any Transition {
        guard let last = transitions.last else {
            fatalError("Error in \(Self.self) where there should always be one transition in a coordinator")
        }
        return last
    }
    
    public var sourceCoordinator: (any UICoordinator)?
    public var finishedValue: Any?
    public var finished: ((Any?) -> Void)?
    public var parentCoordinator: (any Coordinator)?
    public var childControllers: [UIViewController] = []
    public var childCoordinators: [any Coordinator] = []
    public var transitions: [any Transition] = []
    
    public init(transition: some Transition) {
        transitions.append(transition)
        logging?.log("Init \(Self.self) with memory \(Unmanaged.passUnretained(self).toOpaque())")
    }
    
    deinit {
        logging?.log("Deinit \(Self.self) with memory \(Unmanaged.passUnretained(self).toOpaque())")
    }
    
    open func start() {
        fatalError("Subclasses must implement start()")
    }
    
    public func open(controller: UIViewController, with transition: some Transition) {
        childControllers.append(controller)
        
        if !transitions.contains(where: { $0 === transition }) {
            transitions.append(transition)
        }
        
        transition.delegate = self
        transition.coordinator = self
        transition.open(controller)
    }
    
    public func open(coordinator: some Coordinator) {
        /// Usually UICoordinators only open other UICoordinators
        guard let uiCoordinator = coordinator as? UICoordinator else {
            return
        }
        
        var parentCoordinatorTransitionIsDismissing = false

        if let parent = parentCoordinator as? UICoordinator {
            parentCoordinatorTransitionIsDismissing = parent.transition.isDismissing
        }
        
        /// We need to check if either this coordinator or it's parent might be in the middle of a dismissing transition
        if transition.isDismissing || parentCoordinatorTransitionIsDismissing {
            logging?.log("Opening coordinator \(type(of: coordinator)) from \(type(of: self)) but the last transition \(type(of: transition)) has a dismissing state of \(transition.isDismissing)")
            logging?.log("Failed to open the coordinator")
            return
        }
        
        logging?.log("Opening coordinator \(type(of: coordinator)) from \(type(of: self))")
        
        childCoordinators.append(coordinator)
        
        if !transitions.contains(where: { $0 === uiCoordinator.transition }) {
            transitions.append(uiCoordinator.transition)
        }
        
        coordinator.parentCoordinator = self
        coordinator.start()
    }
    
    public func finish(with value: Any?) {
        /// we check if we didn't delete the transitions previously (e.g. user pressing multiple times a button to finish the coordinator)
        guard !transitions.isEmpty else { return }
        transition.delegate = nil
        transition.coordinator = nil
        transitions.removeAll()
        
        finishedValue = value
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
    
    public func removeControllers(from childCoordinator: some Coordinator, didChildPresentedController: Bool, completion: @escaping () -> Void) {
        /// I need to check what was the type of the last transition
        if let pushTransition = transition as? PushTransition {
            guard let lastController = childControllers.last else {
                fatalError("Coordinator \(Self.self) should always have at least one child controller when child coordinator is been removed")
            }
            
            /// I don't want the transition delegate to run again the removal logic
            pushTransition.delegate = nil
            
            if didChildPresentedController {
                pushTransition.dismiss {
                    pushTransition.pop(to: lastController, completion: nil)
                    /// Once I went back to the last controller I can remove the last transition of the father.
                    self.transitions.removeLast()
                    /// I need to reassign the delegate of the navigation to the current transition
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
        } else if let presentTransition = transition as? PresentTransition {
            /// If it's a presentation transition, again I remove the delegate so it doesn't run the removal logic
            transition.delegate = nil
            presentTransition.close {
                /// we don't need to reassign the delegate, because the last transition was a presentation and that had it's own navigation controller
                self.transitions.removeLast()
                completion()
            }
        } else {
            fatalError("this should never happen")
        }
    }
    
    public func childDidFinish(_ childCoordinator: some Coordinator) {
        childCoordinators.removeAll { $0 === childCoordinator }
    }
    
    private func notifyThatCoordinatorFinished() {
        /// This is a workaround to avoid a bug when presenting a controller after the child coordinator finished.
        /// We need a delay to ensure that the coordinator is no longer visible before trying to present something in the parent coodinator.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.coordinatorDidFinish()
        }
    }
    
    private func coordinatorDidFinish() {
        finished?(finishedValue)
    }
}

extension BaseCoordinator: TransitionDelegate {
    public func transitionDidPop(_ transition: some Transition, controller: UIViewController, navigationController: UINavigationController, coordinator: some Coordinator) {
        guard let uiCoordinator = coordinator as? UICoordinator else { return }
        /// we clean the coordinator a bit. First, we remove the last transition
        uiCoordinator.transitions.removeLast()
        /// then we remove controller from the list of child controllers
        uiCoordinator.childControllers.removeAll(where: { $0 === controller })
        
        /// if there is no more controllers, we can remove this coordinator
        if uiCoordinator.childControllers.isEmpty {
            uiCoordinator.childCoordinators.removeAll()
            uiCoordinator.parentCoordinator?.childDidFinish(self)
            
            /// if we are removin this coordinator, we need to also remove the last transition of the parent.
            if let parentCoordinator = coordinator.parentCoordinator as? UICoordinator {
                parentCoordinator.transitions.removeLast()
                parentCoordinator.transition.reassignNavigationDelegate()
            }
            
            if let parent = uiCoordinator.parentCoordinator as? BaseRootCoordinator {
                parent.lastChildTransitions[uiCoordinator.id] = nil
            }

            notifyThatCoordinatorFinished()
        } else {
            /// it the coordinator still have child controllers to manage, then we reassign the navigation delegate to the current transition.
            uiCoordinator.transition.reassignNavigationDelegate()
        }
    }
    
    public func transitionDidPopToRoot(_ transition: some Transition, navigationController: UINavigationController, coordinator: some Coordinator) {
        guard let uiCoordinator = coordinator as? UICoordinator,
              let firstController = navigationController.viewControllers.first else { return }
        
        let isCoordinatorMainRootOfNavigation = uiCoordinator.childControllers.contains(where: { $0 === firstController })
        
        /// if the current coordinator has the first controller of the navigation we can assure that this coordinator will be remaining after the popToRoot.
        if isCoordinatorMainRootOfNavigation {
            /// delete all transitions and controllers but the first one, which is the one that started (pushed) the navigation controller
            uiCoordinator.transitions.removeSubrange(1...)
            uiCoordinator.childControllers.removeSubrange(1...)
            
            /// we need the current transition to be the delegate again
            uiCoordinator.transition.reassignNavigationDelegate()
        } else {
            /// this coordinator will must likely be remove from the parent so we clean and finish it.
            uiCoordinator.transitions.removeAll()
            uiCoordinator.childControllers.removeAll()
            uiCoordinator.childCoordinators.removeAll()
            uiCoordinator.parentCoordinator?.childDidFinish(self)
            
            /// we call the parent to make sure we get to the root
            if let parent = uiCoordinator.parentCoordinator as? BaseCoordinator {
                parent.transitionDidPopToRoot(
                    transition,
                    navigationController: navigationController,
                    coordinator: parent
                )
            }
            
            if let parent = uiCoordinator.parentCoordinator as? BaseRootCoordinator {
                parent.lastChildTransitions[uiCoordinator.id] = nil
            }
            
            notifyThatCoordinatorFinished()
        }
    }
    
    public func transitionDidDismiss(_ transition: some Transition, navigationController: UINavigationController, coordinator: some Coordinator) {
        guard let uiCoordinator = coordinator as? UICoordinator else { return }
        /// we delete all possible PushTransitions after the PresentTransition
        if let index = uiCoordinator.transitions.firstIndex(where: { $0 === transition }) {
            uiCoordinator.transitions.removeSubrange(index...)
        }
        
        /// we remove all the controllers from the navigation that are part of the child controllers of this coordinator
        for controller in navigationController.viewControllers {
            uiCoordinator.childControllers.removeAll(where: { $0 === controller })
        }
        
        /// if there is no more child controllers, we clean and finish the coordinator
        if uiCoordinator.childControllers.isEmpty {
            coordinator.childCoordinators.removeAll()
            coordinator.parentCoordinator?.childDidFinish(self)

            if let parent = coordinator.parentCoordinator as? BaseCoordinator {
                parent.transitionDidDismiss(transition, navigationController: navigationController, coordinator: parent)
            }
            
            if let parent = coordinator.parentCoordinator as? BaseRootCoordinator {
                parent.lastChildTransitions[uiCoordinator.id] = nil
            }
            
            notifyThatCoordinatorFinished()
        }
    }
}
