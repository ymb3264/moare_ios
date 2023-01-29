//
//  Follow.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

struct RequestFollowObj: Codable {
    var userObj: UserFollowObj
    var targetObj: TargetFollowObj
    var userIsTeam: Bool
    var targetIsTeam: Bool
}

// follow obj to add in dynamodb account
struct UserFollowObj: Codable {
    var userID: String
    var createdAt: String
    var profileImage: String
    var username: String
}

// follow obj to add in dynamodb account
struct TargetFollowObj: Codable {
    var userID: String
    var createdAt: String
    var profileImage: String
    var username: String
}

struct ResponseFollowObj: Codable {
    var following: [FollowObj]
    var teamOrMember: [FollowObj]?
    var targetFollower: [FollowObj]
    var targetTeamOrMember: [FollowObj]?
}
