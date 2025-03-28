//
//  AddCardCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import Flowie
import UIKit
import class SwiftUI.UIHostingController

final class AddCardCoordinator: BaseCoordinator {
    override func start() {
        let addCardController = SwiftUI.UIHostingController(rootView: AddCardView())
        open(controller: addCardController, with: transition)
    }
}
