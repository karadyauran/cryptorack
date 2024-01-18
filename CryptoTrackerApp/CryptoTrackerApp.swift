//
//  CryptoTrackerAppApp.swift
//  CryptoTrackerApp
//
//  Created by Александр Карадяур on 18.01.24.
//

import SwiftUI

@main
struct CryptoTrackerApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView().frame(width: 0, height: 0).background(WindowDisabler())
        }
    }
}
