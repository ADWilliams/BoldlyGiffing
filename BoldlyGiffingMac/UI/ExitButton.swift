//
//  BottomBar.swift
//  BoldlyGiffingMac
//
//  Created by Aaron Williams on 2023-02-07.
//  Copyright © 2023 SweetieApps. All rights reserved.
//

import SwiftUI


struct ExitButton: View {
    @State private var isExpanded = false
    @State private var iconVisible = true
    
    private var timer: Timer?
    private var iconAnimationDuration = 0.2
    
    var body: some View {
        Button {
            if isExpanded {
                NSApplication.shared.terminate(self)
            } else {
                withAnimation(.linear(duration: iconAnimationDuration)) {
                    iconVisible = false
                }
                
                withAnimation(.easeOut.delay(iconAnimationDuration)) {
                    isExpanded = true
                    
                    Timer.scheduledTimer(
                        withTimeInterval: 2,
                        repeats: false
                    ) { timer in
                        withAnimation(.easeOut(duration: 0.2)) {
                            isExpanded = false
                        }
                        withAnimation(.default.delay(0.2)) {
                            iconVisible = true
                        }
                        timer.invalidate()
                    }
                }
            }
        } label: {
            HStack(spacing: 0) {
                LCARSCapsule(.leftEndCap)
                    .fill(isExpanded ? LCARSColor.red : LCARSColor.lightBlue)
                    .frame(width: 35)
                
                if isExpanded {
                    Text("End Program")
                        .font(.LCARS(size: 22))
                        .foregroundColor(LCARSColor.red)
                        .textCase(.uppercase)
                        .offset(y: 2)
                        .padding(.horizontal, 4)
                        .transition(.move(edge: .leading))
                        .zIndex(-1)
                        .clipped()
                }
 
                LCARSCapsule(.rightEndCap)
                    .fill(isExpanded ? LCARSColor.red : LCARSColor.lightBlue)
                    .frame(width: 35)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if iconVisible {
                    Image(systemName: "xmark")
                        .foregroundStyle(.black)
                        .imageScale(.large)
                        .fontWeight(.semibold)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(height: 20)
        .background {
            RoundedRectangle(cornerRadius: 11)
                .fill(.black)
        }
    }
}

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        ExitButton()
    }
}
