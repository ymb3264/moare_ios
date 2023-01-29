//
//  LocationAPI.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Foundation

struct LocationAPI {
    private let host = "dapi.kakao.com"
    
    func searchAddress(query: String) async throws -> AddressResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = self.host
        components.path = "/v2/local/search/address.json"
        components.queryItems = [URLQueryItem(name: "query", value: query)]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("KakaoAK 964b84968914e77804587272bb857d25", forHTTPHeaderField: "Authorization")

        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(AddressResponse.self, from: data)
    }
    
    func searchCoordinateAddress(coordinate: Coordinate) async throws -> CoordinateResponse {
        var components = URLComponents()
        
        components.scheme = APIUtil.scheme
        components.host = self.host
        components.path = "/v2/local/geo/coord2address.json"
        components.queryItems = [
            URLQueryItem(name: "x", value: coordinate.x),
            URLQueryItem(name: "y", value: coordinate.y),
            URLQueryItem(name: "input_coord", value: "WGS84"),
        ]
        
        guard let url = components.url else {
            throw NetworkError(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("KakaoAK 964b84968914e77804587272bb857d25", forHTTPHeaderField: "Authorization")

        let data = try await APIUtil.getResponse(request: request)
        return try JSONDecoder().decode(CoordinateResponse.self, from: data)
    }
}
