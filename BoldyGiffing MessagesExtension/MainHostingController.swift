//
//  MainHostingController.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2022-04-01.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import Foundation
import SwiftUI

class MainHostingController: UIHostingController<MainView> {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: MainView())
    }
}
