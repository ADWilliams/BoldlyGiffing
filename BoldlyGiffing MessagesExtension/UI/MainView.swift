//
//  MainView.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-04-01.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        ThumbnailView(gifs: viewModel.dataSet)
            .background(.black)
            .onAppear {
                viewModel.fetchInfo()
            }
            .environmentObject(viewModel)
            .animation(.easeIn, value: viewModel.dataSet)
    }
}
