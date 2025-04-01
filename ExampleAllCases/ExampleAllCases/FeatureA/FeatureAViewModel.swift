//
//  FeatureAViewModel.swift
//  ExampleAllCases
//
//  Created by Daniel Fernandez on 01.04.2025.
//

import Combine

@MainActor
protocol FeatureARouting: AnyObject {
    func featureARouting(to route: FeatureAViewModel.Route)
}

@MainActor
final class FeatureAViewModel {
    enum Route {
        case pushSameFlow
        case presentSameFlow
        case presentNewFlow
        case pushNewFlow
        case close
        case finishCoordinator
    }
    
    weak var router: (any FeatureARouting)?
    
    deinit {
        print("deinit \(Self.self) with memory \(Unmanaged.passUnretained(self).toOpaque())")
    }
    
    func pushSameFlow() {
        router?.featureARouting(to: .pushSameFlow)
    }
    
    func pushNewFlow() {
        router?.featureARouting(to: .pushNewFlow)
    }
    
    func presentSameFlow() {
        router?.featureARouting(to: .presentSameFlow)
    }
    
    func presentNewFlow() {
        router?.featureARouting(to: .presentNewFlow)
    }
    
    func close() {
        router?.featureARouting(to: .close)
    }
    
    func finishCoordinator() {
        router?.featureARouting(to: .finishCoordinator)
    }
}
