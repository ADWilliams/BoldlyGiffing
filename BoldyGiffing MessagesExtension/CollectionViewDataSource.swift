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

struct Gif {
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

let dataSetUpdatedNotification = Notification.Name("notification.dataSetUpdated")

final class CollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {

    // MARK: - Properties
    private let baseURL = "https://api.tumblr.com/v2/blog/boldlygiffing.tumblr.com/"
    private let apiKey = "GXeFiXAi3Ho0HXbCX9Arm4dlxMuuPG4dIjhj7TVfCsUMCVCLRT"
    var dataSet: [Gif] = [] {
        didSet {
            NotificationCenter.default.post(name: dataSetUpdatedNotification, object: nil)
        }
    }

    // MARK: - Lifecycle

    override init() {
        super.init()
        
    }

    func fetchThumbnails() {
        guard let url = URL(string: baseURL + "posts?limit=20&api_key=" + apiKey) else { return }

        Alamofire.request(url).responseJSON { [weak self] response in

            switch response.result {
            case .success(let data):
                guard
                    let data = data as? [String: Any],
                    let response = data["response"] as? [String: Any],
                    let postsJson = response["posts"] as? [[String: Any]]
                    else { return }

                let posts = postsJson.flatMap(Post.init)
                posts.forEach { self?.dataSet.append(contentsOf: $0.gifs) }

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
