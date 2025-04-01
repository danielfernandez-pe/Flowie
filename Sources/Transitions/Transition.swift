//
//  Transition.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 21.03.2025.
//

import SwiftUI
import Combine

@MainActor
public protocol TransitionDelegate: AnyObject {
    func transitionDidPop(_ transition: some Transition,
                          controller: UIViewController,
                          navigationController: UINavigationController,
                          coordinator: BaseCoordinator)
    func transitionDidPopToRoot(_ transition: some Transition,
                                navigationController: UINavigationController,
                                coordinator: BaseCoordinator)
    func transitionDidDismiss(_ transition: some Transition,
                              navigationController: UINavigationController,
                              coordinator: BaseCoordinator)
}

@MainActor
public protocol Transition: AnyObject {
    var delegate: TransitionDelegate? { get set }
    var coordinator: BaseCoordinator? { get set }
    var isDismissing: Bool { get set }
    
    var rootViewController: UIViewController { get }
    var navigationController: UINavigationController { get }
    
    func open(_ controller: UIViewController)
    func pop()
    func popToRoot()
    func pop(to controller: UIViewController, completion: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
    func reassignNavigationDelegate()
}

public extension Transition {
    func dismiss() {
        dismiss(completion: nil)
    }
    
    func pop(to controller: UIViewController) {
        pop(to: controller, completion: nil)
    }
}
