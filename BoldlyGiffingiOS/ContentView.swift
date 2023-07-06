//
//  ContentView.swift
//  BoldlyGiffingiOS
//
//  Created by Aaron Williams on 2023-03-07.
//  Copyright © 2023 Sweet Software. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        ThumbnailView(gifs: viewModel.dataSet)
            .padding(.horizontal, 8)
            .onAppear {
                viewModel.fetchInfo()
            }
            .environmentObject(viewModel)
            .background(
                Color.black
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
