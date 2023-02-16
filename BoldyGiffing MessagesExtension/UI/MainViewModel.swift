//
//  MainViewModel.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2022-04-01.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import Foundation
import SDWebImage

enum CharacterTag: String {
    case crusher = "beverly crusher"
    case data = "data"
    case laForge = "geordi la forge"
    case picard = "jean luc picard"
    case riker = "william riker"
    case troi = "deanna troi"
    case yar = "tasha yar"
    case worf = "worf"
    case wesley = "wesley crusher"
    case obrien = "miles o'brien"
    case enterprise = "enterprise d"
    case q = "q"
    case barclay = "reginald barclay"
    case all = ""
}

class MainViewModel: ObservableObject {
    
    private let baseURL = "https://api.tumblr.com/v2/blog/boldlygiffing.tumblr.com/"
    private let apiKey = "GXeFiXAi3Ho0HXbCX9Arm4dlxMuuPG4dIjhj7TVfCsUMCVCLRT"
    
    private var dataRequest: URLSessionDataTask?
    private var postCount: Int = 0
    private var offset: Int = 0 {
        didSet {
            self.offset = offset >= self.postCount ? 0 : self.offset
        }
    }
    
    @Published private(set) var dataSet: [Gif] = []
    @Published var character: CharacterTag = .all {
        didSet {
            loadCharacter()
        }
    }
    
    @Published var gifCopied: Gif?
    
    func loadCharacter() {
        dataSet.removeAll()
        if character == .all {
            fetchRandomThumbnails()
        } else {
            fetchThumbnails()
        }
    }
    
    func gifTapped(_ gif: Gif) {
        loadFullSize(gif: gif)
    }
    
    func pathFor(gif: Gif) -> URL {
        let path = SDImageCache.shared.cachePath(forKey: gif.fullSizeURL.absoluteString)
        return URL(fileURLWithPath: path ?? "")
    }
    
    func fetchInfo() {
        guard let url = URL(string: baseURL + "info?api_key=\(apiKey)") else { return }
        
        let loader = ModelLoader<InfoResponse>()
        
        Task {
            let result = await loader.loadModel(url: url)
            switch result {
            case let .success(response):
                postCount = response.postCount
                fetchRandomThumbnails()
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func loadFullSize(gif: Gif) {
        SDWebImageManager.shared.loadImage(with: gif.fullSizeURL,
                                           options: .waitStoreCache) { recieved, size, _ in
        } completed: { _, _, error, _, _, _ in
            if let error = error {
                print(error)
            } else {
#if os(macOS)
                self.copyGif(gif: gif)
#else
                let userInfo = ["key" : gif.fullSizeURL.absoluteString]
                NotificationCenter.default.post(name: Notification.Name("insertGif"), object: nil, userInfo: userInfo)
#endif
            }
        }
    }
#if os(macOS)
    private func copyGif(gif: Gif) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.fileContents], owner: nil)
        do {
            if let path = SDImageCache.shared.cachePath(forKey: gif.fullSizeURL.absoluteString) {
                let url = URL(fileURLWithPath: path)
                
                let data = try Data(contentsOf: url)
                if  pasteboard.setData(data, forType: NSPasteboard.PasteboardType(rawValue: "com.compuserve.gif")) {
                    gifCopied = gif
                    print("✅ gif copied")
                }
            }
        }
        catch {
            print(error)
        }
    }
#endif
    
    func fetchRandomThumbnails() {
        let postCount = self.postCount - (self.postCount > 21 ? 21 : 0)
#if os(iOS)
        let randomOffset = Int.random(postCount)
#elseif os(macOS)
        let randomOffset = Int.random(in: 0...postCount)
#endif
        offset = randomOffset < 0 ? 0 : randomOffset
        fetchThumbnails(offset: self.offset)
    }
    
    func fetchThumbnails(limit: Int = 21, offset: Int = 0) {
        var tagPath: String = ""
        if let characterTag = character.rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            tagPath = characterTag.isEmpty ? characterTag : "&tag=\(characterTag)"
        }
        
        guard
            let url = URL(string: baseURL + "posts/photo?limit=21&offset=\(offset)\(tagPath)&api_key=\(apiKey)"),
            dataRequest == nil
        else { return }
        
        let loader = ModelLoader<PostResponse>()
        
        Task {
            let result = await loader.loadModel(url: url)
            switch result {
            case let .success(response):
                DispatchQueue.main.async {
                    var newItems: [Gif] = []
                    response.posts.forEach { newItems.append(contentsOf: $0.gifs) }
                    
                    self.dataSet.append(contentsOf: newItems)
                    self.offset = offset
                    self.offset += 21
                }
                
            case let .failure(error):
                print(error)
            }
            
        }
    }
    
    func fetchThumbnailsWithOffset() {
        fetchThumbnails(offset: offset)
    }
}
