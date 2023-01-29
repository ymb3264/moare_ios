//
//  ProfileAPI.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Foundation
import UIKit

struct ProfileAPI {
    func getMyProfile(token: String, username: String) async throws -> Profile {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/profile"
        components.queryItems = [
            URLQueryItem(name: "username", value: username)
        ]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(Profile.self, from: data)
    }
    
    func getUserProfile(username: String) async throws -> Profile {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/profile/user"
        components.queryItems = [
            URLQueryItem(name: "username", value: username)
        ]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let request = URLRequest(url: url)
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(Profile.self, from: data)
    }
    
    func getUserPosts(userID: String, username: String) async throws -> [Post] {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post/user"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let obj = ["userID": userID, "username": username]
        let body = try! JSONEncoder().encode(obj)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode([Post].self, from: data)
    }
    
    func getMoreUserPosts(userID: String, username: String, createdAt: String) async throws -> [Post] {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post/user_more"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let obj = ["userID": userID, "username": username, "createdAt": createdAt]
        let body = try! JSONEncoder().encode(obj)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode([Post].self, from: data)
    }
    
    func createTeamProfile(token: String, profile: CreateTeamProfile, profileImage: UIImage) async throws -> Profile {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/profile/team"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let data = try! JSONEncoder().encode(profile)
        let jsonData = String(data: data, encoding: .utf8)!
        
        let boundary = UUID().uuidString
        let body = createBody(boundary: boundary, jsonData: jsonData, image: profileImage)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let responseData = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(Profile.self, from: responseData)
    }
    
    func updateProfile(token: String, profile: RequestUpdateProfile, selectedImage: UIImage) async throws -> Profile {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/profile"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let data = try! JSONEncoder().encode(profile)
        let jsonData = String(data: data, encoding: .utf8)!
        
        let boundary = UUID().uuidString
        let body = createBody(boundary: boundary, jsonData: jsonData, image: selectedImage)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let responseData = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(Profile.self, from: responseData)
    }
    
    func getMyAccounts(token: String) async throws -> [Profile] {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/profile/accounts"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode([Profile].self, from: data)
    }
    
    func deleteProfile(token: String, profile: Profile) async throws -> MessageResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/profile/delete"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(profile)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(MessageResponse.self, from: data)
    }
    
    func reportUser(accessToken: String, obj: [String:String]) async throws -> MessageResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/profile/report"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(obj)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(MessageResponse.self, from: data)
    }
    
    func blockUser(accessToken: String, obj: BlockUserObj) async throws -> Profile {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/profile/block"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(obj)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(Profile.self, from: data)
    }
    
    private func createBody(boundary: String, jsonData: String, image: UIImage) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"profile\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(jsonData)\r\n".data(using: .utf8)!)
        
        if image != UIImage() {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"profileImage\"; filename=\"testImage\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(image.jpegData(compressionQuality: 0.1)!)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
