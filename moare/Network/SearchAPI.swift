//
//  SearchAPI.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Foundation

struct SearchAPI {
    func searchUsername(query: String) async throws -> [SearchUserObj] {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/search/username"
        components.queryItems = [
            URLQueryItem(name: "username", value: query)
        ]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let request = URLRequest(url: url)
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode([SearchUserObj].self, from: data)
    }
}
