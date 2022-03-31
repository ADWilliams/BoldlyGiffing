//
//  CollectionViewDataSource.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2017-06-30.
//  Copyright © 2017 SweetieApps. All rights reserved.
//

import UIKit
import Kingfisher

struct Post {
    let gifs: [Gif]

    init? (json: [String: Any]) {
        guard
        let tags = json["tags"] as? [String],
        let photos = json["photos"] as? [[String: Any]]
        else { return nil}

        gifs = photos.compactMap { Gif(json: $0, tags: tags) }
    }
}

struct Gif: Equatable  {
    static func ==(lhs: Gif, rhs: Gif) -> Bool {
        return lhs.fullSizeURL == rhs.fullSizeURL
    }

    let fullSizeURL: URL
    var thumbnailURL: URL?
    let tags: [String]

    init? (json: [String: Any], tags: [String]) {
        guard
            let altSizes = json["alt_sizes"] as? [[String: Any]],
            let originalSize = json["original_size"] as? [String: Any],
            let fullSizeURLString = originalSize["url"] as? String,
            let fullSizeURL = URL(string: fullSizeURLString)
            else { return nil }

        for size in altSizes where size["width"] as? Int == 100 {
            guard
                let urlString = size["url"] as? String,
                let url = URL(string: urlString)
                else { return nil }

            self.thumbnailURL = url
        }

        self.fullSizeURL = fullSizeURL
        self.tags = tags
    }
}

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

let dataSetUpdatedNotification = Notification.Name("notification.dataSetUpdated")

final class CollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {

    // MARK: - Properties
    private let baseURL = "https://api.tumblr.com/v2/blog/boldlygiffing.tumblr.com/"
    private let apiKey = "GXeFiXAi3Ho0HXbCX9Arm4dlxMuuPG4dIjhj7TVfCsUMCVCLRT"
    var dataSet: [Gif] = [] {
        didSet {
            let indexPaths = dataSet
                .compactMap { return oldValue.contains($0) ? nil : dataSet.index(of: $0) }
                .map { IndexPath(indexes:[0, $0]) }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: dataSetUpdatedNotification, object: nil, userInfo: ["newItems": indexPaths])
            }
        }
    }
    
    var offset: Int = 0 {
        didSet {
            self.offset = offset >= self.postCount ? 0 : self.offset
        }
    }
    var postCount: Int = 0
    private var character: CharacterTag = .All
    private var dataRequest: URLSessionDataTask?

    // MARK: - Lifecycle
    override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(loadCharacter(notification:)), name: loadCharacterNotification, object: nil)

        fetchInfo()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func loadCharacter(notification: Notification) {
        guard
        let userInfo = notification.userInfo,
        let characterTag = userInfo["characterTag"] as? CharacterTag
        else { return }

        set(character: characterTag)
        dataSet.removeAll()
        fetchThumbnails()
    }

    func set(character: CharacterTag) {
        self.character = character
    }

    func fetchInfo() {
        guard let url = URL(string: baseURL + "info?api_key=\(apiKey)") else { return }

        dataRequest = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.dataRequest = nil
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let response = json?["response"] as? [String: Any],
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
        let randomOffset = Int.random(postCount)
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
        
        dataRequest = URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            self?.dataRequest = nil
            
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let response = json?["response"] as? [String: Any],
                let postsJson = response["posts"] as? [[String: Any]]
            else {
                print(error)
                return
            }
            
            let posts = postsJson.compactMap(Post.init)
            var newItems: [Gif] = []
            posts.forEach { newItems.append(contentsOf: $0.gifs) }
            self?.dataSet.append(contentsOf: newItems)
            self?.offset = offset
            self?.offset += 21
        })
        dataRequest?.resume()
    }

    func fetchThumbnailsWithOffset() {
        fetchThumbnails(offset: offset)
    }

    // MARK: - CollectionViewDataSource
    @available(iOSApplicationExtension 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSet.count
    }

    @available(iOSApplicationExtension 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: thumbmailCellIdentifier, for: indexPath) as? ThumbnailCell else { return UICollectionViewCell() }

        cell.configure(with: dataSet[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView = UICollectionReusableView()
        if kind == UICollectionView.elementKindSectionHeader {
            guard let characterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: characterPickerViewIdentifier, for: indexPath) as? CharacterPickerView else { return reusableView}

            reusableView = characterView
        }
        return reusableView
    }

    // MARK: - Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { return dataSet[$0.item].fullSizeURL }
        ImagePrefetcher(urls: urls).start()
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard !dataSet.isEmpty else { return }
        
        let urls = indexPaths.compactMap { return dataSet[$0.item].fullSizeURL }
        ImagePrefetcher(urls: urls).stop()
    }
}
