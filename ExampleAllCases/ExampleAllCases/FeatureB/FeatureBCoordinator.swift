//
//  FeatureBCoordinator.swift
//  ExampleAllCases
//
//  Created by Daniel Fernandez on 01.04.2025.
//

import Combine
import Flowie
import class SwiftUI.UIHostingController

final class FeatureBCoordinator: BaseCoordinator {
    override func start() {
        let viewModel = FeatureBViewModel()
        viewModel.router = self
        let controller = UIHostingController(rootView: FeatureBView(viewModel: viewModel))
        open(controller: controller, with: transition)
    }
    
    private func openFeatureA(transition: some Transition) {
        let viewModel = FeatureAViewModel()
        viewModel.router = self
        let controller = UIHostingController(rootView: FeatureAView(viewModel: viewModel))
        open(controller: controller, with: transition)
    }
    
    private func openFeatureAWithCoordinator(transition: some Transition) {
        let coordinator = FeatureACoordinator(transition: transition)
        open(coordinator: coordinator)
    }
    
    private func openFeatureB(transition: some Transition) {
        let viewModel = FeatureBViewModel()
        viewModel.router = self
        let controller = UIHostingController(rootView: FeatureBView(viewModel: viewModel))
        open(controller: controller, with: transition)
    }
    
    private func openFeatureBWithCoordinator(transition: some Transition) {
        let coordinator = FeatureBCoordinator(transition: transition)
        open(coordinator: coordinator)
    }
}

extension FeatureBCoordinator: FeatureBRouting {
    func featureBRouting(to route: FeatureBViewModel.Route) {
        switch route {
        case .pushSameFlow:
            let pushTransition = PushTransition(navigationController: transition.navigationController)
            openFeatureA(transition: pushTransition)
        case .pushNewFlow:
            let pushTransition = PushTransition(navigationController: transition.navigationController)
            openFeatureAWithCoordinator(transition: pushTransition)
        case .presentSameFlow:
            let presentTransition = PresentTransition(
                presentingViewController: transition.rootViewController
            )
            openFeatureA(transition: presentTransition)
        case .presentNewFlow:
            let presentTransition = PresentTransition(
                presentingViewController: transition.rootViewController
            )
            openFeatureAWithCoordinator(transition: presentTransition)
        case .close:
            transition.close()
        case .finishCoordinator:
            finish(with: 5)
        }
    }
}

extension FeatureBCoordinator: FeatureARouting {
    func featureARouting(to route: FeatureAViewModel.Route) {
        switch route {
        case .pushSameFlow:
            let pushTransition = PushTransition(navigationController: transition.navigationController)
            openFeatureB(transition: pushTransition)
        case .pushNewFlow:
            let pushTransition = PushTransition(navigationController: transition.navigationController)
            openFeatureBWithCoordinator(transition: pushTransition)
        case .presentSameFlow:
            let presentTransition = PresentTransition(
                presentingViewController: transition.rootViewController
            )
            openFeatureB(transition: presentTransition)
        case .presentNewFlow:
            let presentTransition = PresentTransition(
                presentingViewController: transition.rootViewController
            )
            openFeatureBWithCoordinator(transition: presentTransition)
        case .close:
            transition.close()
        case .finishCoordinator:
            finish()
        }
    }
}
