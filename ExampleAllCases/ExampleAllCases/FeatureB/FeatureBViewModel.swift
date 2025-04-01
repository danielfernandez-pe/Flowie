//
//  FeatureBViewModel.swift
//  ExampleAllCases
//
//  Created by Daniel Fernandez on 01.04.2025.
//

import Combine

@MainActor
protocol FeatureBRouting: AnyObject {
    func featureBRouting(to route: FeatureBViewModel.Route)
}

@MainActor
final class FeatureBViewModel {
    enum Route {
        case pushSameFlow
        case presentSameFlow
        case presentNewFlow
        case pushNewFlow
        case close
        case finishCoordinator
    }
    
    weak var router: (any FeatureBRouting)?
    
    deinit {
        print("deinit \(Self.self) with memory \(Unmanaged.passUnretained(self).toOpaque())")
    }
    
    func pushSameFlow() {
        router?.featureBRouting(to: .pushSameFlow)
    }
    
    func pushNewFlow() {
        router?.featureBRouting(to: .pushNewFlow)
    }
    
    func presentSameFlow() {
        router?.featureBRouting(to: .presentSameFlow)
    }
    
    func presentNewFlow() {
        router?.featureBRouting(to: .presentNewFlow)
    }
    
    func close() {
        router?.featureBRouting(to: .close)
    }
    
    func finishCoordinator() {
        router?.featureBRouting(to: .finishCoordinator)
    }
}
