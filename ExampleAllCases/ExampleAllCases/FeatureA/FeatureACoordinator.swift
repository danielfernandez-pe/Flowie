//
//  FeatureACoordinator.swift
//  ExampleAllCases
//
//  Created by Daniel Fernandez on 01.04.2025.
//

import Combine
import Flowie
import class SwiftUI.UIHostingController

final class FeatureACoordinator: BaseCoordinator {
    override func start() {
        let viewModel = FeatureAViewModel()
        viewModel.router = self
        let controller = UIHostingController(rootView: FeatureAView(viewModel: viewModel))
        open(controller: controller, with: transition)
    }

    private func openFeatureA(transition: Transition) {
        let viewModel = FeatureAViewModel()
        viewModel.router = self
        let controller = UIHostingController(rootView: FeatureAView(viewModel: viewModel))
        open(controller: controller, with: transition)
    }
    
    private func openFeatureB(transition: Transition) {
        let viewModel = FeatureBViewModel()
        viewModel.router = self
        let controller = UIHostingController(rootView: FeatureBView(viewModel: viewModel))
        open(controller: controller, with: transition)
    }
    
    private func openFeatureACoordinator(transition: Transition) {
        let coordinator = FeatureACoordinator(transition: transition)
        open(coordinator: coordinator)
    }
    
    private func openFeatureBCoordinator(transition: Transition) {
        let coordinator = FeatureBCoordinator(transition: transition)
        
        coordinator.finished = { [weak self] _ in
            guard let self else { return }
            let presentTransition = PresentTransition(presentingViewController: self.transition.rootViewController)
            self.openFeatureB(transition: presentTransition)
        }
        
        open(coordinator: coordinator)
    }
}

extension FeatureACoordinator: FeatureARouting {
    func featureARouting(to route: FeatureAViewModel.Route) {
        switch route {
        case .pushSameFlow:
            let pushTransition = PushTransition(
                navigationController: transition.navigationController,
                parameters: .init(isBackHidden: false)
            )
            openFeatureB(transition: pushTransition)
        case .pushNewFlow:
            let pushTransition = PushTransition(
                navigationController: transition.navigationController,
                parameters: .init(isBackHidden: true)
            )
            openFeatureBCoordinator(transition: pushTransition)
        case .presentSameFlow:
            let presentTransition = PresentTransition(
                presentingViewController: transition.rootViewController,
                parameters: .init(modalPresentationStyle: .formSheet)
            )
            openFeatureB(transition: presentTransition)
        case .presentNewFlow:
            let presentTransition = PresentTransition(
                presentingViewController: transition.rootViewController
            )
            openFeatureBCoordinator(transition: presentTransition)
        case .close:
            transition.close()
        case .finishCoordinator:
            finish()
        }
    }
}

extension FeatureACoordinator: FeatureBRouting {
    func featureBRouting(to route: FeatureBViewModel.Route) {
        switch route {
        case .pushSameFlow:
            let pushTransition = PushTransition(navigationController: transition.navigationController)
            openFeatureA(transition: pushTransition)
        case .pushNewFlow:
            let pushTransition = PushTransition(navigationController: transition.navigationController)
            openFeatureACoordinator(transition: pushTransition)
        case .presentSameFlow:
            let presentTransition = PresentTransition(
                presentingViewController: transition.rootViewController
            )
            openFeatureA(transition: presentTransition)
        case .presentNewFlow:
            let presentTransition = PresentTransition(
                presentingViewController: transition.rootViewController
            )
            openFeatureACoordinator(transition: presentTransition)
        case .close:
            transition.close()
        case .finishCoordinator:
            finish()
        }
    }
}
