//
//  FollowAPI.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Foundation

struct FollowAPI {
    func follow(token: String, followObj: RequestFollowObj) async throws -> ResponseFollowObj {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/follow/add"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(followObj)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(ResponseFollowObj.self, from: data)
    }
    
    func unfollow(token: String, followObj: RequestFollowObj) async throws -> ResponseFollowObj {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/follow/delete"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(followObj)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(ResponseFollowObj.self, from: data)
    }
}
