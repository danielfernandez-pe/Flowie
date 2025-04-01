//
//  CardsView.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import SwiftUI

struct CardsView: View {
    let coordinator: CardsCoordinator
    
    var body: some View {
        VStack(spacing: 50) {
            Button("Add card") {
                coordinator.startAddCardFlow()
            }
            
            Button("Change pin") {
                coordinator.startChangePinFlow()
            }
            
            Button("Push") {
                coordinator.pushNewFlow()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cyan)
    }
}
