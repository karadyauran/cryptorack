//
//  WindowDisabler.swift
//  CryptoTrackerApp
//
//  Created by Александр Карадяур on 18.01.24.
//

import SwiftUI

struct WindowDisabler: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            NSApp.windows.first?.close()
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
