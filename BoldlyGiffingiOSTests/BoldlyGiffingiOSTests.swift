//
//  BoldlyGiffingiOSTests.swift
//  BoldlyGiffingiOSTests
//
//  Created by Aaron Williams on 2023-03-07.
//  Copyright © 2023 Sweet Software. All rights reserved.
//

import XCTest
import ComposableArchitecture
@testable import SDWebImageSwiftUI
@testable import BoldlyGiffingiOS

@MainActor
final class BoldlyGiffingiOSTests: XCTestCase {

    func testFetchInfoSuccess() async {
        let store = TestStore(initialState: Thumbnails.State()) {
            Thumbnails()
        } withDependencies: {
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(LCRNG(seed: 2))
            $0.mainQueue = .immediate
        }
            
        var gen = LCRNG(seed: 2)
        let offset = Int.random(in: 0...InfoResponse.mock.postCount - 21, using: &gen)
        let postResponse = PostResponse(
            posts: [Post(
                gifs: Gif.mockArray,
                tags: ["picard"])
            ]
        )
        let infoResponse = InfoResponse.mock
        store.dependencies.APIClient.override(route: "info") {
            try await OK(infoResponse)
        }
        store.dependencies.APIClient.override(route: "posts/photo?limit=\(21)&offset=\(offset)") {
            try await OK(postResponse)
        }
        
        await store.send(.fetchInfo)
        
        await store.receive(.fetchInfoResponse(.success(infoResponse))) {
            $0.postCount = infoResponse.postCount
        }
        await store.receive(.fetchRandomThumbnails)
        await store.receive(.fetchThumbnails(limit: 21, offset: offset)) {
            $0.offset = offset
        }
        await store.receive(
            .fetchThumbnailsResponse(
                .success(postResponse)
            )
        ) {
            $0.offset += 21
            $0.dataSet = IdentifiedArrayOf(uniqueElements: Gif.mockArray)
        }
    }
}

private struct LCRNG: RandomNumberGenerator {
  var seed: UInt64
  mutating func next() -> UInt64 {
    self.seed = 2_862_933_555_777_941_757 &* self.seed &+ 3_037_000_493
    return self.seed
  }
}
