//
//  HomeCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import Flowie
import UIKit
import class SwiftUI.UIHostingController

final class HomeCoordinator: BaseCoordinator2 {
    override func start() {
        let homeController = UIHostingController(rootView: HomeView())
        open(controller: homeController, with: transition)
    }
}
