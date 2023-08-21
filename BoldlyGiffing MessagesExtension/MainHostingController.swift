//
//  MainHostingController.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2022-04-01.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import Foundation
import SwiftUI
import ComposableArchitecture

class MainHostingController: UIHostingController<AppView> {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(
            coder: aDecoder,
            rootView: AppView(
                store: Store(
                    initialState: .init(),
                    reducer: {
                        AppReducer()
                    }
                )
            )
        )
    }
}
