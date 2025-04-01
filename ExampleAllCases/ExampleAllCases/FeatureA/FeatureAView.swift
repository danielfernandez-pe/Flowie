//
//  FeatureAView.swift
//  ExampleAllCases
//
//  Created by Daniel Fernandez on 01.04.2025.
//

import SwiftUI

struct FeatureAView: View{
    let viewModel: FeatureAViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Hello from Feature A")
                .foregroundStyle(.black)
            
            Button("Push in the same flow") {
                viewModel.pushSameFlow()
            }
            
            Button("Push a new coordinator/flow") {
                viewModel.pushNewFlow()
            }
            
            Button("Present a controller") {
                viewModel.presentSameFlow()
            }
            
            Button("Present a new coordinator/flow") {
                viewModel.presentNewFlow()
            }
            
            Button("Close") {
                viewModel.close()
            }
            
            Button("Finish coordinator") {
                viewModel.finishCoordinator()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .navigationTitle("Feature A")
    }
}
