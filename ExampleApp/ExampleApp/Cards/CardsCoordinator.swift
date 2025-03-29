//
//  CardsCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import Flowie
import UIKit
import class SwiftUI.UIHostingController

protocol CardsExternalRouting: AnyObject {
    func needAuthorization(currentTransition: some Transition, completion: @escaping (Bool) -> Void)
}

final class CardsCoordinator: BaseCoordinator {
    weak var externalRouter: CardsExternalRouting?
    
    override func start() {
        let cardsController = SwiftUI.UIHostingController(rootView: CardsView(coordinator: self))
        open(controller: cardsController, with: transition)
    }
    
    func startAddCardFlow() {
        let presentTransition = PresentTransition(presentingViewController: transition.rootViewController)
        open(coordinator: AddCardCoordinator(transition: presentTransition))
    }
    
    func startChangePinFlow() {
        externalRouter?.needAuthorization(currentTransition: transition) { [weak self] authorized in
            guard let self else { return }
            if authorized {
                let presentTransition = PresentTransition(presentingViewController: transition.rootViewController)
                open(coordinator: ChangePinCoordinator(transition: presentTransition))
            } else {
                print("nothing happened because the user was not authorized")
            }
        }
    }
}
