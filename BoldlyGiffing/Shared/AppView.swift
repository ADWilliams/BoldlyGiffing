//
//  AppView.swift
//  BoldlyGiffing
//
//  Created by Aaron Williams on 2023-07-06.
//  Copyright © 2023 Sweet Software. All rights reserved.
//

import Foundation
import ComposableArchitecture

struct AppReducer: ReducerProtocol {
    @Dependency(\.APIClient) var apiClient
    
    struct State: Equatable {
        var dataSet: [Gif] = []
        var postCount = 0
        var characterTag: CharacterTag = .all
        var offset = 0
    }
    
    
    enum Action: Equatable {
        case fetchInfo
        case fetchInfoResponse(TaskResult<InfoResponse>)
        case fetchRandomThumbnails
        case fetchThumbnails(limit: Int, offset: Int)
        case fetchThumbnailsResponse(TaskResult<PostResponse>)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .fetchInfo:
            return .run { send in
                await send(.fetchInfoResponse(TaskResult {
                    try await apiClient.request(route: "info", as: InfoResponse.self)
                }))
            }
        case .fetchInfoResponse(.failure):
            return .none
            
        case let .fetchInfoResponse(.success(response)):
            state.postCount = response.postCount
            
            return .run { send in
                await send(.fetchRandomThumbnails)
            }
            
        case .fetchRandomThumbnails:
            let postCount = state.postCount - (state.postCount > 21 ? 21 : 0)
#if os(iOS)
            let randomOffset = Int.random(postCount)
#elseif os(macOS)
            let randomOffset = Int.random(in: 0...postCount)
#endif
            let offset = randomOffset < 0 ? 0 : randomOffset
            state.offset = offset
            
            return.run { send in
                await send(.fetchThumbnails(limit: 21, offset: offset))
            }
            
        case let .fetchThumbnails(limit, offset):
            var tagPath: String = ""
            if let characterTag = state.characterTag.rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                tagPath = characterTag.isEmpty ? characterTag : "&tag=\(characterTag)"
            }
            
            let route = "posts/photo?limit\(limit)&offset=\(offset)\(tagPath)"
            return .run { send in
                await send(.fetchThumbnailsResponse(TaskResult<PostResponse> {
                    try await apiClient.request(route: route, as: PostResponse.self)
                }))
            }
        case .fetchThumbnailsResponse(.failure):
            return .none
            
        case let .fetchThumbnailsResponse(.success(response)):
            var newItems: [Gif] = []
            response.posts.forEach { newItems.append(contentsOf: $0.gifs) }
            
            state.dataSet.append(contentsOf: newItems)
            state.offset += 21
        }
        return .none
    }
    
}
