//
//  LoginAPI.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Foundation

struct LoginAPI {
    func login(account: LoginAccount) async throws -> TokenResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/login"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(account)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }
    
    func me(accessToken: String, refreshToken: String) async throws -> TokenResponse {
        do {
            var components = URLComponents()
            
            components.scheme = APIUtil.scheme
            components.host = APIUtil.host
            components.path = "/login"
            
            guard let url = components.url else {
                throw NetworkError(.invalidURL)
            }
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            
            let data = try await APIUtil.getResponse(request: request)
            return try JSONDecoder().decode(TokenResponse.self, from: data)
        } catch APIError.requestError(let response) {
            if response.message == "Accesstoken Expired" {
                var components = URLComponents()
                components.scheme = APIUtil.scheme
                components.host = APIUtil.host
                components.path = "/login/refresh"
                
                guard let url = components.url else {
                    throw NetworkError(.invalidURL)
                }
                
                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
                
                let data = try await APIUtil.getResponse(request: request)
                return try JSONDecoder().decode(TokenResponse.self, from: data)
            }
            throw APIError.requestError(response: response)
        }
    }
    
    func getEmailCode(email: String) async throws -> ResponseForNewPwd {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/login/emailcode"
        components.queryItems = [
            URLQueryItem(name: "email", value: email)
        ]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let request = URLRequest(url: url)
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(ResponseForNewPwd.self, from: data)
    }
    
    func setNewPwd(obj: NewPwdObj) async throws -> MessageResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/login/newpwd"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(obj)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(MessageResponse.self, from: data)
    }
}
