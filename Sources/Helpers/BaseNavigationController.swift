//
//  BaseNavigationController.swift
//  Flowie
//
//  Created by Daniel Fernandez on 28.03.2025.
//

import UIKit

public enum NavigationStyle {
    case transparent
    case `default`
}

public final class BaseNavigationController: UINavigationController {
    let style: NavigationStyle
    var disableGesture = false
    
    public init(style: NavigationStyle = .default) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        switch style {
        case .default:
            navigationBarAppearance.configureWithDefaultBackground()
        case .transparent:
            navigationBarAppearance.configureWithTransparentBackground()
        }

        // Hide back button title
        navigationBarAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        navigationBarAppearance.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
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
