//
//  CreateInstallmentsCardView.swift
//  ExampleApp
//
//  Created by Daniel Fernandez on 31.03.2025.
//

import SwiftUI

struct CreateInstallmentsCardView: View {
    let coordinator: CreateInstallmentsCardCoordinator
    
    var body: some View {
        VStack(spacing: 50) {
            Text("We are in installments module. Let's create your card")
            
            Button("Create card") {
                coordinator.showCardCreated()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brown)
    }
}
