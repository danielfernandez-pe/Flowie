//
//  BaseNavigationController.swift
//  Flowie
//
//  Created by Daniel Fernandez on 28.03.2025.
//

import UIKit

public final class BaseNavigationController: UINavigationController {
    var disableGesture = false
    
    func initAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()

        // Apply appearance to all navigation bar states
        navigationBar.standardAppearance = navigationBarAppearance
        navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationBar.compactAppearance = navigationBarAppearance
        navigationBar.compactScrollEdgeAppearance = navigationBarAppearance

        // Tint color for back button and other interactive elements
        navigationBar.tintColor = .systemBlue // Default iOS blue
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
        interactivePopGestureRecognizer?.delegate = self
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            return viewControllers.count > 1 && !disableGesture
        } else {
            // default value
            return true
        }
    }
}
