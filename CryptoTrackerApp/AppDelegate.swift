//
//  AppDelegate.swift
//  CryptoTrackerApp
//
//  Created by Александр Карадяур on 18.01.24.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow?
    var statusItem: NSStatusItem!
    let popover = NSPopover()
    let coinCapService = CoinCapPriceService()
    var menuBarCoinViewModel: MenuBarCoinViewModel!
    var popoverCoinViewModel: PopoverCoinViewModel!
    
    private lazy var contentView: NSView? = {
        let view = (statusItem.value(forKey: "window") as? NSWindow)?.contentView
        return view
    }()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupCoinCapService()
        setupMenuBar()
        setupPopover()
    }
    
    func setupCoinCapService() {
        coinCapService.connect()
        coinCapService.startMonitorNetworkConnectivity()
    }
}

// MARK: - MENU BAR

extension AppDelegate {
    func setupMenuBar() {
        menuBarCoinViewModel = MenuBarCoinViewModel(service: coinCapService)
        statusItem = NSStatusBar.system.statusItem(withLength: 72)
        guard let contentView = self.contentView, let menuButton = statusItem.button else {return}
        
        let hostingView = NSHostingView(rootView: MenuBarView(viewModel: menuBarCoinViewModel))
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ])
        
        menuButton.action = #selector(menuButtonClicked)
    }
    
    @objc func menuButtonClicked() {
        if popover.isShown {
            popover.performClose(nil)
            return
        }
        
        guard let menuButton = statusItem.button else {return}
        let positioningView = NSView(frame: menuButton.bounds)
        positioningView.identifier = NSUserInterfaceItemIdentifier("positioningView")
        menuButton.addSubview(positioningView)
        
        popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .maxY)
        menuButton.bounds = menuButton.bounds.offsetBy(dx: 0, dy: menuButton.bounds.height)
        popover.contentViewController?.view.window?.makeKey()
    }
}

// MARK: - POPOVER

extension AppDelegate: NSPopoverDelegate {
    func setupPopover() {
        popoverCoinViewModel = .init(service: coinCapService)
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = .init(width: 240, height: 280)
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(
            rootView: PopoverView(viewModel: popoverCoinViewModel).frame(maxWidth: .infinity, maxHeight: .infinity).padding()
        )
        popover.delegate = self
    }
    
    func popoverDidClose(_ notification: Notification) {
        let positionView = statusItem.button?.subviews.first {
            $0.identifier == NSUserInterfaceItemIdentifier("positionView")
        }
        positionView?.removeFromSuperview()
    }
}
