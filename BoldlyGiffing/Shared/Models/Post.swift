//
//  Post.swift
//  BoldlyGiffingMac
//
//  Created by Aaron Williams on 2022-04-12.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import Foundation

struct PostResponse: Decodable, Equatable {
    var posts: [Post]
    
    enum OuterContainer: String, CodingKey {
        case response
    }
    
    enum ResponseContainer: String, CodingKey {
        case posts
    }
    
    init(from decoder: Decoder) throws {
        let outerContainer = try decoder.container(keyedBy: OuterContainer.self)
        let response = try outerContainer.nestedContainer(keyedBy: ResponseContainer.self, forKey: .response)
        self.posts = try response.decode([Post].self, forKey: .posts)
    }
}

struct Post: Decodable, Equatable {
    var gifs: [Gif]
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case tags
        case gifs = "photos"
        case newFormat = "should_open_in_legacy"
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
