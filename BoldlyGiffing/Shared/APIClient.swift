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
    
    static var testValue: APIClientKey = {
        return Self(request: unimplemented("\(Self.self).request"))
    }()
    
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

extension APIClientKey: TestDependencyKey {
    public mutating func override(
        route matchingRoute: String,
        withResponse response: @escaping @Sendable () async throws -> (Data, URLResponse)
    ) {
        self.request = { @Sendable [self] route in
            if route == matchingRoute {
                return try await response()
            } else {
                return try await self.request(route)
            }
        }
    }
}

#if DEBUG

  public func OK<A: Encodable>(
    _ value: A, encoder: JSONEncoder = .init()
  ) async throws -> (Data, URLResponse) {
    (
      try encoder.encode(value),
      HTTPURLResponse(
        url: URL(string: "/")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    )
  }

  public func OK(_ jsonObject: Any) async throws -> (Data, URLResponse) {
    (
      try JSONSerialization.data(withJSONObject: jsonObject, options: []),
      HTTPURLResponse(
        url: URL(string: "/")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    )
  }
#endif
