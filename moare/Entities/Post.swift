//
//  Post.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import UIKit

struct Post: Codable, Hashable {
    var userID: String
    var postCreatedAt: String
    var userCreatedAt: String
    var username: String
    var profileImage: String
    var yearAndMonth: String
    var mediaObj: [MediaObj]
    var content: String
    var sportHashtag: [String]
    var place: String
    var x: String
    var y: String
    var like: [String]?
    var uiImage: [UIImage]?
    
    enum CodingKeys: String, CodingKey {
        case userID, postCreatedAt, userCreatedAt, username, profileImage, yearAndMonth, mediaObj, content, sportHashtag, place, x, y, like
    }
}

struct CreatePost: Codable, Hashable {
    var postCreatedAt: String
    var userCreatedAt: String
    var username: String
    var profileImage: String
    var yearAndMonth: String
    var mediaObj: [MediaObj]
    var content: String
    var sportHashtag: [String]
    var place: String
    var x: String
    var y: String
    var userHashtag = [String]()
}

struct UpdatePost: Codable, Hashable {
    var postCreatedAt: String
    var updatedAt: String
    var content: String
    var sportHashtag: [String]
    var place: String
    var x: String
    var y: String
    var userHashtag = [String]()
}

struct MediaObj: Codable, Hashable {
    var type: String
    var url: String
}

struct Posts: Identifiable {
    var id = UUID()
    var posts: [Post]
}

struct PostListObj: Hashable {
    var postList: [Post]
    var isLoaded: Bool
}

struct MediaData {
    var data: Data
    var mediaType: String
    var filename: String
}

struct LikeObj: Codable {
    var userID: String
    var userCreatedAt: String
    var username: String
    var postUserID: String
    var postCreatedAt: String
}
