//
//  GifView.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-03-31.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct GifView: View {
    let gif: Gif
    let isLarge: Bool
    
    internal init(gif: Gif, isLarge: Bool = false) {
        self.gif = gif
        self.isLarge = isLarge
    }
    
    var body: some View {
        AnimatedImage(url: isLarge ? gif.fullSizeURL : gif.thumbnailURL)
            .transition(.fade)
            .resizable()
            .aspectRatio(1.2, contentMode: .fit)
            .scaledToFill()
            .background {
                Color(red: 0.26, green: 0.53, blue: 0.96)
                    .opacity( isLarge ? 0 : 0.6)
            }
            .cornerRadius(isLarge ? 16 : 4)
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
