//
//  APIClient.swift
//  BoldlyGiffing
//
//  Created by Aaron Williams on 2023-07-04.
//  Copyright © 2023 SweetieApps. All rights reserved.
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
}

struct APIClientKey: DependencyKey {
    
    public static var liveValue = {
        let baseURL = "https://api.tumblr.com/v2/blog/boldlygiffing.tumblr.com/"
        let apiKey = "GXeFiXAi3Ho0HXbCX9Arm4dlxMuuPG4dIjhj7TVfCsUMCVCLRT"

        return Self(request: { route in
            let requestString = baseURL + route + "&api_key=" + apiKey

            if let url = URL(string: requestString) {
                return try await URLSession.shared.data(from: url)
            } else {
                throw(APIClientError.invalidRequestURL)
            }
        }
        )
    }()
    
    public var request: @Sendable (_ route: String) async throws -> (Data, URLResponse)
}


