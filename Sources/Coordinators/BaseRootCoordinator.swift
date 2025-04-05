//
//  BaseRootCoordinator.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 05.04.2025.
//

import UIKit

open class BaseRootCoordinator: Coordinator {
    public var id: UUID = UUID()
    public var finishedValue: Any?
    public var finished: ((Any?) -> Void)?
    public var parentCoordinator: (any Coordinator)?
    public var childCoordinators: [any Coordinator] = []
    var lastChildTransitions: [UUID: (any Transition)] = [:]
    
    public init() {}
    
    deinit {
        logging?.log("Deinit \(Self.self) with memory \(Unmanaged.passUnretained(self).toOpaque())")
    }
    
    open func start() {
        fatalError("Subclasses must implement start()")
    }
    
    public func open(coordinator: some Coordinator) {
        if let uiCoordinator = coordinator as? UICoordinator {
            lastChildTransitions[coordinator.id] = uiCoordinator.transition
        }
        
        logging?.log("Opening coordinator \(type(of: coordinator)) from \(type(of: self))")
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.start()
    }
    
    public func finish(with value: Any?) {
        finishedValue = value
        childCoordinators.removeAll()
        
        parentCoordinator?.removeControllers(
            from: self,
            didChildPresentedController: false
        ) {
            self.parentCoordinator?.childDidFinish(self)
            self.notifyThatCoordinatorFinished()
        }
    }
    
    public func removeControllers(from childCoordinator: some Coordinator, didChildPresentedController: Bool, completion: @escaping () -> Void) {
        guard let childCoordinator = childCoordinator as? UICoordinator,
            let lastChildTransition = lastChildTransitions[childCoordinator.id] else {
            /// if the child coordinator we are removing is not UICoordinator, then it means it doesn't have controllers to be remove. So we can just complete
            completion()
            return
        }
        
        if let pushTransition = lastChildTransition as? PushTransition {
            /// The childCoordinator must have a sourceCoordinator, if not we don't know where to go back to since this RootCoordinator doesn't own controllers on it's own
            guard let sourceCoordinator = childCoordinator.sourceCoordinator else {
                logging?.log("Deleting child coordinator of a RootCoordinator. If you expected some transition to happen check if you set sourceCoordinator for the child coordinator that is been dismiss.")
                completion()
                return
            }
            
            guard let lastController = sourceCoordinator.childControllers.last else {
                fatalError("We don't have a last controller to go back to. This should never happened.")
            }
            
            pushTransition.delegate = nil
            
            if didChildPresentedController {
                pushTransition.dismiss {
                    pushTransition.pop(to: lastController, completion: nil)
                    self.lastChildTransitions[childCoordinator.id] = nil
                    completion()
                }
            } else {
                pushTransition.pop(to: lastController) {
                    self.lastChildTransitions[childCoordinator.id] = nil
                    completion()
                }
            }
        } else if let presentTransition = lastChildTransition as? PresentTransition {
            presentTransition.delegate = nil
            presentTransition.close {
                self.lastChildTransitions[childCoordinator.id] = nil
                /// we don't need to reassign the delegate, because the last transition was a presentation and that had it's own navigation controller
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
