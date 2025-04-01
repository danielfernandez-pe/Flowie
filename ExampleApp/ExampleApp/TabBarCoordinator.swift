//
//  TabBarCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import Flowie
import UIKit
import class SwiftUI.UIHostingController

final class TabBarCoordinator: BaseCoordinator {
    override var isRootCoordinator: Bool { true }
    
    private let window: UIWindow
    private let tabBarController = UITabBarController()
    
    init(window: UIWindow) {
        self.window = window
        super.init()
    }
    
    override func start() {
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        let homeNavController = BaseNavigationController()
        homeNavController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        let homeTransition = PushTransition(navigationController: homeNavController)
        let homeCoordinator = HomeCoordinator(transition: homeTransition)
        
        let cardsNavController = BaseNavigationController()
        cardsNavController.tabBarItem = UITabBarItem(title: "Cards", image: UIImage(systemName: "creditcard.fill"), tag: 1)
        let cardsTransition = PushTransition(navigationController: cardsNavController)
        let cardsCoordinator = CardsCoordinator(transition: cardsTransition)
        cardsCoordinator.externalRouter = self
        
        open(coordinator: cardsCoordinator)
        open(coordinator: homeCoordinator)

        tabBarController.viewControllers = [
            cardsNavController,
            homeNavController
        ]
    }
}

extension TabBarCoordinator: CardsExternalRouting {
    func needAuthorization(_ coordinator: BaseCoordinator, currentTransition: some Transition, completion: @escaping (Bool) -> Void) {
        guard !currentTransition.isDismissing else { return }
        let presentTransition = PresentTransition(presentingViewController: currentTransition.rootViewController)
        let securityCoordinator = SecurityCoordinator(transition: presentTransition)
        open(coordinator: securityCoordinator)
        
        securityCoordinator.finished = { value in
            guard let authorized = value as? Bool else { return }
            completion(authorized)
        }
    }
    
    func needAuthorizationPushFlow(_ coordinator: BaseCoordinator, currentTransition: some Transition, completion: @escaping (Bool) -> Void) {
        let pushTransition = PushTransition(navigationController: currentTransition.navigationController)
        let securityCoordinator = SecurityCoordinator(transition: pushTransition)
        securityCoordinator.sourceCoordinator = coordinator
        open(coordinator: securityCoordinator)
        
        securityCoordinator.finished = { value in
            guard let authorized = value as? Bool else { return }
            completion(authorized)
        }
    }
    
    func openCreateInstallmentsCard(_ coordinator: BaseCoordinator, currentTransition: some Transition) {
        let presentTransition = PresentTransition(presentingViewController: currentTransition.rootViewController)
        let installmentsCoordinator = CreateInstallmentsCardCoordinator(transition: presentTransition)
        open(coordinator: installmentsCoordinator)
    }
}
