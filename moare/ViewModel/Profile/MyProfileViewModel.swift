//
//  ProfileViewModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import KeychainAccess
import StreamChat
import StreamChatSwiftUI

class MyProfileViewModel: ObservableObject {
    private let api = ProfileAPI()
    private let postAPI = PostAPI()
    
    @Environment(\.presentationMode) var presentationMode
    
    // appstorage변수에 값을 넣으면 해당 변수는 다른곳에서 값을 바꿨을때 반영이 안된다
    @AppStorage("userID") var userID = ""
    @AppStorage("username") var username = ""
    @AppStorage("profile") var profile = ""
    @AppStorage("currentLocation") var currentLocation = ""
    
    @Published var myProfile = Profile(createdAt: "", chatToken: "", username: "", name: "", profileImage: "", content: "", place: "", isTeam: false, follower: [], following: [], teamOrMember: [])
    @Published var newTeamProfile = CreateTeamProfile(createdAt: "", username: "", name: "", profileImage: "", content: "", place: "", isTeam: true)
    @Published var updatedUserProfile = UpdateProfile(createdAt: "", username: "", name: "", profileImage: "", content: "", place: "")
    
    @Published var myAccounts = [Profile]()
    
    @Published var teamCompleteBtnEnabled = false
    @Published var updateCompleteBtnEnabled = true
    
    @Published var showErrorText = false
    @Published var showErrorText2 = false
    
    @Published var loading = false
    @Published var usernameLoading = false
    @Published var postLoading = false
    
    @Published var profileNetworkError = false
    @Published var postNetworkError = false
    @Published var accountsNetworkError = false
    
    @Published var messageTarget = ""
    
    // userPosts
    @Published var postsList = [PostListObj]()
    var postNum = 6
    var postsData = [Post]()
    
    @Published var scrollY:CGFloat = 0
    @Published var newScrollY:CGFloat = 0
    
    @Injected(\.chatClient) var chatClient
    
    @MainActor init() {
        getMyProfile()
        getUserPosts()
    }
    
    @MainActor func getMyProfile() {
        Task {
            do {
                guard let token = try Keychain().get("AccessToken") else { return }
                let response = try await api.getMyProfile(token: token, username: self.username)
                
                // 처음 userdefaults profile 초기화
                self.profile = response.encoded()
                self.myProfile = response
                setUpdatedUserProfile(profile: response)
                
                // accounts가져오고 accounts이용해서 현재 profile에 chatId설정하고 chat연결
                getMyAccounts()
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        self.profileNetworkError = true
                        print("\(error)")
                    case .serverError:
                        self.profileNetworkError = true
                        print("\(error)")
                    default:
                        self.profileNetworkError = true
                        print("\(error)")
                    }
                } else {
                    self.profileNetworkError = true
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
                self.postsData = try await api.getUserPosts(userID: userID, username: username)

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
                
                let newPostsData = try await api.getMoreUserPosts(userID: userID, username: username, createdAt: lastPost.postCreatedAt)
                
                postsData = postsData + newPostsData
                loadMorePost()
            } catch {
                
            }
        }
    }
    
    @MainActor func createTeamProfile(profileImage: UIImage, close: @escaping () -> ()) {
        self.loading = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        self.newTeamProfile.createdAt = dateFormatter.string(from: Date())

        Task {
            do {
                guard let token = try! Keychain().get("AccessToken") else { return }
                
                let followObj = FollowObj(userID: myProfile.userID!, createdAt: myProfile.createdAt, profileImage: myProfile.profileImage, username: myProfile.username)
                self.newTeamProfile.follow = followObj
                
                // host createdAt for hostChatId
                let hostCreatedAt = myProfile.createdAt.components(separatedBy: [":"]).joined()
                
                let response = try await api.createTeamProfile(token: token, profile: self.newTeamProfile, profileImage: profileImage)
                
                // profile 정보 업데이트
                self.username = response.username
                self.profile = response.encoded()
                self.myProfile = response
                setUpdatedUserProfile(profile: response)
                
                // get accounts and set chat
                getMyAccounts(createTeamChannel: true, hostChatId: myProfile.userID!.components(separatedBy: ["@","."]).joined() + "_\(hostCreatedAt)")
                
                // post초기화
                self.postsList = [PostListObj]()
                self.postNum = 6
                self.postsData = [Post]()
                
                close()
                // teamProfileCreateView 초기화
                self.newTeamProfile = CreateTeamProfile(createdAt: "", username: "", name: "", profileImage: "", content: "", place: "", isTeam: true)
                self.loading = false
                self.teamCompleteBtnEnabled = false
            } catch {
                // toast error
                self.loading = false
                print("\(error)")
            }
        }
    }
    
    @MainActor func updateProfile(selectedImage: UIImage, completion: @escaping () -> ()) {
        self.loading = true
        Task {
            do {
                if !checkUpdateContent(image: selectedImage) {
                    guard let token = try Keychain().get("AccessToken") else { return }
                    let updateProfile = RequestUpdateProfile(newProfile: updatedUserProfile, beforeProfile: myProfile)
                    
                    // 기본이미지로 변경 후 다시 새로운 이미지 넣었을때 
                    if selectedImage != UIImage() {
                        updatedUserProfile.shouldUpdateDefaultImage = false
                    }
                    
                    let response = try await api.updateProfile(token: token, profile: updateProfile, selectedImage: selectedImage)
                    self.username = response.username
                    self.profile = response.encoded()
                    self.myProfile = response
                    setUpdatedUserProfile(profile: response)
                    
                    // main post refresh and my post refresh
                    getUserPosts()
                    
                    // get accounts and set chat
                    getMyAccounts()
                    
                    // profile이 team일때 team 채팅방 name, profileImage update
                    if myProfile.isTeam {
                        updateTeamChannel(name: response.name, profileImage: URL(string: response.profileImage))
                    }
                }
                
                completion()
                self.loading = false
                self.updateCompleteBtnEnabled = true
            } catch {
                // toast error
                self.loading = false
                print("\(error)")
            }
        }
    }
    
    @MainActor func getMyAccounts(createTeamChannel: Bool = false, hostChatId: String = "") {
        Task {
            do {
                guard let token = try! Keychain().get("AccessToken") else { return }
                self.myAccounts = try await api.getMyAccounts(token: token)
                
                setChatIdAndConnectChat(createTeamChannel: createTeamChannel, hostChatId: hostChatId)
                
                let encodedAccounts = self.myAccounts.map { account in
                    return account.encoded()
                }
                UserDefaults.standard.set(encodedAccounts, forKey: "accounts")
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        self.accountsNetworkError = true
                    case .serverError:
                        self.accountsNetworkError = true
                    default:
                        self.accountsNetworkError = true
                    }
                } else {
                    self.accountsNetworkError = true
                    print("\(error)")
                }
            }
        }
    }
    
    func refreshAccounts() {
        let encodedAccounts = UserDefaults.standard.array(forKey: "accounts") ?? [String]()
        self.myAccounts = encodedAccounts.map { account in
            return Profile.decode(account as! String)
        }
    }
    
    @MainActor func checkUsername(username: String) {
        let usernameRegex = "[A-Za-z_.[0-9]]{1,30}"
        showErrorText = !NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: username)
        
        checkCompleteBtn(isTeam: false)
        if (!showErrorText && self.username != username) {
            checkUsername2(username: username, isTeam: false)
        }
    }
    
    @MainActor func checkTeamUsername(username: String) {
        let usernameRegex = "[A-Za-z_.[0-9]]{1,30}"
        if !username.isEmpty {
            showErrorText = !NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: username)
        }
        
        checkCompleteBtn(isTeam: true)
        if (!showErrorText) {
            checkUsername2(username: username, isTeam: true)
        }
    }
    
    @MainActor func checkUsername2(username: String, isTeam: Bool) {
        let joinApi = JoinAPI()
        
        self.usernameLoading = true
        Task {
            do {
                let response = try await joinApi.checkUsername(username: username)
                
                self.usernameLoading = false
                if response.message == "available" {
                    self.showErrorText2 = false
                    checkCompleteBtn(isTeam: isTeam)
                }
            } catch {
                self.usernameLoading = false
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        self.showErrorText2 = true
                        checkCompleteBtn(isTeam: isTeam)
                        print("\(error)")
                    case .serverError:
                        print("\(error)")
                    default:
                        print("\(error)")
                    }
                } else {
                    print("\(error)")
                }
            }
        }
    }
    
    @MainActor func changeProfile(username: String, cb: @escaping () -> () = {}) {
        self.username = username
        getMyProfile()
        getUserPosts()
        
//        let location = UserDefaults.standard.string(forKey: "currentLocation") ?? ""
//        currentLocation = ""
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.currentLocation = location
//        }
        
        AppState.shared.postRootActive = false
        AppState.shared.postSearchBar = false
        
        cb()
    }
    
    func checkCompleteBtn(isTeam: Bool) {
        if isTeam {
            self.teamCompleteBtnEnabled = !username.isEmpty && (!showErrorText && !showErrorText2) && !newTeamProfile.username.isEmpty && !newTeamProfile.name.isEmpty
        } else {
            self.updateCompleteBtnEnabled = !showErrorText && !showErrorText2
        }
    }
    
    func getImage(post: [Post]) async throws -> [Post] {
        let newPosts = post.map { (post: Post) -> Post in
            var newPost = post
            
            var list = [UIImage]()
            for obj in post.mediaObj {
                if obj.type == "image" {
                    let data = try? Data(contentsOf: URL(string: "\(obj.url)")!)
                    let image = UIImage(data: data!)
                    list.append(image!)
                }
            }
            newPost.uiImage = list
            return newPost
        }
        return newPosts
    }
    
    func resetTeamProfile() {
        self.newTeamProfile = CreateTeamProfile(createdAt: "", username: "", name: "", profileImage: "", content: "", place: "", isTeam: true)
        self.showErrorText = false
        self.showErrorText2 = false
        self.teamCompleteBtnEnabled = false
    }
    
    func resetUpdateProfile() {
        setUpdatedUserProfile(profile: self.myProfile)
        self.showErrorText = false
        self.showErrorText2 = false
        self.updateCompleteBtnEnabled = true
    }
    
    func checkTeamContent(image: UIImage) -> Bool {
        let profile = CreateTeamProfile(createdAt: "", username: "", name: "", profileImage: "", content: "", place: "", isTeam: true)
        return image == UIImage() && profile == self.newTeamProfile
    }
    
    func checkUpdateContent(image: UIImage) -> Bool {
        var profile = UpdateProfile(createdAt: "", username: "", name: "", profileImage: "", content: "", place: "")
        
        profile.createdAt = self.myProfile.createdAt
        profile.username = self.myProfile.username
        profile.sportHashtag = self.myProfile.sportHashtag
        profile.name = self.myProfile.name
        profile.profileImage = self.myProfile.profileImage
        profile.content = self.myProfile.content
        profile.place = self.myProfile.place
        
        return image == UIImage() && profile == updatedUserProfile
    }
    
    func setUpdatedUserProfile(profile: Profile) {
        self.updatedUserProfile.createdAt = profile.createdAt
        self.updatedUserProfile.username = profile.username
        self.updatedUserProfile.sportHashtag = profile.sportHashtag
        self.updatedUserProfile.name = profile.name
        self.updatedUserProfile.profileImage = profile.profileImage
        self.updatedUserProfile.content = profile.content
        self.updatedUserProfile.place = profile.place
    }
    
    func like(post: Post, listIndex: Int, postIndex: Int) {
        Task {
            do {
                var likeList = postsList[listIndex].postList[postIndex].like ?? []
                likeList.append(username)
                postsList[listIndex].postList[postIndex].like = likeList
                
                let like = LikeObj(userID: userID, userCreatedAt: Profile.decode(profile).createdAt, username: self.username, postUserID: post.userID, postCreatedAt: post.postCreatedAt)
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
                if let index = likeList.firstIndex(of: username) {
                    likeList.remove(at: index)
                }
                postsList[listIndex].postList[postIndex].like = likeList
                
                let like = LikeObj(userID: userID, userCreatedAt: Profile.decode(profile).createdAt, username: self.username, postUserID: post.userID, postCreatedAt: post.postCreatedAt)
                let newLike = try await postAPI.unlike(like: like)
                postsList[listIndex].postList[postIndex].like = newLike
            } catch {
                print("\(error)")
            }
        }
    }
    
    @MainActor func deleteProfile(completion: @escaping () -> () = {}) {
        loading = true
        Task {
            do {
                guard let token = try Keychain().get("AccessToken") else { return }
                
                try await api.deleteProfile(token: token, profile: myProfile)
                
                if myProfile.isTeam {
                    let encodedAccounts = UserDefaults.standard.array(forKey: "accounts") ?? [String]()
                    if !encodedAccounts.isEmpty {
                        let userAccount = Profile.decode(encodedAccounts.first as! String)
                        changeProfile(username: userAccount.username)
                        AppState.shared.profileRootActive = false
                        completion()
                    }
                } else {
                    AppState.shared.logout()
                    UserDefaults.standard.set("", forKey: "currentLocation")
                    UserDefaults.standard.set([String](), forKey: "locationList")
                    UserDefaults.standard.set("", forKey: "username")
                    UserDefaults.standard.set("", forKey: "userID")
                    UserDefaults.standard.set("", forKey: "profile")
                    UserDefaults.standard.set([String](), forKey: "accounts")
                }
                loading = false
            } catch {
                loading = false
                print("\(error)")
            }
        }
    }
    
    func updatePost(updatePost: UpdatePost, listIndex: Int, postIndex: Int, completion: @escaping () -> ()) {
        loading = true
        Task {
            do {
                guard let token = try! Keychain().get("AccessToken") else { return }
                
                let newPost = try await postAPI.updatePost(token: token, post: updatePost)
                postsList[listIndex].postList[postIndex] = newPost
                completion()
                loading = false
            } catch {
                loading = false
            }
        }
    }
    
    func deletePost(post: Post, listIndex: Int, postIndex: Int) {
        loading = true
        Task {
            do {
                guard let token = try! Keychain().get("AccessToken") else { return }
                
                try await postAPI.deletePost(token: token, post: post)
                
                postsList[listIndex].postList.remove(at: postIndex)
                // 24시간 이내 게시물이면 getPosts다시 또는 사용자가 refresh
                loading = false
            } catch {
                loading = false
                print(error)
            }
        }
    }
    
    // chat
    func setChatIdAndConnectChat(createTeamChannel: Bool = false, hostChatId: String = "") {
        let chatToken = try! Token(rawValue: myProfile.chatToken!)
        
        var newProfile = Profile.decode(profile)
        let chatID = myProfile.userID!.components(separatedBy: ["@","."]).joined() + "_\(myProfile.createdAt.components(separatedBy: [":"]).joined())"
        newProfile.chatID = chatID
        
        profile = newProfile.encoded()
        myProfile.chatID = chatID
        
        chatClient.disconnect()
        chatClient.connectUser(
            userInfo: .init(id: myProfile.chatID!,
                            name: myProfile.username,
                            imageURL: URL(string: myProfile.profileImage)),
            token: chatToken
        ) { error in
            if let error = error {
                log.error("connecting the user failed \(error)")
                return
            } else {
                if createTeamChannel {
                    self.createTeamChannel(channelId: self.myProfile.chatID!, hostChatId: hostChatId)
                }
            }
        }
    }
    
    func createTeamChannel(channelId: String, hostChatId: String) {
        try! chatClient.channelController(
            createChannelWithId: ChannelId(type: .messaging, id: channelId),
            name: self.myProfile.name,
            imageURL: URL(string: self.myProfile.profileImage),
            members: [hostChatId],
            isCurrentUserMember: true,
            messageOrdering: .topToBottom,
            extraData: ["info": .string("Hello")]
        ).synchronize()
    }
    
    func updateTeamChannel(name: String, profileImage: URL?) {
        let controller = chatClient.channelController(for: .init(type: .messaging, id: myProfile.chatID!))
        
        controller.updateChannel(name: name, imageURL: profileImage, team: nil) { error in
            if let error = error {
                print(error)
            }
        }
    }
}
