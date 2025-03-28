//
//  AppCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import Flowie
import UIKit

final class AppCoordinator: BaseCoordinator {
    override var isRootCoordinator: Bool { true }
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        super.init()
    }
    
    override func start() {
        let tabBarCoordinator = TabBarCoordinator(window: window)
        open(coordinator: tabBarCoordinator)
    }
}
