//
//  APIClient.swift
//  BoldlyGiffing
//
//  Created by Aaron Williams on 2023-07-04.
//  Copyright © 2023 Sweet Software. All rights reserved.
//

import Foundation
import Dependencies

extension DependencyValues {
    var APIClient: APIClientKey {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

enum APIClientError: Error {
    case invalidRequestURL
    case decodingError
}

struct APIClientKey: DependencyKey {
    
    public static var liveValue = {
        let baseURL = "https://api.tumblr.com/v2/blog/boldlygiffing.tumblr.com/"
        let apiKey = "GXeFiXAi3Ho0HXbCX9Arm4dlxMuuPG4dIjhj7TVfCsUMCVCLRT"

        return Self(request: { route in
            let requestString = baseURL + route
            
            

            let apiKey = URLQueryItem(name: "api_key", value: apiKey)
            
            if var url = URL(string: requestString) {
                url.append(queryItems:[apiKey])
                return try await URLSession.shared.data(from: url)
            } else {
                throw(APIClientError.invalidRequestURL)
            }
        }
        )
    }()
    
    public func request<A: Decodable>(route: String, as: A.Type) async throws -> A {
        let (data, _ ) = try await request(route)
        do {
            return try apiDecode(A.self, from: data)
        } catch {
            throw error
        }
    }
    
    public var request: @Sendable (_ route: String) async throws -> (Data, URLResponse)
    
    let jsonDecoder = JSONDecoder()
    
    public func apiDecode<A: Decodable>(_ type: A.Type, from data: Data) throws -> A {
        do {
            return try jsonDecoder.decode(A.self, from: data)
        } catch {
            print("🚨 Decoding Error: \(error)")
            throw APIClientError.decodingError
        }
    }
}
