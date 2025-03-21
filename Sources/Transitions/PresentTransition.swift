//
//  PresentTransition.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 21.03.2025.
//

import UIKit

public struct PresentParameters {
    let modalPresentationStyle: UIModalPresentationStyle
    
    public init(modalPresentationStyle: UIModalPresentationStyle) {
        self.modalPresentationStyle = modalPresentationStyle
    }
}

@MainActor
public final class PresentTransition: NSObject, Transition {
    public var rootViewController: UIViewController {
        navigationController.topViewController?.lastPresentedViewController ?? navigationController
    }
    
    public weak var delegate: TransitionDelegate?
    public weak var coordinator: BaseCoordinator?
    public let navigationController = UINavigationController()
    private let presentingViewController: UIViewController
    private let parameters: PresentParameters?

    public init(presentingViewController: UIViewController, parameters: PresentParameters? = nil) {
        self.presentingViewController = presentingViewController
        self.parameters = parameters
        super.init()
        navigationController.presentationController?.delegate = self
        navigationController.delegate = self
    }

    public func open(_ controller: UIViewController) {
        if navigationController.viewControllers.isEmpty {
            navigationController.viewControllers = [controller]
            presentingViewController.present(navigationController, animated: true)
        } else {
            navigationController.pushViewController(controller, animated: true)
        }
    }

    public func dismiss() {
        presentingViewController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            if let coordinator {
                delegate?.transitionDidDismiss(self, navigationController: navigationController, coordinator: coordinator)
            }
        }
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

extension PresentTransition: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let coordinator {
            delegate?.transitionDidDismiss(self, navigationController: navigationController, coordinator: coordinator)
        }
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if let parameters {
            return parameters.modalPresentationStyle
        }
        
        return .formSheet
    }
}

extension PresentTransition: UINavigationControllerDelegate {
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
