//
//  Gif.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-03-31.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import Foundation
import SwiftUI

enum GifError: Error {
    case decoding
}

struct GifAltSize: Decodable, Equatable {
    let url: String
    let width: Int
    let height: Int
}

struct Gif: Decodable, Equatable, Identifiable {
    static func ==(lhs: Gif, rhs: Gif) -> Bool {
        return lhs.fullSizeURL == rhs.fullSizeURL
    }

    var id: String?
    let fullSizeURL: URL
    var thumbnailURL: URL?
    var tags: [String] = []
    
    mutating func set(tags: [String]) {
        self.tags = tags
    }
    
    enum OuterContainer: String, CodingKey {
        case altSizes = "alt_sizes"
        case originalSize = "original_size"
    }
    
    enum OriginalSizeContainer: String, CodingKey {
        case url
    }
    
    init(from decoder: Decoder) throws {
        let outerContainer = try decoder.container(keyedBy: OuterContainer.self)
        let originalSizeContainer = try outerContainer.nestedContainer(
            keyedBy: OriginalSizeContainer.self,
            forKey: .originalSize
        )
        let fullSizeString = try originalSizeContainer.decode(String.self, forKey: .url)
        let altSizes = try outerContainer.decode([GifAltSize].self, forKey: .altSizes)
        guard let fullSizeURL = URL(string: fullSizeString) else {
            throw GifError.decoding
        }
        
        self.fullSizeURL = fullSizeURL
        self.id = fullSizeURL.lastPathComponent
        self.thumbnailURL = URL(string: altSizes.first(where: { $0.width == 250 })?.url ?? "")
    }
}

extension Gif {
    init (id: String, fullSizeURL: URL, thumbnailURL: URL, tags: [String] = []) {
        self.id = id
        self.fullSizeURL = fullSizeURL
        self.thumbnailURL = thumbnailURL
        self.tags = tags
    }
    
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

extension Gif: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.fullSizeURL)
    }
}

extension Gif {
    
    static let empty = Gif(
        id: UUID().uuidString,
        fullSizeURL: URL(string: "https://www.example.com")!,
        thumbnailURL: URL(string: "https://www.example.com")!,
        tags: []
        )
    
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
