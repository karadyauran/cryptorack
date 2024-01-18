//
//  PopoverView.swift
//  CryptoTrackerApp
//
//  Created by Александр Карадяур on 18.01.24.
//

import SwiftUI

struct PopoverView: View {
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text("Bitcoin").font(.largeTitle)
                Text("$40.000").font(.title.bold())
            }
            
            Divider()
            
            Button("Quit") {
                NSApp.terminate(self)
            }
        }
    }
}

#Preview {
    PopoverView()
}
