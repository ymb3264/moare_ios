//
//  Profile.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import UIKit

struct Profile: Codable, Hashable {
    var userID: String?
    var createdAt: String
    var chatToken: String?
    var username: String
    var sportHashtag: [String]?
    var name: String
    var profileImage: String
    var content: String
    var place: String
    var isTeam: Bool
    var follower: [FollowObj]
    var following: [FollowObj]
    var teamOrMember: [FollowObj]
    var likePost: [String]?
    var blockedUser: [String]?
    var blockedBy: [String]?
    // var for controlling chat
    var chatID: String?
    
    func encoded() -> String {
        let data = try! JSONEncoder().encode(self)
        return String(data: data, encoding: .utf8)!
    }
    
    static func decode(_ encodedString: String) -> Profile {
        let data = encodedString.data(using: .utf8)
        do {
            return try JSONDecoder().decode(Profile.self, from: data!)
        } catch {
            return Profile(createdAt: "", username: "", name: "", profileImage: "", content: "", place: "", isTeam: false, follower: [], following: [], teamOrMember: [])
        }
    }
}

struct FollowObj: Codable, Hashable {
    var userID: String
    var createdAt: String
    var profileImage: String
    var username: String
}

struct RequestUpdateProfile: Codable, Hashable {
    var newProfile: UpdateProfile
    var beforeProfile: Profile
}

struct UpdateProfile: Codable, Hashable {
    var createdAt: String
    var username: String
    var sportHashtag: [String]?
    var name: String
    var profileImage: String
    var content: String
    var place: String
    var userHashtag = [String]()
    // 기본 이미지로 변경시 기존 이미지 삭제용도 변수
    var shouldUpdateDefaultImage = false
}

struct CreateTeamProfile: Codable, Hashable {
    var createdAt: String
    var username: String
    var sportHashtag: [String]?
    var name: String
    var profileImage: String
    var content: String
    var place: String
    var isTeam = true
    var follow: FollowObj?
    var userHashtag = [String]()
}

struct BlockUserObj: Codable {
    var targetUserID: String
    var targetCreatedAt: String
    var userProfile: Profile
}
