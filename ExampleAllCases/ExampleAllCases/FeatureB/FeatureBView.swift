//
//  FeatureBView.swift
//  ExampleAllCases
//
//  Created by Daniel Fernandez on 01.04.2025.
//

import SwiftUI

struct FeatureBView: View {
    let viewModel: FeatureBViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Hello from Feature B")
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
        .navigationTitle("Feature B")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    print("Leading button tapped")
                }) {
                    Text("Dismiss")
                }
            }
        }
//        .navigationBarBackButtonHidden(true)
    }
}
