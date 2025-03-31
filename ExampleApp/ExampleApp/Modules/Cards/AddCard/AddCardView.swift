//
//  AddCardView.swift
//  ExampleApp
//
//  Created by Daniel Fernandez Yopla on 28.03.2025.
//

import SwiftUI

struct AddCardView: View {
    let coordinator: AddCardCoordinator
    
    var body: some View {
        VStack(spacing: 50) {
            Text("Hello from AddCardView")
            
            Button("Create an installments card") {
                coordinator.openCreateInstallmentsCard()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.orange)
    }
}
