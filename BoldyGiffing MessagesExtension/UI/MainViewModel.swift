//
//  MainViewModel.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2022-04-01.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import Foundation

enum CharacterTag: String {
    case Crusher = "beverly crusher"
    case Data = "data"
    case LaForge = "geordi la forge"
    case Picard = "jean luc picard"
    case Riker = "william riker"
    case Troi = "deanna troi"
    case Yar = "tasha yar"
    case Worf = "worf"
    case All = ""
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
    @Published private(set) var character: CharacterTag = .All
    
    @objc func loadCharacter(notification: Notification) {
        guard
        let userInfo = notification.userInfo,
        let characterTag = userInfo["characterTag"] as? CharacterTag
        else { return }

        character = characterTag
        dataSet.removeAll()
        fetchThumbnails()
    }
    
    func gifTapped(key: String) {
        let userInfo = ["key" : key]
        NotificationCenter.default.post(name: Notification.Name("insertGif"), object: nil, userInfo: userInfo)
    }
    
    func fetchInfo() {
        guard let url = URL(string: baseURL + "info?api_key=\(apiKey)") else { return }
        
        dataRequest = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.dataRequest = nil
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as! [String: Any],
                let response = json["response"] as? [String: Any],
                let blog = response["blog"] as? [String: Any],
                let postCount = blog["posts"] as? Int
            else {
                print(error)
                return
            }
            
            self?.postCount = postCount
            self?.fetchRandomThumbnails()
        }
        dataRequest?.resume()
    }
    
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
        //        if let characterTag = character.rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
        //            tagPath = characterTag.isEmpty ? characterTag : "&tag=\(characterTag)"
        //        }
        
        guard
            let url = URL(string: baseURL + "posts/photo?limit=21&offset=\(offset)\(tagPath)&api_key=\(apiKey)"),
            dataRequest == nil
        else { return }
        
        dataRequest = URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            self?.dataRequest = nil
            
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as! [String: Any],
                let response = json["response"] as? [String: Any],
                let postsJson = response["posts"] as? [[String: Any]]
            else {
                print(error)
                return
            }
            
            let posts = postsJson.compactMap(Post.init)
            var newItems: [Gif] = []
            posts.forEach { newItems.append(contentsOf: $0.gifs) }
            DispatchQueue.main.async {
                self?.dataSet.append(contentsOf: newItems)
                self?.offset = offset
                self?.offset += 21
            }
        })
        dataRequest?.resume()
    }
    
    func fetchThumbnailsWithOffset() {
        fetchThumbnails(offset: offset)
    }
}
