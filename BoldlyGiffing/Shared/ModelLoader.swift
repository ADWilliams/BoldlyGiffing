//
//  ModelLoader.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2022-04-05.
//  Copyright © 2022 Sweet Software. All rights reserved.
//

import Foundation

struct ModelLoader<Model: Decodable> {
    let urlSession = URLSession.shared
    
    func loadModel(url: URL) async -> Result<Model, Error> {
        do {
            let model = try await urlSession.model(for: url, type: Model.self)
            return .success(model)
        }
        catch {
            return .failure(error)
        }
    }
}

extension URLSession {
    func model<T: Decodable>(
        for url: URL,
        type: T.Type = T.self,
        decoder: JSONDecoder = .init()
    ) async throws -> T {
        let (data, _) = try await data(from: url)
        return try decoder.decode(type, from: data)
    }
}
