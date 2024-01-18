//
//  MenuBarView.swift
//  CryptoTrackerApp
//
//  Created by Александр Карадяур on 18.01.24.
//

import SwiftUI

struct MenuBarView: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "circle.fill")
                .foregroundColor(.green)
            VStack(alignment: .trailing, spacing: -2) {
                Text("Bitcoin")
                Text("$40.000")
            }
            .font(.caption)
        }
        .padding(EdgeInsets(
            top: 0, leading: 10, bottom: 0, trailing: 10
        ))
    }
}

#Preview {
    MenuBarView()
}
