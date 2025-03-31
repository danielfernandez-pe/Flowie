//
//  ChangePinCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import Flowie
import UIKit
import class SwiftUI.UIHostingController

final class ChangePinCoordinator: BaseCoordinator {
    override func start() {
        let changePinController = SwiftUI.UIHostingController(rootView: ChangePinView())
        open(controller: changePinController, with: transition)
    }
}
