//
//  JoinAPI.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Foundation

struct JoinAPI {
    func getEmailCode(email: String) async throws -> EmailCode {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/join/emailcode"
        components.queryItems = [
            URLQueryItem(name: "email", value: email)
        ]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let request = URLRequest(url: url)
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(EmailCode.self, from: data)
    }
    
    func checkUsername(username: String) async throws -> MessageResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/join/username"
        components.queryItems = [
            URLQueryItem(name: "username", value: username)
        ]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let request = URLRequest(url: url)
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(MessageResponse.self, from: data)
    }
    
    func getSportList() async throws -> SportHashtagList {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/join/sport"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let request = URLRequest(url: url)
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(SportHashtagList.self, from: data)
    }
    
    func join(account: JoinAccount) async throws -> TokenResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/join"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(account)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }
}
