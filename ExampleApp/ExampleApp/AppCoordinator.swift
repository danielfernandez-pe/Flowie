//
//  AppCoordinator.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import Flowie
import UIKit
import OSLog

extension Logger: @retroactive FlowLogging {
    static let exampleLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "flowLogger")
    
    public func log(_ message: String) {
        debug("\(message)")
    }
}

final class AppCoordinator: BaseRootCoordinator {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        super.init()
        Flowie.logging = Logger.exampleLogger
    }
    
    override func start() {
        let tabBarCoordinator = TabBarCoordinator(window: window)
        open(coordinator: tabBarCoordinator)
    }
}
