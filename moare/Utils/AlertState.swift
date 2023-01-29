//
//  AlertState.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/16.
//

enum PostCreateAlertState {
    case contentDelete
    case videoDurationLimit
    case mediaCountLimit
}

enum LocationAlertState {
    case currentLocation
    case denied
}

enum PostDetailAlertState {
    case report
    case reportSuccess
}

enum UserProfileViewAlertState {
    case unfollow
    case report
    case reportSuccess
    case blockUser
    case blockUserSuccess
}
