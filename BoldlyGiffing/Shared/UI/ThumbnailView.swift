//
//  ThumbnailView.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-03-31.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import SwiftUI

struct ThumbnailView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @Namespace var thumbnailNamespace
    @State private var pressedGif: Gif?
    @GestureState private var longPressActive = false
    @State private var completedHold = false
    var gifs: [Gif]
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    private func holdGesture(_ gif: Gif) -> some Gesture {
        LongPressGesture(minimumDuration: 0.1, maximumDistance: 10).simultaneously(with: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .updating($longPressActive) { currentState, gestureState, transaction in
                gestureState = currentState.first == true
            }
            .onChanged { value in
                print("onchange \(value)")
                completedHold = value.first == true
                withAnimation {
                    pressedGif = longPressActive ? gif : nil
                }
            }
            .onEnded({ value in
                withAnimation(.interactiveSpring()) {
                    print("hold ended, long press \(longPressActive)")
                    completedHold = true
                    withAnimation {
                        pressedGif = nil
                    }
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
                            .offset(y: -115)
                    }
                    Section {
                        ForEach(gifs) { gif in
                            GifView(gif: gif)
                                .matchedGeometryEffect(id: longPressActive ? gif.id : "", in: thumbnailNamespace, isSource: false)
                                .zIndex(pressedGif == gif ? 2 : 0)
                                .onTapGesture {
                                    viewModel.gifTapped(gif)
                                }
                                .gesture(holdGesture(gif))
                                .animation( .interactiveSpring(), value: longPressActive)
                                .overlay {
                                    if viewModel.selectedGif == gif {
                                        let text = viewModel.downloadProgress < 100 ? "\(viewModel.downloadProgress)" : "Copied"
                                        Text(text)
                                            .foregroundColor(.white)
                                            .font(.LCARS(size: 22))
                                            .shadow(radius: 1)
                                    }
                                }
                                .onAppear {
                                    if gif == gifs[gifs.count - 6] {
                                        viewModel.fetchThumbnailsWithOffset()
                                    }
                                }
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
                    .padding(.top, 4)
                }
                .padding(.bottom, 30)
            }
        }
        .modifier(VersionAwareBounce())
        .clipped()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.black)
            
        )
        .overlay {
            GifView(gif: pressedGif ?? Gif.empty, isLarge: true)
                .opacity( longPressActive ? 1 : 0)
                .matchedGeometryEffect(id: pressedGif?.id, in: thumbnailNamespace)
                .animation( .interactiveSpring().delay(0.3), value: longPressActive)
                .frame(height: 200)
                .padding(16)
            
        }
    }
}

fileprivate struct VersionAwareBounce: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 13.3, iOS 16.4, *) {
            content.scrollBounceBehavior(.always, axes: .vertical)
        }
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MainViewModel()
        ThumbnailView(gifs: viewModel.dataSet)
            .environmentObject(viewModel)
        
    }
}
