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
    enum CoordinatorResult {
        case openCreateInstallmentsCard
    }
    
    override func start() {
        let addCardController = UIHostingController(rootView: AddCardView(coordinator: self))
        open(controller: addCardController, with: transition)
    }
    
    func openCreateInstallmentsCard() {
        finish(with: CoordinatorResult.openCreateInstallmentsCard)
    }
    
    func finishTheFlow() {
        finish()
    }
}
