//
//  AppDelegate.swift
//  BoldlyGiffingMac
//
//  Created by Aaron Williams on 2022-04-11.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menuItem = NSMenuItem()
        let mainView = NSHostingView(rootView: ContentView())
        mainView.frame = NSRect(origin: .zero, size: CGSize(width: 400, height: 600))
        menuItem.view = mainView
        let menu = NSMenu()
        menu.addItem(menuItem)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        statusItem?.menu = menu
        let image = NSImage(named: "badge")
        image?.size = NSSize(width: 24, height: 24)
        image?.isTemplate = true
        statusItem?.button?.image = image
    }
}
