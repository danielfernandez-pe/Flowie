//
//  CreateInstallmentsCardCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez on 31.03.2025.
//

import Flowie
import UIKit
import class SwiftUI.UIHostingController

final class CreateInstallmentsCardCoordinator: BaseCoordinator {
    override func start() {
        let createCardController = UIHostingController(rootView: CreateInstallmentsCardView(coordinator: self))
        open(controller: createCardController, with: transition)
    }
    
    func showCardCreated() {
        let cardCreatedController = UIHostingController(rootView: CardCreatedView(coordinator: self))
        let pushParameters = PushParameters(isBackHidden: true)
        let pushTransition = PushTransition(navigationController: transition.navigationController, parameters: pushParameters)
        open(controller: cardCreatedController, with: pushTransition)
    }
    
    func finishTapped() {
        finish(with: nil)
    }
}
