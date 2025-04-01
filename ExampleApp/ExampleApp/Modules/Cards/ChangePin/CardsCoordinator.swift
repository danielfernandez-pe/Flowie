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
    func needAuthorization(_ coordinator: BaseCoordinator, currentTransition: some Transition, completion: @escaping (Bool) -> Void)
    func needAuthorizationPushFlow(_ coordinator: BaseCoordinator, currentTransition: some Transition, completion: @escaping (Bool) -> Void)
    func openCreateInstallmentsCard(_ coordinator: BaseCoordinator, currentTransition: some Transition)
}

final class CardsCoordinator: BaseCoordinator {
    weak var externalRouter: CardsExternalRouting?
    
    override func start() {
        let cardsController = UIHostingController(rootView: CardsView(coordinator: self))
        open(controller: cardsController, with: transition)
    }
    
    func startAddCardFlow() {
        let presentTransition = PresentTransition(presentingViewController: transition.rootViewController)
        let coordinator = AddCardCoordinator(transition: presentTransition)
        open(coordinator: coordinator)
        
        coordinator.finished = { [weak self] value in
            guard let result = value as? AddCardCoordinator.CoordinatorResult, let self else { return }
            switch result {
            case .openCreateInstallmentsCard:
                externalRouter?.openCreateInstallmentsCard(self, currentTransition: transition)
            }
        }
    }
    
    func pushNewFlow() {
        externalRouter?.needAuthorizationPushFlow(self, currentTransition: transition, completion: { [weak self] authorized in
            guard let self else { return }
            if authorized {
                let presentTransition = PresentTransition(presentingViewController: transition.rootViewController)
                open(coordinator: ChangePinCoordinator(transition: presentTransition))
            } else {
                print("nothing happened because the user was not authorized")
            }
        })
    }
    
    func startChangePinFlow() {
        // basically I tried to present modally (I created my coordinator and present transition in the tab bar coordinator)
        // and try to present in the current transition (WHICH IS STILL THE LAST PRESENT from AddCardView) and haven't got deallocated.
        // and when I tried, that controller is not in the window hierarchy.
//        Attempt to present <UINavigationController: 0x105020800> on <UINavigationController: 0x106043a00> (from <_TtGC7SwiftUI19UIHostingControllerV10ExampleApp11AddCardView_: 0x105829e00>) whose view is not in the window hierarchy.
        externalRouter?.needAuthorization(self, currentTransition: transition) { [weak self] authorized in
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
