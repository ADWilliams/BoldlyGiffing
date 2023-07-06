//
//  BoldlyGiffingMacApp.swift
//  BoldlyGiffingMac
//
//  Created by Aaron Williams on 2022-03-31.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import SwiftUI

@main
struct BoldlyGiffingMacApp: App {
    
    var body: some Scene {
        MenuBarExtra("Trek", image: "badge") {
            ContentView()
                .frame(width: 450, height: 600)
        }
        .menuBarExtraStyle(.window)
    }
}
