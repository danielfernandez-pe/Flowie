//
//  CardsCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import Flowie
import UIKit
import class SwiftUI.UIHostingController

final class CardsCoordinator: BaseCoordinator {
    override func start() {
        let cardsController = SwiftUI.UIHostingController(rootView: CardsView(coordinator: self))
        open(controller: cardsController, with: transition)
    }
    
    func startAddCardFlow() {
        let presentTransition = PresentTransition(presentingViewController: transition.rootViewController)
        open(coordinator: AddCardCoordinator(transition: presentTransition))
    }
    
    func startChangePinFlow() {
        let presentTransition = PresentTransition(presentingViewController: transition.rootViewController)
        let securityCoordinator = SecurityCoordinator(transition: presentTransition)
        open(coordinator: securityCoordinator)
        
        securityCoordinator.finishedWithValue = { [weak self] value in
            guard let authorized = value as? Bool else { return }
            
            if authorized {
                let presentTransition = PresentTransition(presentingViewController: self!.transition.rootViewController)
                self?.open(coordinator: ChangePinCoordinator(transition: presentTransition))
            } else {
                print("nothing happened because the user was not authorized")
            }
        }
    }
}
