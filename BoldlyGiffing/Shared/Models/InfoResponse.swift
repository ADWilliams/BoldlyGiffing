//
//  InfoResponse.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2022-04-05.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import Foundation

public struct InfoResponse: Codable, Equatable {
    
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
    
    internal init(postCount: Int) {
        self.postCount = postCount
    }
    
    public enum CodingKeys: CodingKey {
        case postCount
    }
    
    public func encode(to encoder: Encoder) throws {
        var outerContainer = encoder.container(keyedBy: OuterKeys.self)
        var responseContainer = outerContainer.nestedContainer(keyedBy: ResponseKeys.self, forKey: .response)
        var blogContainer = responseContainer.nestedContainer(keyedBy: BlogKeys.self, forKey: .blog)
        try blogContainer.encode(self.postCount, forKey: .posts)
    }
    
   public init(from decoder: Decoder) throws {
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

extension InfoResponse {
    static var mock: InfoResponse {
        return InfoResponse(postCount: 1600)
    }
}
