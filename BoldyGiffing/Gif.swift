//
//  Gif.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-03-31.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import Foundation

struct Gif: Equatable, Identifiable {
    static func ==(lhs: Gif, rhs: Gif) -> Bool {
        return lhs.fullSizeURL == rhs.fullSizeURL
    }

    var id: String?
    let fullSizeURL: URL
    var thumbnailURL: URL?
    let tags: [String]
}

extension Gif {
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

        self.id = fullSizeURL.pathComponents.last
        self.fullSizeURL = fullSizeURL
        self.tags = tags
    }
}

extension Gif {
    static let mock = Gif(
        id: UUID().uuidString,
        fullSizeURL: URL(string: "https://64.media.tumblr.com/00cc50a1ccdea1b4e15735f1c6f723ec/tumblr_olppycIjeH1trbh6do1_400.gif")!,
        thumbnailURL: URL(string: "https://64.media.tumblr.com/00cc50a1ccdea1b4e15735f1c6f723ec/tumblr_olppycIjeH1trbh6do1_100.gif")!,
        tags: ["picard"]
    )
    
    static let mockArray = [
        Gif(
        id: UUID().uuidString,
        fullSizeURL: URL(string: "https://64.media.tumblr.com/00cc50a1ccdea1b4e15735f1c6f723ec/tumblr_olppycIjeH1trbh6do1_400.gif")!,
        thumbnailURL: URL(string: "https://64.media.tumblr.com/00cc50a1ccdea1b4e15735f1c6f723ec/tumblr_olppycIjeH1trbh6do1_100.gif")!,
        tags: ["picard"]
    ),
        Gif(
            id: UUID().uuidString,
            fullSizeURL: URL(string: "https://64.media.tumblr.com/00cc50a1ccdea1b4e15735f1c6f723ec/tumblr_olppycIjeH1trbh6do1_400.gif")!,
            thumbnailURL: URL(string: "https://64.media.tumblr.com/00cc50a1ccdea1b4e15735f1c6f723ec/tumblr_olppycIjeH1trbh6do1_100.gif")!,
            tags: ["picard"]
        ),
        Gif(
            id: UUID().uuidString,
            fullSizeURL: URL(string: "https://64.media.tumblr.com/00cc50a1ccdea1b4e15735f1c6f723ec/tumblr_olppycIjeH1trbh6do1_400.gif")!,
            thumbnailURL: URL(string: "https://64.media.tumblr.com/00cc50a1ccdea1b4e15735f1c6f723ec/tumblr_olppycIjeH1trbh6do1_100.gif")!,
            tags: ["picard"]
        ),
        Gif(
            id: UUID().uuidString,
            fullSizeURL: URL(string: "https://64.media.tumblr.com/00cc50a1ccdea1b4e15735f1c6f723ec/tumblr_olppycIjeH1trbh6do1_400.gif")!,
            thumbnailURL: URL(string: "https://64.media.tumblr.com/00cc50a1ccdea1b4e15735f1c6f723ec/tumblr_olppycIjeH1trbh6do1_100.gif")!,
            tags: ["picard"]
        )
    ]
}

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
