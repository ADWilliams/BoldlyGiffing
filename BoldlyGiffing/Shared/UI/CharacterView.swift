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
    @State private var introVisible = true

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                
#if os(macOS)
                
                ExitButton(activated: $isExiting)
                    .onChange(of: isExiting) { newValue in
                        introVisible = false
                    }
#else
                
                LCARSCapsule(.leftEndCap)
                    .fill(LCARSColor.lightBlue)
                    .frame(width: 35)
#endif
                
                Rectangle()
                    .fill( isExiting ? LCARSColor.red : LCARSColor.gold)
                
                if !isExiting {
                    if introVisible {
                        HStack {
                            Text("Tap to copy")
                                .font(.LCARS(size: 22))
                                .textCase(.uppercase)
                                .foregroundColor(LCARSColor.orange)
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .fixedSize()
                            
                            Text("hold to enlarge")
                                .font(.LCARS(size: 22))
                                .textCase(.uppercase)
                                .foregroundColor(LCARSColor.orange)
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .fixedSize()
                                .onAppear {
                                    Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
                                        withAnimation {
                                            self.introVisible = false
                                        }
                                        timer.invalidate()
                                    }
                                }
                        }
                        .transition(.move(edge: .leading))
                    } else {
                        Text("Query Results")
                            .font(.LCARS(size: 22))
                            .foregroundColor(LCARSColor.orange)
                            .textCase(.uppercase)
                            .offset(y: 1)
                            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    }
                }
                
                LCARSCapsule(.rightEndCap)
                    .fill( isExiting ? LCARSColor.red : LCARSColor.gold)
                    .frame(width: 35)
            }
        }
    }
}

struct CharacterView: View {
    @State private var isAnimating: Bool = false
    @Binding var character: CharacterTag
    
    private func buttonTapped(selected: CharacterTag) {
        character = selected
#if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
#endif
    }
    
    var body: some View {
        VStack{
            HStack(spacing: 4) {
                Button("Jean-Luc Picard", action: { buttonTapped(selected: .picard) })
                    .buttonStyle(CharacterButton(capsuleType: .leftEndCap, color: LCARSColor.orange))
                
                Button("William Riker", action: { buttonTapped(selected: .riker) })
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.lightBlue))
                
                Button("Data", action: { buttonTapped(selected: .data) })
                    .buttonStyle(CharacterButton(capsuleType: .rightEndCap, color: LCARSColor.gold))
            }
            .frame(maxHeight: 40)
            
            HStack(spacing: 4) {
                Button("Geordi La Forge", action: { buttonTapped(selected: .laForge) })
                    .buttonStyle(CharacterButton(capsuleType: .leftEndCap, color: LCARSColor.yellow))
                Button("Worf", action: { buttonTapped(selected: .worf) })
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.almond))
                Button("Beverly Crusher", action: { buttonTapped(selected: .crusher) })
                    .buttonStyle(CharacterButton(capsuleType: .rightEndCap, color: LCARSColor.lightBlue))
            }
            .frame(maxHeight: 40)
            
            HStack(spacing: 4) {
                Button("Deanna Troi", action: { buttonTapped(selected: .troi) })
                    .buttonStyle(CharacterButton(capsuleType: .leftEndCap, color: LCARSColor.almond))
                Button("Miles O'Brien", action: { buttonTapped(selected: .obrien) })
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.gold))
                Button("Wesley Crusher", action: { buttonTapped(selected: .wesley) })
                    .buttonStyle(CharacterButton(capsuleType: .rightEndCap, color: LCARSColor.tomato))
            }
            .frame(maxHeight: 40)
            
            HStack(spacing: 4) {
                Button("Tasha Yar", action: { buttonTapped(selected: .yar) })
                    .buttonStyle(CharacterButton(capsuleType: .leftEndCap, color: LCARSColor.almond))
                Button("Enterprise", action: { buttonTapped(selected: .enterprise) })
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.lightBlue))
                Button("Q", action: { buttonTapped(selected: .q) })
                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.lightBlue))
                // Uncomment for 🥦
//                Button("Reginald Barclay", action: { character = .barclay})
//                    .buttonStyle(CharacterButton(capsuleType: .none, color: LCARSColor.lightBlue))
                Button("Random", action: { buttonTapped(selected: .all) })
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
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .accessibilityShowsLargeContentViewer()
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
