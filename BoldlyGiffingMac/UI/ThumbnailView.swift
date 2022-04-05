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
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(gifs) { gif in
                    GifView(gif: gif)
                        .onAppear {
                            if gif == gifs.last {
                                viewModel.fetchThumbnailsWithOffset()
                            }
                        }
                        .onTapGesture {
                            viewModel.gifTapped(key: gif.fullSizeURL.absoluteString)
                        }
                }
            }
            .animation(.easeIn, value: gifs)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(gifs: Gif.mockArray)
            
    }
}
