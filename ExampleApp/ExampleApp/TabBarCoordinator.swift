//
//  TabBarCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import Flowie
import SwiftUI

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
        
        open(coordinator: homeCoordinator)
        open(coordinator: cardsCoordinator)

        tabBarController.viewControllers = [
            homeNavController,
            cardsNavController
        ]
    }
}
