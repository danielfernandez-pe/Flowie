//
//  SecurityCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import Flowie
import UIKit
import class SwiftUI.UIHostingController

final class SecurityCoordinator: BaseCoordinator {    
    override func start() {
        let securityController = UIHostingController(rootView: SecurityView(coordinator: self))
        open(controller: securityController, with: transition)
    }
    
    func finishWithSuccess() {
        finish(with: true)
    }
    
    func finishWithFailure() {
        finish(with: false)
    }
}
