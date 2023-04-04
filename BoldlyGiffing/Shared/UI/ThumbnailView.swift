//
//  ThumbnailView.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-03-31.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import SwiftUI

struct ThumbnailView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var pressedGif: Gif?
    @GestureState private var longPressActive = false
    @State private var completedHold = false
    var gifs: [Gif]
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    private func holdGesture(_ gif: Gif) -> some Gesture {
        LongPressGesture(minimumDuration: 0.2).sequenced(before: DragGesture(minimumDistance: 0))
            .updating($longPressActive) { currentState, gestureState, transaction in
                switch currentState {
                case .second(true, nil):
                    print("no drag")
                    gestureState = true
                case .second(true, _):
                    print("drag")
                    gestureState = false
                    
                default:
                    break
                }
            }
            .onChanged({ value in
                switch value {
                case .first(_):
                    completedHold = false
                case .second(true, _):
                    print("long changed")
                    completedHold = false
                    withAnimation {
                        if longPressActive {
                            pressedGif = gif
                        }
                    }
                default:
                    break
                }
            })
            .onEnded({ value in
                withAnimation {
                    completedHold = true
                    pressedGif = nil
                }
            })
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ScrollViewReader { proxy in
                LazyVGrid(columns: columns, pinnedViews: .sectionHeaders) {
                    Section {
                        // Intentionally left blank
                    } footer: {
                        CharacterView(character: $viewModel.character)
                            .id("CharacterPicker")
                    }
                    .background {
                        CreatorBar()
                            .offset(y: -110)
                    }
                    Section {
                        ForEach(gifs) { gif in
                            Button {
                                if !completedHold {
                                    viewModel.gifTapped(gif)
                                }
                            } label: {
                                GifView(gif: gif)
                            }
                            .scaleEffect(pressedGif == gif ? 2 : 1)
                            .zIndex(pressedGif == gif ? 2 : 1)
                            .animation(.default, value: pressedGif)
                            .buttonStyle(.plain)
                            .overlay {
                                if viewModel.selectedGif == gif {
                                    let text = viewModel.downloadProgress < 100 ? "\(viewModel.downloadProgress)" : "Copied"
                                    Text(text)
                                        .font(.LCARS(size: 22))
                                        .shadow(radius: 1)
                                }
                            }
                            .onAppear {
                                if gif == gifs[gifs.count - 6] {
                                    viewModel.fetchThumbnailsWithOffset()
                                }
                            }
                            .simultaneousGesture(holdGesture(gif))
                        }
                    } header: {
                        ResultsHeader()
                            .onTapGesture {
                                withAnimation {
                                    proxy.scrollTo("CharacterPicker")
                                }
                            }
                            .frame(height: 20)
                            .background(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: .clear, location: 0),
                                        Gradient.Stop(color: .black, location: 0.3)
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .frame(height: 30)
                            )
                            .padding(.bottom, 8)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .clipped()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.black)
            
        )
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MainViewModel()
        ThumbnailView(gifs: viewModel.dataSet)
            .environmentObject(viewModel)
        
    }
}
