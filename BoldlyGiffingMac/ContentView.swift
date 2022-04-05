//
//  ContentView.swift
//  BoldlyGiffingMac
//
//  Created by Aaron Williams on 2022-03-31.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = MainViewModel()
    var body: some View {
        ThumbnailView(gifs: viewModel.dataSet)
            .onAppear {
                viewModel.fetchInfo()
            }
            .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
