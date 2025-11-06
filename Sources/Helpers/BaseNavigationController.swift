//
//  BaseNavigationController.swift
//  Flowie
//
//  Created by Daniel Fernandez on 28.03.2025.
//

import UIKit

public struct NavigationStyle {
    let isTransparent: Bool
    let prefersLargeTitles: Bool
    let tintColor: UIColor
    
    public init(
        isTransparent: Bool = false,
        prefersLargeTitles: Bool = false,
        tintColor: UIColor = .systemBlue // Default iOS blue
    ) {
        self.isTransparent = isTransparent
        self.prefersLargeTitles = prefersLargeTitles
        self.tintColor = tintColor
    }
}

public final class BaseNavigationController: UINavigationController {
    let style: NavigationStyle
    var disableGesture = false
    
    public init(style: NavigationStyle? = nil) {
        self.style = style ?? .init()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        
        if style.isTransparent {
            navigationBarAppearance.configureWithTransparentBackground()
        } else {
            navigationBarAppearance.configureWithDefaultBackground()
        }

        // Hide back button title
        navigationBarAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        navigationBarAppearance.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        // Apply appearance to all navigation bar states
        navigationBar.standardAppearance = navigationBarAppearance
        navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationBar.compactAppearance = navigationBarAppearance
        navigationBar.compactScrollEdgeAppearance = navigationBarAppearance
        navigationBar.prefersLargeTitles = style.prefersLargeTitles

        // Tint color for back button and other interactive elements
        navigationBar.tintColor = style.tintColor
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
