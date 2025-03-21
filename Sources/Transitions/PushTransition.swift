//
//  PushTransition.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 21.03.2025.
//

import UIKit

@MainActor
public final class PushTransition: NSObject, Transition {
    public var rootViewController: UIViewController {
        navigationController.topViewController?.lastPresentedViewController ?? navigationController
    }
    
    public weak var delegate: TransitionDelegate?
    public weak var coordinator: BaseCoordinator?
    public let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        navigationController.delegate = self
    }

    deinit {
        print("\(Self.self) got deinit")
    }
    
    public func open(_ controller: UIViewController) {
        navigationController.pushViewController(controller, animated: true)
    }

    public func dismiss() {
    }

    public func pop() {
        navigationController.popViewController(animated: true)
    }
    
    public func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
    
    public func pop(to controller: UIViewController) {
        navigationController.popToViewController(controller, animated: true)
    }
}

extension PushTransition: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        
        // is showing
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }
        
        // is popping
        if let coordinator {
            if navigationController.viewControllers.count == 1 {
                delegate?.transitionDidPopToRoot(self, navigationController: navigationController, coordinator: coordinator)
            } else {
                delegate?.transitionDidPop(self, controller: fromViewController, coordinator: coordinator)
            }
        }
    }
}
