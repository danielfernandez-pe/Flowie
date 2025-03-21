//
//  UIViewController+.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 21.03.2025.
//

import UIKit

extension UIViewController {
    var lastPresentedViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.lastPresentedViewController
        } else {
            return self
        }
    }
}
