//
//  BottomBar.swift
//  BoldlyGiffingMac
//
//  Created by Aaron Williams on 2023-02-07.
//  Copyright © 2023 SweetieApps. All rights reserved.
//

import SwiftUI

struct BottomBar: View {
    var body: some View {
        HStack(spacing: 4) {
            LCARSCapsule(.leftEndCap)
                .fill(LCARSColor.lightBlue)
                .frame(width: 35)
            
            Button {
                NSApplication.shared.terminate(self)
            } label: {
                Text("Exit Program")
                    .font(.LCARS(size: 20))
                    .foregroundColor(LCARSColor.red)
                    .textCase(.uppercase)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(LCARSColor.gold)
            
            LCARSCapsule(.rightEndCap)
                .fill(LCARSColor.lightBlue)
                .frame(width: 35)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black)
        )
        .frame(height: 20)
    }
}

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomBar()
    }
}
