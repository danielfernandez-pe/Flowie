//
//  PushTransition.swift
//  Flowie
//
//  Created by Daniel Fernandez on 14.03.2025.
//

import UIKit

///
/// This structure will let you define the customization you want
/// the navigation to have.
///
/// - isBackHidden: If you don't want the user to be able to go back using the navigationItem.
///     **⚠️ There is a bug (most probably) so in order to not see the back button
///     you need to also use .navigationBarBackButtonHidden() in the view.
///     **
///
struct PushParameters {
    let isBackHidden: Bool
    
    init(isBackHidden: Bool) {
        self.isBackHidden = isBackHidden
    }
}

@MainActor
final class PushTransition: NSObject, Transition {
    var rootViewController: UIViewController {
        navigationController.topViewController?.lastPresentedViewController ?? navigationController
    }
    
    weak var delegate: TransitionDelegate?
    weak var coordinator: BaseCoordinator?
    let navigationController: UINavigationController
    private let parameters: PushParameters?

    init(navigationController: UINavigationController, parameters: PushParameters? = nil) {
        self.navigationController = navigationController
        self.parameters = parameters
        super.init()
        navigationController.delegate = self
    }

    deinit {
        print("\(Self.self) got deinit")
    }
    
    func open(_ controller: UIViewController) {
        if let parameters {
            controller.navigationItem.hidesBackButton = parameters.isBackHidden
            (navigationController as? BaseNavigationController)?.disableGesture = parameters.isBackHidden
        }

        navigationController.pushViewController(controller, animated: true)
    }

    func dismiss(completion: (() -> Void)?) {
        navigationController.dismiss(animated: true) {
            completion?()
        }
    }

    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func pop(to controller: UIViewController, completion: (() -> Void)?) {
        navigationController.popToViewController(controller, animated: true) {
            completion?()
        }
    }
    
    func reassignNavigationDelegate() {
        navigationController.delegate = self
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
                delegate?.transitionDidPop(self, controller: fromViewController, navigationController: navigationController, coordinator: coordinator)
            }
        }
    }
}
