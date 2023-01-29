//
//  Common.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Foundation

struct MessageResponse: Codable {
    var message: String
}

struct SportHashtagList: Codable {
    var sportList: [String]
}

struct TokenResponse: Codable {
    var accessToken: String
    var refreshToken: String
    var username: String
    var userID: String
}

struct NetworkError: Error {
    enum ErrorType: Error {
        case invalidURL
        case requestError
        case serverError
        case unknown
    }
    
    var error: ErrorType
    
    init(_ error: ErrorType) {
        self.error = error
    }
    
    static func result(urlResponse: URLResponse, data: Data) throws -> Data {
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkError(.unknown)
        }
        switch httpResponse.statusCode {
        case 200..<300:
            return data
        case 400..<500:
            throw NetworkError(.requestError)
        case 500..<599:
            throw NetworkError(.serverError)
        default:
            throw NetworkError(.unknown)
        }
    }
}

enum APIError: Error {
    case requestError(response: MessageResponse)
    case serverError
    case unknown
}
