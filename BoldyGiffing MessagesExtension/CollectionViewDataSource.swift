//
//  CollectionViewDataSource.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2017-06-30.
//  Copyright © 2017 SweetieApps. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

struct Post {
    let gifs: [Gif]

    init? (json: [String: Any]) {
        guard
        let tags = json["tags"] as? [String],
        let photos = json["photos"] as? [[String: Any]]
        else { return nil}

        gifs = photos.flatMap { Gif(json: $0, tags: tags) }
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
                .flatMap { return oldValue.contains($0) ? nil : dataSet.index(of: $0) }
                .map { IndexPath(indexes:[0, $0]) }
            NotificationCenter.default.post(name: dataSetUpdatedNotification, object: nil, userInfo: ["newItems": indexPaths])
        }
    }
    
    var offset: Int = 0 {
        didSet {
            self.offset = offset >= self.postCount ? 0 : self.offset
        }
    }
    var postCount: Int = 0
    private var character: CharacterTag = .All
    private var dataRequest: DataRequest?

    // MARK: - Lifecycle
    override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(loadCharacter(notification:)), name: loadCharacterNotification, object: nil)
        fetchInfo()
    }

    @objc func loadCharacter(notification: Notification) {
        guard
        let userInfo = notification.userInfo,
        let characterTag = userInfo["characterTag"] as? CharacterTag
        else { return }

        set(character: characterTag)
        fetchRandomThumbnails()
    }

    func set(character: CharacterTag) {
        self.character = character
    }

    func fetchInfo() {
        guard let url = URL(string: baseURL + "info?api_key=\(apiKey)") else { return }

        Alamofire.request(url).responseJSON { [weak self] response in

            switch response.result {
            case .success(let data):
                guard
                    let data = data as? [String: Any],
                    let response = data["response"] as? [String: Any],
                    let blog = response["blog"] as? [String: Any],
                    let postCount = blog["posts"] as? Int
                    else { return }

                self?.postCount = postCount
                self?.fetchRandomThumbnails()
            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchRandomThumbnails() {
        let postCount = self.postCount - (self.postCount > 21 ? 21 : 0)
        let randomOffset = Int.random(postCount)
        offset = randomOffset < 0 ? 0 : randomOffset
        fetchThumbnails(offset: self.offset)
    }

    func fetchThumbnails(limit: Int = 21, offset: Int = 0) {
        guard
            let characterTag = character.rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = URL(string: baseURL + "posts/photo?limit=21&offset=\(offset)&tag=\(characterTag)&api_key=\(apiKey)" ),
            dataRequest == nil
            else { return }

        dataRequest = Alamofire.request(url).responseJSON { [weak self] response in
            self?.dataRequest = nil
            switch response.result {
            case .success(let data):
                guard
                    let data = data as? [String: Any],
                    let response = data["response"] as? [String: Any],
                    let postsJson = response["posts"] as? [[String: Any]]
                    else { return }

                let posts = postsJson.flatMap(Post.init)
                var newItems: [Gif] = []
                posts.forEach { newItems.append(contentsOf: $0.gifs) }
                self?.dataSet.append(contentsOf: newItems)
                self?.offset += 21

            case .failure(let error):
                print(error)
            }
        }
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
    
    // MARK: - Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap { return dataSet[$0.item].fullSizeURL }
        ImagePrefetcher(urls: urls).start()
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap { return dataSet[$0.item].fullSizeURL }
        ImagePrefetcher(urls: urls).stop()
    }
}
