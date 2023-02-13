//
//  BottomBar.swift
//  BoldlyGiffingMac
//
//  Created by Aaron Williams on 2023-02-07.
//  Copyright © 2023 SweetieApps. All rights reserved.
//

import SwiftUI


struct ExitButton: View {
    @Binding var activated: Bool
    
    @State private var isExpanded = false
    @State private var iconVisible = true
    
    init(activated: Binding<Bool>,
         timer: Timer? = nil,
         iconAnimationDuration: Double = 0.2
    ) {
        self._activated = activated
        self.timer = timer
        self.iconAnimationDuration = iconAnimationDuration
    }
    
    private var timer: Timer?
    private var iconAnimationDuration = 0.2
    
    var body: some View {
        Button {
            if isExpanded {
                NSApplication.shared.terminate(self)
            } else {
                withAnimation(.linear(duration: iconAnimationDuration)) {
                    iconVisible = false
                    activated = true
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
                            activated = false
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
                }
            }
            .clipShape(LCARSCapsule(.leftEndCap))
            .overlay {
                if iconVisible {
                    Image(systemName: "xmark")
                        .foregroundStyle(.black)
                        .imageScale(.large)
                        .fontWeight(.semibold)
                        .offset(x: 2)
                }
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .buttonStyle(.plain)
        .frame(height: 20)
        .background {
            RoundedRectangle(cornerRadius: 11)
                .fill(.black)
        }
    }
}

struct BindingExitButton_Previews: View {
    @State var activated = false
    var body: some View {
            ExitButton(activated: $activated)
    }
}

struct ExitButton_Previews: PreviewProvider {
    static var previews: some View {
        BindingExitButton_Previews()
    }
}
