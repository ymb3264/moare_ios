//
//  Login.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

struct LoginAccount: Codable {
    var userID: String
    var password: String
}

struct ResponseForNewPwd: Codable {
    var createdAt: String
    var serverCode: Int
}

struct NewPwdObj: Codable {
    var userID: String
    var createdAt: String
    var password: String
}
