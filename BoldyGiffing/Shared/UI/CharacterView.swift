//
//  CharacterView.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-04-13.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import SwiftUI

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
                Button("Tasha Yar", action: { character = .yar })
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.gold))
                Button("Random", action: { character = .all })
                    .buttonStyle(CharacterButton(capsuleType: .rightEndCap, color: LCARSColor.tomato))
            }
            .frame(maxHeight: 65)
            //                    .animation(.linear(duration: 0.1).delay(0.8).repeatForever(autoreverses: true), value: isAnimating)
        }
        .padding(.vertical, 30)
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
                HStack(spacing: 4) {
                    LCARSCapsule(.leftEndCap)
                        .fill(LCARSColor.lightBlue)
                        .frame(width: 35)
                    Rectangle()
                        .fill(LCARSColor.gold)
                    
                    Text("Query Results")
                        .font(.LCARS(size: 22))
                        .foregroundColor(LCARSColor.orange)
                        .textCase(.uppercase)
                    
                    LCARSCapsule(.rightEndCap)
                        .fill(LCARSColor.lightBlue)
                        .frame(width: 35)
                }
                .frame(height: 20)
            }
        }
        
        .padding(4)
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
            .contentShape(Rectangle())
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
