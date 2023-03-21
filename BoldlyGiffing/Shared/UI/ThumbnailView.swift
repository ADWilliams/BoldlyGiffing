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
    
    var gifs: [Gif]
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
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
                                viewModel.gifTapped(gif)
                            } label: {
                                GifView(gif: gif)
                                    .draggable(gif)
                            }
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
