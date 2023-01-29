//
//  Join.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

struct JoinAccount: Codable {
    var userID: String
    var createdAt: String
    var password: String
    var username: String
    var sportHashtag = [String]()
    var allTermsAgreed: Bool
}

struct EmailCode: Codable {
    var serverCode: Int
}
