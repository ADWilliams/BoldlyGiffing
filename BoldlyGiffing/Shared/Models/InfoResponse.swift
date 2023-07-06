//
//  InfoResponse.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2022-04-05.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import Foundation

struct InfoResponse: Decodable {
    let postCount: Int
    
    enum OuterKeys: String, CodingKey {
        case response
    }
    
    enum ResponseKeys: String, CodingKey {
        case blog
    }
    
    enum BlogKeys: String, CodingKey {
        case posts
    }
    
    init(from decoder: Decoder) throws {
        let outerContainer = try decoder.container(keyedBy: OuterKeys.self)
        let responseContainer = try outerContainer.nestedContainer(
            keyedBy: ResponseKeys.self,
            forKey: .response
        )
        let blogContainer = try responseContainer.nestedContainer(
            keyedBy: BlogKeys.self,
            forKey: .blog
        )
        
        self.postCount = try blogContainer.decode(Int.self, forKey: .posts)
    }
}
