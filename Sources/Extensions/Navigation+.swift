//
//  Navigation+.swift
//  Flowie
//
//  Created by Daniel Fernandez on 26.03.2025.
//

import UIKit

extension UIViewController {
    var lastPresentedViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.lastPresentedViewController
        } else {
            return self
        }
    }
}

extension UINavigationController {
    public func pushViewController(_ viewController: UIViewController,
                                   animated: Bool,
                                   completion: @escaping () -> Void){
            pushViewController(viewController, animated: animated)
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    public func popToViewController(_ viewController: UIViewController,
                                    animated: Bool,
                                    completion: @escaping () -> Void) {
        popToViewController(viewController, animated: animated)
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}
