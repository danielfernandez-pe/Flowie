//
//  SecurityView.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import SwiftUI

struct SecurityView: View {
    let coordinator: SecurityCoordinator
    
    var body: some View {
        VStack(spacing: 50) {
            Button("Dismiss with success") {
                coordinator.finishWithSuccess()
            }
            
            Button("Dismiss with failure") {
                coordinator.finishWithFailure()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
    }
}
