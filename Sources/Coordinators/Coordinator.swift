//
//  Coordinator.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 04.04.2025.
//

import UIKit

@MainActor
public protocol Coordinator: AnyObject {
    var finishedValue: Any? { get set }
    var finished: ((Any?) -> Void)? { get set }
    var parentCoordinator: (any Coordinator)? { get set }
    var childCoordinators: [any Coordinator] { get set }
    
    func start()
    func open(coordinator: some Coordinator)
    func finish(with value: Any?)
    func removeControllers(from childCoordinator: some Coordinator,
                           didChildPresentedController: Bool,
                           completion: @escaping () -> Void)
    func childDidFinish(_ childCoordinator: some Coordinator)
}

public extension Coordinator {
    func finish() {
        finish(with: nil)
    }
}

public protocol UICoordinator: Coordinator {
    var sourceCoordinator: (any UICoordinator)? { get }
    var transition: any Transition { get }
    var transitions: [any Transition] { get set }
    var childControllers: [UIViewController] { get set }
    
    func open(controller: UIViewController, with transition: some Transition)
}
