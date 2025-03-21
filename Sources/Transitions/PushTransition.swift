//
//  PushTransition.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 21.03.2025.
//

import UIKit

@MainActor
final class PushTransition: NSObject, Transition {
    var rootViewController: UIViewController {
        navigationController.topViewController?.lastPresentedViewController ?? navigationController
    }
    
    weak var delegate: TransitionDelegate?
    weak var coordinator: BaseCoordinator?
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        navigationController.delegate = self
    }

    deinit {
        print("\(Self.self) got deinit")
    }
    
    func open(_ controller: UIViewController) {
        navigationController.pushViewController(controller, animated: true)
    }

    func dismiss() {
    }

    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func pop(to controller: UIViewController) {
        navigationController.popToViewController(controller, animated: true)
    }
}

extension PushTransition: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
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
