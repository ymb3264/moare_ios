//
//  UserProfileViewModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import KeychainAccess
import StreamChat
import StreamChatSwiftUI
import Combine

class UserProfileViewModel: ObservableObject {
    private let profileApi = ProfileAPI()
    private var followApi = FollowAPI()
    private let postAPI = PostAPI()
    
    @AppStorage("username") var myUsername = ""
    @AppStorage("userID") var userID = ""
    @AppStorage("profile") var profile = ""
    
    @Published var userProfile = Profile(userID: "", createdAt: "", username: "", name: "", profileImage: "", content: "", place: "", isTeam: false, follower: [], following: [], teamOrMember: [])
    
    @Published var postLoading = false
    @Published var followLoading = false

    @Published var postNetworkError = false
    @Published var networkError = false
    
    // unfollow 확인 알람
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    @Published var postsList = [PostListObj]()
    var postNum = 6
    var postsData = [Post]()
    
    var accountsUsername = [String]()

    @Published var followButtonEnabled = true

    @Injected(\.chatClient) var chatClient
    
    @MainActor init(username: String) {
        let encodedAccounts = UserDefaults.standard.array(forKey: "accounts")
        encodedAccounts?.forEach { account in
            accountsUsername.append(Profile.decode(account as! String).username)
        }
        getUserProfile(username: username)
    }
    
    @MainActor func getUserProfile(username: String) {
        Task {
            do {
                let response = try await profileApi.getUserProfile(username: username)
                self.userProfile = response
                userProfile.chatID = userProfile.userID!.components(separatedBy: ["@","."]).joined() + "_\(userProfile.createdAt.components(separatedBy: [":"]).joined())"
                getUserPosts()
                
                for obj in userProfile.follower {
                    if obj.username == myUsername {
                        followButtonEnabled = false
                        break
                    }
                }
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        self.networkError = true
                    case .serverError:
                        self.networkError = true
                    default:
                        self.networkError = true
                    }
                } else {
                    self.networkError =  true
                    print("\(error)")
                }
            }
        }
    }
    
    @MainActor func getUserPosts() {
        self.postLoading = true
        postNum = 6
        Task {
            do {
                self.postsData = try await profileApi.getUserPosts(userID: userProfile.userID!, username: userProfile.username)

                let num = postsData.count <= 6 ? postsData.count-1 : postNum-1

                self.postLoading = false
                self.postsList.removeAll()
                self.postsList.append(
                    PostListObj(postList: Array(postsData[...num]), isLoaded: false)
                )
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        self.postLoading = false
                        self.postNetworkError = true
                    case .serverError:
                        self.postLoading = false
                        self.postNetworkError = true
                        print("\(error)")
                    default:
                        self.postLoading = false
                        self.postNetworkError = true
                    }
                } else {
                    self.postLoading = false
                    self.postNetworkError = true
                    print("\(error)")
                }
            }
        }
    }
    
    @MainActor func loadMorePost() {
        Task {
            var newPosts = [Post]()
            let count = postsData.count
            
            if count % 60 == 0 && postNum == count {
                getMorePost()
            } else {
                if postNum < count && count < postNum+6 {
                    newPosts = Array(postsData[postNum...postsData.count-1])
                } else if count >= postNum+6 {
                    newPosts = Array(postsData[postNum...postNum+5])
                } else {
                    return
                }
                
                self.postsList.append(PostListObj(postList: newPosts, isLoaded: false))
                self.postNum += 6
            }
        }
    }
    
    @MainActor func getMorePost() {
        Task {
            do {
                let lastPost = postsData.last!
                
                let newPostsData = try await profileApi.getMoreUserPosts(userID: userProfile.userID!, username: userProfile.username, createdAt: lastPost.postCreatedAt)
                
                postsData = postsData + newPostsData
                loadMorePost()
            } catch {
                
            }
        }
    }
    
    @MainActor func checkUnfollow(cb: @escaping () -> ()) {
        let myProfile = Profile.decode(self.profile)
        
        for obj in myProfile.teamOrMember {
            if obj.username == userProfile.username {
                cb()
                if myProfile.isTeam {
                    alertTitle = "\(userProfile.username)(멤버) 언팔로우"
                    alertMessage = "팀에 속해있는 멤버를 언팔로우시 해당 멤버는 팀에서 제외되며 채팅방에서도 제외됩니다."
                    return
                } else {
                    alertTitle = "\(userProfile.username)(팀) 언팔로우"
                    alertMessage = "멤버로 속해있는 팀을 언팔로우시 해당 팀 멤버에서 제외되며 팀 채팅방에서도 나가집니다."
                    return
                }
            }
        }
        
        // teamOrMember에 없을 시 바로 언팔로우
        unfollow()
    }
    
    @MainActor func follow() {
        self.followLoading = true
        Task {
            do {
                guard let token = try! Keychain().get("AccessToken") else { return }
                
                // userprofileview로 넘어온 myProfile사용, appstorage profile은 안쓰이면 삭제
                var myProfile = Profile.decode(self.profile)
                
                let targetObj = TargetFollowObj(
                    userID: userProfile.userID!,
                    createdAt: userProfile.createdAt,
                    profileImage: userProfile.profileImage,
                    username: userProfile.username)
                let userObj = UserFollowObj(
                    userID: myProfile.userID!,
                    createdAt: myProfile.createdAt,
                    profileImage: myProfile.profileImage,
                    username: myProfile.username)
                let followObj = RequestFollowObj(
                    userObj: userObj,
                    targetObj: targetObj,
                    userIsTeam: myProfile.isTeam,
                    targetIsTeam: userProfile.isTeam)
                
                let response = try await followApi.follow(token: token, followObj: followObj)
                
                // follow update
                self.userProfile.follower = response.targetFollower
                if let targetTeamOrMember = response.targetTeamOrMember {
                    self.userProfile.teamOrMember = targetTeamOrMember
                }
                
                // accounts, myProfile update
                var encodedAccounts = UserDefaults.standard.array(forKey: "accounts") ?? [String]()
                for(i, item) in encodedAccounts.enumerated() {
                    if Profile.decode(item as! String).username == myProfile.username {
                        encodedAccounts.remove(at: i)
                        
                        myProfile.following = response.following
                        if let teamOrMember = response.teamOrMember {
                            myProfile.teamOrMember = teamOrMember
                        }
                        self.profile = myProfile.encoded()
                        
                        encodedAccounts.insert(self.profile, at: i)
                        UserDefaults.standard.set(encodedAccounts, forKey: "accounts")
                    }
                }
                
                // joinChat
                if response.teamOrMember != nil {
                    joinTeamChannel(isTeam: myProfile.isTeam)
                }
                
                self.followLoading = false
                followButtonEnabled = false
            } catch {
                // toast error
                self.followLoading = false
                print("\(error)")
            }
        }
    }
    
    @MainActor func unfollow() {
        self.followLoading = true
        Task {
            do {
                guard let token = try! Keychain().get("AccessToken") else { return }
                
                var myProfile = Profile.decode(self.profile)
                
                let targetObj = TargetFollowObj(
                    userID: userProfile.userID!,
                    createdAt: userProfile.createdAt,
                    profileImage: userProfile.profileImage,
                    username: userProfile.username)
                let userObj = UserFollowObj(
                    userID: myProfile.userID!,
                    createdAt: myProfile.createdAt,
                    profileImage: myProfile.profileImage,
                    username: myProfile.username)
                let followObj = RequestFollowObj(
                    userObj: userObj,
                    targetObj: targetObj,
                    userIsTeam: myProfile.isTeam,
                    targetIsTeam: userProfile.isTeam)
                
                let response = try await followApi.unfollow(token: token, followObj: followObj)
                
                // follow update
                self.userProfile.follower = response.targetFollower
                if let targetTeamOrMember = response.targetTeamOrMember {
                    self.userProfile.teamOrMember = targetTeamOrMember
                }
                
                // leaveChat
                for obj in myProfile.teamOrMember {
                    if obj.username == userProfile.username {
                        leaveTeamChannel(isTeam: myProfile.isTeam)
                        break
                    }
                }
                                
                // accounts, myProfile update
                var encodedAccounts = UserDefaults.standard.array(forKey: "accounts") ?? [String]()
                for(i, item) in encodedAccounts.enumerated() {
                    if Profile.decode(item as! String).username == myProfile.username {
                        encodedAccounts.remove(at: i)
                        
                        myProfile.following = response.following
                        if let teamOrMember = response.teamOrMember {
                            myProfile.teamOrMember = teamOrMember
                        }
                        self.profile = myProfile.encoded()
                        
                        encodedAccounts.insert(self.profile, at: i)
                        UserDefaults.standard.set(encodedAccounts, forKey: "accounts")
                    }
                }
                
                self.followLoading = false
                followButtonEnabled = true
            } catch {
                // toast error
                self.followLoading = false
                print("\(error)")
            }
        }
    }
    
    func like(post: Post, listIndex: Int, postIndex: Int) {
        Task {
            do {
                var likeList = postsList[listIndex].postList[postIndex].like ?? []
                likeList.append(myUsername)
                postsList[listIndex].postList[postIndex].like = likeList
                
                let like = LikeObj(userID: userID, userCreatedAt: Profile.decode(profile).createdAt, username: myUsername, postUserID: post.userID, postCreatedAt: post.postCreatedAt)
                let newLike = try await postAPI.like(like: like)
                postsList[listIndex].postList[postIndex].like = newLike
            } catch {
                print("\(error)")
            }
        }
    }
    
    func unlike(post: Post, listIndex: Int, postIndex: Int) {
        Task {
            do {
                var likeList = postsList[listIndex].postList[postIndex].like ?? []
                if let index = likeList.firstIndex(of: myUsername) {
                    likeList.remove(at: index)
                }
                postsList[listIndex].postList[postIndex].like = likeList
                
                let like = LikeObj(userID: userID, userCreatedAt: Profile.decode(profile).createdAt, username: myUsername, postUserID: post.userID, postCreatedAt: post.postCreatedAt)
                let newLike = try await postAPI.unlike(like: like)
                postsList[listIndex].postList[postIndex].like = newLike
            } catch {
                print("\(error)")
            }
        }
    }
    
    @MainActor func reportPost(post: Post, listIndex: Int, postIndex: Int, cb: @escaping () -> ()) {
        Task {
            do {
                guard let accessToken = try! Keychain().get("AccessToken") else { return }
                
                let obj = [
                    "userID": post.userID,
                    "createdAt": post.postCreatedAt,
                    "userCreatedAt": Profile.decode(profile).createdAt
                ]
                let respone = try await postAPI.reportPost(accessToken: accessToken, obj: obj)
                
                if respone.message == "report success" {
                    cb()
                }
            } catch {
                print(error)
            }
        }
    }
    
    @MainActor func reportUser(cb: @escaping () -> ()) {
        Task {
            do {
                guard let accessToken = try! Keychain().get("AccessToken") else { return }
                
                let obj = [
                    "userID": userProfile.userID!,
                    "createdAt": userProfile.createdAt,
                    "userCreatedAt": Profile.decode(profile).createdAt
                ]
                let respone = try await profileApi.reportUser(accessToken: accessToken, obj: obj)
                
                if respone.message == "report success" {
                    cb()
                }
            } catch {
                print(error)
            }
        }
    }
    
    @MainActor func blockUser(cb: @escaping () ->()) {
        Task {
            do {
                guard let accessToken = try! Keychain().get("AccessToken") else { return }
                
                let obj = BlockUserObj(
                    targetUserID: userProfile.userID!,
                    targetCreatedAt: userProfile.createdAt,
                    userProfile: Profile.decode(profile)
                )
                let respone = try await profileApi.blockUser(accessToken: accessToken, obj: obj)
                
                profile = respone.encoded()
                cb()
            } catch {
                print(error)
            }
        }
    }
    
    // chat
    func createChannel(completion: @escaping (String) -> ()) {
        let controller = chatClient.channelListController(
            query: .init(
                filter: .and([.equal(.type, to: .messaging), .equal("members", to: [userProfile.chatID!, Profile.decode(profile).chatID!])])
            )
        )
        
        controller.synchronize { error in
            if let error = error {
                print(error)
            } else {
                let channels = controller.channels
                // 존재하는 채널이 없으면 만들고, 만들어진 directMessageChannel을 다시 가져와 cid를 전달한다
                if (channels.isEmpty) {
                    try! self.chatClient.channelController(
                        createDirectMessageChannelWith: [self.userProfile.chatID!],
                        isCurrentUserMember: true,
                        extraData: ["info": .string("Hello")]
                    ).synchronize { error in
                        if let error = error {
                            print(error)
                        } else {
                            let controller = self.chatClient.channelListController(
                                query: .init(
                                    filter: .and([.equal(.type, to: .messaging), .equal("members", to: [self.userProfile.chatID!, Profile.decode(self.profile).chatID!])])
                                )
                            )
                            
                            controller.synchronize { error in
                                if let error = error {
                                   print(error)
                                } else {
                                    let channels = controller.channels
                                    if !channels.isEmpty {
                                        completion(channels.first?.cid.id ?? "")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    completion(channels.first?.cid.id ?? "")
                }
            }
        }
    }
    
    private func joinTeamChannel(isTeam: Bool) {
        if (isTeam) {
            let channelClient = chatClient.channelController(for: ChannelId(type: .messaging, id: Profile.decode(profile).chatID!))
            channelClient.addMembers(userIds: [userProfile.chatID!])
        } else {
            let channelClient = chatClient.channelController(for: ChannelId(type: .messaging, id: userProfile.chatID!))
            channelClient.addMembers(userIds: [Profile.decode(profile).chatID!])
        }
    }
    
    private func leaveTeamChannel(isTeam: Bool) {
        if (isTeam) {
            let channelClient = chatClient.channelController(for: ChannelId(type: .messaging, id: Profile.decode(profile).chatID!))
            channelClient.removeMembers(userIds: [userProfile.chatID!])
        } else {
            let channelClient = chatClient.channelController(for: ChannelId(type: .messaging, id: userProfile.chatID!))
            channelClient.removeMembers(userIds: [Profile.decode(profile).chatID!])
        }
    }
}
