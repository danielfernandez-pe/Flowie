//
//  PresentTransition.swift
//  Flowie
//
//  Created by Daniel Fernandez on 14.03.2025.
//

import UIKit

///
/// This structure will let you define the customization you want
/// the presentation to have.
///
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
    public weak var coordinator: (any Coordinator)?
    public let navigationController = UINavigationController()
    private let presentingViewController: UIViewController
    private let parameters: PresentParameters?
    
    public var isDismissing: Bool = false

    public init(presentingViewController: UIViewController, parameters: PresentParameters? = nil) {
        self.presentingViewController = presentingViewController
        self.parameters = parameters
        super.init()
        navigationController.presentationController?.delegate = self
    }
    
    deinit {
        logging?.log("Deinit \(Self.self)")
    }

    public func open(_ controller: UIViewController) {
        navigationController.setViewControllers([controller], animated: true)
        presentingViewController.present(navigationController, animated: true)
    }

    public func close(completion: (() -> Void)?) {
        isDismissing = true
        presentingViewController.dismiss(animated: true) { [weak self] in
            completion?()
            guard let self else { return }
            if let coordinator {
                delegate?.transitionDidDismiss(self, navigationController: navigationController, coordinator: coordinator)
            }
        }
    }
    
    public func reassignNavigationDelegate() {
    }
}

extension PresentTransition: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        isDismissing = true
    }
    
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
