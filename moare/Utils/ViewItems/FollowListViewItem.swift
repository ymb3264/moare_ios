//
//  FollowListViewItem.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

enum Selected {
    case team
    case member
    case follower
    case following
    
    var alignment: Alignment {
        switch self {
        case .team:
            return .leading
        case .member:
            return .leading
        case .follower:
            return .center
        case .following:
            return .trailing
        }
    }
    
    var tabName: String {
        switch self {
        case .team:
            return "team"
        case .member:
            return "member"
        case .follower:
            return "follower"
        case .following:
            return "following"
        }
    }
}
