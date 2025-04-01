//
//  AppCoordinator.swift
//  ExampleAllCases
//
//  Created by Daniel Fernandez on 01.04.2025.
//

import UIKit
import Flowie
import OSLog

extension Logger: @retroactive FlowLogging {
    static let exampleLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "flowLogger")
    
    public func log(_ message: String) {
        debug("\(message)")
    }
}

final class AppCoordinator: BaseCoordinator {
    override var isRootCoordinator: Bool { true }
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        super.init()
        Flowie.logging = Logger.exampleLogger
    }
    
    override func start() {
        let navController = BaseNavigationController()
        let pushTransition = PushTransition(navigationController: navController)
        let featureACoordinator = FeatureACoordinator(transition: pushTransition)
        open(coordinator: featureACoordinator)
        
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
}

/*
 test cases:
 - push and pop by the system ✅
 - push coordinator and pop by the system ✅
 - push coordinator, push, close, close ✅
 - push, push coordinator, close, close ✅
 - push, push coordinator, pop by the system, pop by the system ✅
 - push coordinator, push, finish. ✅
 - present and dismiss by system ✅
 - present and dismiss by button ✅
 - present coordinator and dismiss programatically ✅
 - present coordinator, present and finish should dismiss both and go back to parent coordinator ✅
 - push coordinator, present coordinator. Finish, should maintain the pushed coordinator. Finish again, back to root ✅
 - present, push coordinator, finish. It should maintain the presented controller because it's from the previous coordinator. Then dismiss. ✅
 */
