//
//  GifView.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-03-31.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct GifView: View {
    let gif: Gif
    @State private var progress: Double = 1
    
    var body: some View {
            AnimatedImage(url: gif.thumbnailURL)
                .placeholder(content: {
                    Color(red: 0.26, green: 0.53, blue: 0.96).opacity(0.8)
                })
                .transition(.fade)
                .resizable()
                .aspectRatio(1.2, contentMode: .fit)
                .opacity(progress)
                .cornerRadius(4)
                .scaledToFill()
                .onTapGesture {
                    loadFullSize()
                }
    }
    
    private func loadFullSize() {
        SDWebImageManager.shared.loadImage(with: gif.fullSizeURL,
                                           options: .waitStoreCache) { recieved, size, _ in
            withAnimation {
                progress = 1.0 - Double(recieved / size)
                print(progress)
            }
        } completed: { _, _, error, _, _, _ in
            if let error = error {
                print(error)
            } else {
                let userInfo = ["key" : gif.fullSizeURL.absoluteString]
                NotificationCenter.default.post(name: Notification.Name("insertGif"), object: nil, userInfo: userInfo)
            }
            progress = 1
        }
    }
}

struct GifView_Previews: PreviewProvider {
    static var previews: some View {
        GifView(
            gif: Gif.mock
        )
        .previewLayout(.sizeThatFits)
    }
}
