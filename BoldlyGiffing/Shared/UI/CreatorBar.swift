//
//  CreatorBar.swift
//  BoldlyGiffing
//
//  Created by Aaron Williams on 2023-03-16.
//  Copyright © 2023 SweetieApps. All rights reserved.
//

import SwiftUI

struct CreatorBar: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
    var body: some View {
        HStack(spacing: 4) {
            LCARSCapsule(.leftEndCap)
                .fill(LCARSColor.lightBlue)
                .frame(width: 35)
            Rectangle()
                .fill(LCARSColor.gold)
            
            Text("V\(version) Sweet Software")
                .font(.LCARS(size: 22))
                .foregroundColor(LCARSColor.orange)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            LCARSCapsule(.rightEndCap)
                .fill(LCARSColor.gold)
                .frame(width: 35)
        }
        .frame(maxHeight: 20)
    }
}

struct CreatorBar_Previews: PreviewProvider {
    static var previews: some View {
        CreatorBar()
            .background(Color.black)
    }
}
