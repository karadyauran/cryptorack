//
//  PopoverView.swift
//  CryptoTrackerApp
//
//  Created by Александр Карадяур on 18.01.24.
//

import SwiftUI

struct PopoverView: View {
    
    @ObservedObject var viewModel: PopoverCoinViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text(viewModel.title).font(.largeTitle)
                Text(viewModel.subtitle).font(.title.bold())
            }
            
            Divider()
            
            Picker("Select Coin", selection:
                $viewModel.selectedCoinType) {
                ForEach(viewModel.coinTypes) { type in
                    HStack {
                        Text(type.description).font(.headline)
                        Spacer()
                        Text(viewModel.valueText(for: type))
                            .frame(alignment: .trailing)
                            .font(.body)
                        Link(destination: type.url) {
                            Image(systemName: "safari")
                        }
                    }
                    .tag(type)
                }
            }
                .pickerStyle(RadioGroupPickerStyle())
                .labelsHidden()
            
            Divider()
            
            Button("Quit") {
                NSApp.terminate(self)
            }
        }
        .onChange(of: viewModel.selectedCoinType) { _ in
            viewModel.updateView()
        }
        .onAppear {
            viewModel.subscripeToService()
        }
    }
}

#Preview {
    PopoverView(viewModel: .init(title: "Bitcoin", subtitle: "$40.000"))
}
