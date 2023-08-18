//
//  Post.swift
//  BoldlyGiffingMac
//
//  Created by Aaron Williams on 2022-04-12.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import Foundation

public struct PostResponse: Codable, Equatable {
    internal init(posts: [Post]) {
        self.posts = posts
    }
    
    var posts: [Post]
    
    enum OuterContainer: String, CodingKey {
        case response
    }
    
    enum ResponseContainer: String, CodingKey {
        case posts
    }
    
    enum CodingKeys: CodingKey {
        case posts
    }
    
    public func encode(to encoder: Encoder) throws {
        var outerContainer = encoder.container(keyedBy: OuterContainer.self)
        var container = outerContainer.nestedContainer(keyedBy: ResponseContainer.self, forKey: .response)
        try container.encode(self.posts, forKey: .posts)
    }
    
    public init(from decoder: Decoder) throws {
        let outerContainer = try decoder.container(keyedBy: OuterContainer.self)
        let response = try outerContainer.nestedContainer(keyedBy: ResponseContainer.self, forKey: .response)
        self.posts = try response.decode([Post].self, forKey: .posts)
    }
}

struct Post: Codable, Equatable {
    internal init(gifs: [Gif], tags: [String]) {
        self.gifs = gifs
        self.tags = tags
    }
    
    var gifs: [Gif]
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case tags
        case gifs = "photos"
        case newFormat = "should_open_in_legacy"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gifs, forKey: .gifs)
        try container.encode(tags, forKey: .tags)
        try container.encode(true, forKey: .newFormat)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let newFormat = try !container.decode(Bool.self, forKey: .newFormat)
        
        let tags = try container.decode([String].self, forKey: .tags)
        self.tags = tags
        
        if newFormat {
                gifs = []
        } else {
            let gifs = try container.decode([Gif].self, forKey: .gifs)
            self.gifs = gifs.map { gif -> Gif in
                var returnValue = gif
                returnValue.set(tags: tags)
                return returnValue
            }
        }
    }
}
