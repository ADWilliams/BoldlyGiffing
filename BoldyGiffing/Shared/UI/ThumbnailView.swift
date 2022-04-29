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
            LazyVGrid(columns: columns) {
                Section {
                    ForEach(gifs) { gif in
                        GifView(gif: gif)
                            .onDrag({
                                if let provider = NSItemProvider(contentsOf: viewModel.pathFor(gif: gif)) {
                                    return provider
                                } else {
                                    return NSItemProvider(item: nil, typeIdentifier: "com.compuserve.gif")
                                }
                            })
                            .onAppear {
                                if gif == gifs[gifs.count - 6] {
                                    viewModel.fetchThumbnailsWithOffset()
                                }
                                
                            }
                            .onTapGesture {
                                viewModel.gifTapped(key: gif.fullSizeURL.absoluteString)
                            }

                    }
                } header: {
                    CharacterView(character: $viewModel.character)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black)
                        )
                        .padding(.bottom, 8)
                }
//                .animation(.easeIn, value: gifs)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.black)
            
        )
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(gifs: Gif.mockArray)
        
    }
}
