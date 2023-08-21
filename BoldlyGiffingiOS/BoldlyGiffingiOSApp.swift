//
//  BoldlyGiffingiOSApp.swift
//  BoldlyGiffingiOS
//
//  Created by Aaron Williams on 2023-03-07.
//  Copyright © 2023 Sweet Software. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

@main
struct BoldlyGiffingiOSApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: .init(),
                    reducer: {
                        AppReducer()
                    }
                )
            )
        }
    }
}
