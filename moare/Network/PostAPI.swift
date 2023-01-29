//
//  PostAPI.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Foundation

struct PostAPI {
    func createPost(token: String, post: CreatePost, mediaData: [MediaData]) async throws -> MessageResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let data = try! JSONEncoder().encode(post)
        let jsonData = String(data: data, encoding: .utf8)!
        
        let boundary = UUID().uuidString
        let body = createBody(boundary: boundary, jsonData: jsonData, mediaData: mediaData)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let responseData = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(MessageResponse.self, from: responseData)
    }
    
    func updatePost(token: String, post: UpdatePost) async throws -> Post {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post/update"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(post)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(Post.self, from: data)
    }
    
    func deletePost(token: String, post: Post) async throws -> MessageResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post/delete"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(post)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(MessageResponse.self, from: data)
    }
    
    func getPosts(accessToken: String, yearAndMonth: String, location: UserDefaultLocation, username: String, date: String) async throws -> [Post] {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post"
        components.queryItems = [
            URLQueryItem(name: "yearAndMonth", value: yearAndMonth),
            URLQueryItem(name: "x", value: location.x),
            URLQueryItem(name: "y", value: location.y),
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "date", value: date)
        ]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode([Post].self, from: data)
    }
    
    func getMorePosts(yearAndMonth: String, location: UserDefaultLocation, createdAt: String) async throws -> [Post] {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post/more"
        components.queryItems = [
            URLQueryItem(name: "yearAndMonth", value: yearAndMonth),
            URLQueryItem(name: "x", value: location.x),
            URLQueryItem(name: "y", value: location.y),
            URLQueryItem(name: "createdAt", value: createdAt)
        ]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let request = URLRequest(url: url)
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode([Post].self, from: data)
    }
    
    func getPost(yearAndMonth: String, postCreatedAt: String) async throws -> Post {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post/one"
        components.queryItems = [
            URLQueryItem(name: "yearAndMonth", value: yearAndMonth),
            URLQueryItem(name: "postCreatedAt", value: postCreatedAt)
        ]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let request = URLRequest(url: url)
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(Post.self, from: data)
    }
    
    func like(like: LikeObj) async throws -> [String] {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post/like"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(like)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode([String].self, from: data)
    }
    
    func unlike(like: LikeObj) async throws -> [String] {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post/unlike"
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        let body = try! JSONEncoder().encode(like)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode([String].self, from: data)
    }
    
    func reportPost(accessToken: String, obj: [String:String]) async throws -> MessageResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = APIUtil.host
        components.path = "/post/report"
        
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
    
    private func createBody(boundary: String, jsonData: String, mediaData: [MediaData]) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"post\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(jsonData)\r\n".data(using: .utf8)!)
            
        for media in mediaData {
            body.append(boundaryPrefix.data(using: .utf8)!)
            if media.mediaType == "image" {
                body.append("Content-Disposition: form-data; name=\"media\"; filename=\"\(media.filename)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            } else {
                body.append("Content-Disposition: form-data; name=\"media\"; filename=\"\(media.filename)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
            }
            body.append(media.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
