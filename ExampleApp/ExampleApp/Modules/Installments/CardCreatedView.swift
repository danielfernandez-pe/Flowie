//
//  CardCreatedView.swift
//  ExampleApp
//
//  Created by Daniel Fernandez on 31.03.2025.
//

import SwiftUI

struct CardCreatedView: View {
    let coordinator: CreateInstallmentsCardCoordinator
    
    var body: some View {
        VStack(spacing: 50) {
            Text("Your card was created successfully")
            Button("Finish") {
                coordinator.finishTapped()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow)
        .navigationBarBackButtonHidden()
    }
}
