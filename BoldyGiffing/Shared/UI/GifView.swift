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
    
    var body: some View {
        AnimatedImage(url: gif.fullSizeURL)
            .placeholder(content: {
                Color(red: 0.26, green: 0.53, blue: 0.96).opacity(0.8)
            })
            .transition(.fade)
            .resizable()
            .aspectRatio(1.2, contentMode: .fit)
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
