//
//  CharacterView.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-04-13.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import SwiftUI

struct ResultsHeader: View {
    @State private var isExiting = false

    var body: some View {
        HStack(spacing: 4) {

#if os(macOS)
            
            ExitButton(activated: $isExiting)
#else
    
            LCARSCapsule(.leftEndCap)
                .fill(LCARSColor.lightBlue)
                .frame(width: 35)
#endif
            
            Rectangle()
                .fill( isExiting ? LCARSColor.red : LCARSColor.gold)
            
            if !isExiting {
                Text("Query Results")
                    .font(.LCARS(size: 22))
                    .foregroundColor(LCARSColor.orange)
                    .textCase(.uppercase)
                    .offset(y: 1)
            }
            
            LCARSCapsule(.rightEndCap)
                .fill( isExiting ? LCARSColor.red : LCARSColor.gold)
                .frame(width: 35)
        }
    }
}

struct CharacterView: View {
    @State private var isAnimating: Bool = false
    @Binding var character: CharacterTag
    
    var body: some View {
        VStack{
            HStack(spacing: 4) {
                Button("Jean-Luc Picard", action: { character = .picard })
                    .buttonStyle(CharacterButton(capsuleType: .leftEndCap, color: LCARSColor.orange))
                
                
                Button("William Riker", action: { character = .riker})
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.lightBlue))
                
                Button("Data", action: { character = .data })
                    .buttonStyle(CharacterButton(capsuleType: .rightEndCap, color: LCARSColor.gold))
            }
            .frame(maxHeight: 65)
            
            
            HStack(spacing: 4) {
                Button("Geordi La Forge", action: { character = .laForge })
                    .buttonStyle(CharacterButton(capsuleType: .leftEndCap, color: LCARSColor.yellow))
                Button("Worf", action: { character = .worf })
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.almond))
                Button("Beverly Crusher", action: { character = .crusher})
                    .buttonStyle(CharacterButton(capsuleType: .rightEndCap, color: LCARSColor.lightBlue))
            }
            .frame(maxHeight: 65)
            
            HStack(spacing: 4) {
                Button("Deanna Troi", action: { character = .troi })
                    .buttonStyle(CharacterButton(capsuleType: .leftEndCap, color: LCARSColor.almond))
                Button("Miles O'Brien", action: { character = .obrien })
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.gold))
                Button("Wesley Crusher", action: { character = .wesley })
                    .buttonStyle(CharacterButton(capsuleType: .rightEndCap, color: LCARSColor.tomato))
            }
            .frame(maxHeight: 65)
            
            HStack(spacing: 4) {
                Button("Tasha Yar", action: { character = .yar })
                    .buttonStyle(CharacterButton(capsuleType: .leftEndCap, color: LCARSColor.almond))
                Button("Enterprise", action: { character = .enterprise})
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.lightBlue))
                Button("Q", action: { character = .q})
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.lightBlue))
                // Uncomment for 🥦
//                Button("Reginald Barclay", action: { character = .barclay})
//                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.lightBlue))
                Button("Random", action: { character = .all })
                    .buttonStyle(CharacterButton(capsuleType: .rightEndCap, color: LCARSColor.tomato))
            }
            .frame(maxHeight: 35)
        }
        .padding(.top, 30)
        .padding(.leading, 40)
        .overlay {
            VStack(alignment: .leading) {
                LCARSCurve(columnWidth: 35)
                    .fill(LCARSColor.gold)
                    .frame(height: 50)
                    .padding(.top, 8)
                Rectangle()
                    .fill(LCARSColor.lightBlue)
                    .frame(width: 35)
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

struct CharacterButton: ButtonStyle {
    let capsuleType: LCARSCapsule.CapsuleType
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .multilineTextAlignment(.trailing)
            .font(.LCARS(size: 22))
            .minimumScaleFactor(0.8)
            .foregroundColor(.black)
            .textCase(.uppercase)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .frame(maxWidth:.infinity, maxHeight: .infinity)
            .background(
                LCARSCapsule(capsuleType)
                    .fill(color)
            )
            .opacity(configuration.isPressed ? 0.4 : 1)
    }
}

struct BindingCharacterView_Previews: View {
    @State var tag = CharacterTag.all

    var body: some View {
        CharacterView(character: $tag)
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        BindingCharacterView_Previews()
            .padding()
    }
}
