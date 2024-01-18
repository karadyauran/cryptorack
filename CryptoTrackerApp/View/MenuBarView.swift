//
//  MenuBarView.swift
//  CryptoTrackerApp
//
//  Created by Александр Карадяур on 18.01.24.
//

import SwiftUI

struct MenuBarView: View {
    
    @ObservedObject var viewModel: MenuBarCoinViewModel
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "circle.fill")
                .foregroundColor(viewModel.color)
            VStack(alignment: .center, spacing: -3) {
                Text(viewModel.name)
                Text(viewModel.value)
            }
            .font(.caption)
        }
        .onChange(of: viewModel.selectedCoinType) { _ in
            viewModel.updateView()
        }
        .onAppear {
            viewModel.subscribeToService()
        }
    }
}

#Preview {
    MenuBarView(viewModel: .init(name: "Bitcoin", value: "$40.000", color: .green))
}
