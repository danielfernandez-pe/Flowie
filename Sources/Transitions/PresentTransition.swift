//
//  PresentTransition.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 21.03.2025.
//

import UIKit

@MainActor
final class PresentTransition: NSObject, Transition {
    var rootViewController: UIViewController {
        navigationController.topViewController?.lastPresentedViewController ?? navigationController
    }
    
    weak var delegate: TransitionDelegate?
    weak var coordinator: BaseCoordinator?
    let navigationController = UINavigationController()
    private let presentingViewController: UIViewController

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init()
        navigationController.presentationController?.delegate = self
        navigationController.delegate = self
    }

    func open(_ controller: UIViewController) {
        if navigationController.viewControllers.isEmpty {
            navigationController.viewControllers = [controller]
            presentingViewController.present(navigationController, animated: true)
        } else {
            navigationController.pushViewController(controller, animated: true)
        }
    }

    func dismiss() {
        presentingViewController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            if let coordinator {
                delegate?.transitionDidDismiss(self, navigationController: navigationController, coordinator: coordinator)
            }
        }
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

extension PresentTransition: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let coordinator {
            delegate?.transitionDidDismiss(self, navigationController: navigationController, coordinator: coordinator)
        }
    }
}

extension PresentTransition: UINavigationControllerDelegate {
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
