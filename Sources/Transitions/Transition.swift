//
//  Transition.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 21.03.2025.
//

import SwiftUI

@MainActor
public protocol TransitionDelegate: AnyObject {
    func transitionDidPop(_ transition: some Transition,
                          controller: UIViewController,
                          navigationController: UINavigationController,
                          coordinator: some Coordinator)
    func transitionDidPopToRoot(_ transition: some Transition,
                                navigationController: UINavigationController,
                                coordinator: some Coordinator)
    func transitionDidDismiss(_ transition: some Transition,
                              navigationController: UINavigationController,
                              coordinator: some Coordinator)
}

@MainActor
public protocol Transition: AnyObject {
    var delegate: TransitionDelegate? { get set }
    var coordinator: (any Coordinator)? { get set }
    var isDismissing: Bool { get set }
    
    var rootViewController: UIViewController { get }
    var navigationController: UINavigationController { get }
    
    func open(_ controller: UIViewController)
    func close(completion: (() -> Void)?)
    func reassignNavigationDelegate()
}

public extension Transition {
    func close() {
        close(completion: nil)
    }
}
