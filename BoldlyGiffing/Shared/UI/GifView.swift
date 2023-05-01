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
    let isLarge: Bool
    @State private var progress: Double = 1
    
    internal init(gif: Gif, isLarge: Bool = false) {
        self.gif = gif
        self.isLarge = isLarge
    }
    
    var body: some View {
        AnimatedImage(url: isLarge ? gif.fullSizeURL : gif.thumbnailURL)
                .placeholder(content: {
                    Color(red: 0.26, green: 0.53, blue: 0.96).opacity( isLarge ? 0 : 0.8)
                })
                .transition(.fade)
                .resizable()
                .aspectRatio(1.2, contentMode: .fit)
                .opacity(progress)
                .cornerRadius(4)
                .scaledToFill()
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
