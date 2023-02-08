//
//  ContentView.swift
//  BoldlyGiffingMac
//
//  Created by Aaron Williams on 2022-03-31.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import SwiftUI
import SDWebImage

struct ContentView: View {
    @ObservedObject var viewModel = MainViewModel()
    var body: some View {
        ThumbnailView(gifs: viewModel.dataSet)
            .padding(.horizontal, 8)
            .onAppear {
                viewModel.fetchInfo()
            }
            .environmentObject(viewModel)
            .onAppear {
                setupNotificationHandling()
            }
            .background(
                Color.black
            )
            .overlay(alignment: .bottom) {
                BottomBar()
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .black.opacity(0.01), location: 0),
                                Gradient.Stop(color: .black, location: 0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 30)
                    )
                    .padding(.horizontal, 8)
            }
    }
    
    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(forName: Notification.Name("insertGif"), object: nil, queue: nil) { notification in
            if let key = notification.userInfo?["key"] as? String,
               let path = SDImageCache.shared.cachePath(forKey: key) {
                let url = URL(fileURLWithPath: path)
                copyGif(url: url)
            }
        }
    }
    
    private func copyGif(url: URL) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.fileContents], owner: nil)
        do {
            let data = try Data(contentsOf: url)
            pasteboard.setData(data, forType: NSPasteboard.PasteboardType(rawValue: "com.compuserve.gif"))
        }
        catch {
            print(error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
