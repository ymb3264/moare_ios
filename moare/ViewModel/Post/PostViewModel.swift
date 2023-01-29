//
//  PostViewModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Combine
import SwiftUI
import KeychainAccess
import CoreLocation

class PostViewModel: ObservableObject {
    private let api = PostAPI()
    
    @AppStorage("currentLocation") var currentLocation = ""
    @AppStorage("userID") var userID = ""
    @AppStorage("username") var username = ""
    @AppStorage("profile") var profile = ""
    
    // decoded된 location 주소
    @Published var locationList = [String]()
    
    @Published var selectedImage: UIImage?
    
    @Published var postsList = [PostListObj]()
    var postsData = [Post]()
    var postNum = 6
    
    @Published var loading = false
    @Published var noPost = false
    
    var images = [UIImage]()
    
    @MainActor init() {
        if !currentLocation.isEmpty {
            getPosts()
            
            let list = UserDefaults.standard.stringArray(forKey: "locationList") ?? [String]()
            self.locationList = list.map { item in
                let location = UserDefaultLocation.decode(responseString: item)
                return location.address
            }
        }
    }
    
    @MainActor func getPosts() {
        // noPost가 없이 isEmpty로 하면 처음에 바로 게시물이 없다는 글이 뜬다
        self.loading = true
        self.noPost = false
        postNum = 6
        Task {
            do {
                guard let accessToken = try! Keychain().get("AccessToken") else { return }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM"
                let yearAndMonth = dateFormatter.string(from: Date())
                
                // 하루이내 본인 게시물 위한 변수
                let oneDayBefore = Date(timeInterval: -60*60*24, since: Date())
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
                let date = dateFormatter.string(from: oneDayBefore)
                
                // userDefaults의 locationList중 currentLocation과 같은 encoded UserDefaultLocation
                let locationList = UserDefaults.standard.stringArray(forKey: "locationList") ?? [String]()
                let current = UserDefaults.standard.string(forKey: "currentLocation") ?? ""
                let location = locationList.filter { item in
                    let userDefault = UserDefaultLocation.decode(responseString: item)
                    return current == userDefault.address
                }
                
                let response = try await api.getPosts(
                    accessToken: accessToken,
                    yearAndMonth: yearAndMonth,
                    location: UserDefaultLocation.decode(responseString: location.first!),
                    username: username,
                    date: date)
                
                if response.isEmpty {
                    self.noPost = true
                    return
                }
                
                // 차단한 사용자 게시물 삭제
                var newPostsData = response
                let decodedProfile = Profile.decode(profile)
                if let blockedBy = decodedProfile.blockedBy {
                    for item in newPostsData {
                        let blockedUser = item.userID + "+" + item.userCreatedAt
                        if blockedBy.contains(blockedUser) {
                            newPostsData.remove(at: newPostsData.firstIndex(of: item)!)
                        }
                    }
                }
                
                postsData = newPostsData
                
                let num = postsData.count <= 6 ? postsData.count-1 : postNum-1 // post 개수가 6개이하일때
                
                self.loading = false
                self.postsList.removeAll()
                self.postsList.append(
                    PostListObj(postList: Array(postsData[...num]), isLoaded: false)
                )
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        self.loading = false
                        print("\(networkError)")
                    case .serverError:
                        self.loading = false
                        print("\(networkError)")
                    default:
                        self.loading = false
                        print("\(networkError)")
                    }
                } else {
                    self.loading = false
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
                    //                    newPosts = try await self.getImage(post: Array(postsData[postNum...postsData.count-1]))
                    newPosts = Array(postsData[postNum...postsData.count-1])
                } else if count >= postNum+6 {
                    //                    newPosts = try await self.getImage(post: Array(postsData[postNum...postNum+5]))
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
                
                let locationList = UserDefaults.standard.stringArray(forKey: "locationList") ?? [String]()
                let current = UserDefaults.standard.string(forKey: "currentLocation") ?? ""
                let location = locationList.filter { item in
                    let userDefault = UserDefaultLocation.decode(responseString: item)
                    return current == userDefault.address
                }
                
                let newPostsData = try await api.getMorePosts(
                    yearAndMonth: lastPost.yearAndMonth,
                    location: UserDefaultLocation.decode(responseString: location.first!),
                    createdAt: lastPost.postCreatedAt
                )
                
                postsData = postsData + newPostsData
                loadMorePost()
            } catch {
                
            }
        }
    }
    
    func getImage(post: [Post]) async throws -> [Post] {
        let newPosts = post.map { (post: Post) -> Post in
            var newPost = post
            
            var list = [UIImage]()
            if let obj = post.mediaObj.first {
                if obj.type == "image" {
                    let data = try? Data(contentsOf: URL(string: String(obj.url))!)
                    let image = UIImage(data: data!)
                    list.append(image!)
                }
            }
            
            newPost.uiImage = list
            return newPost
        }
        return newPosts
    }
    
    func setLocationList() {
        let list = UserDefaults.standard.stringArray(forKey: "locationList") ?? [String]()
        self.locationList = list.map { item in
            let location = UserDefaultLocation.decode(responseString: item)
            return location.address
        }
    }
    
    @MainActor func changeCurrentLocation(location: String, cb: @escaping () -> ()) {
        self.currentLocation = location
        cb()
    }
    
    @MainActor func like(post: Post, listIndex: Int, postIndex: Int) {
        Task {
            do {
                // response오기전에 일단 view를 바로 업데이트
                var likeList = postsList[listIndex].postList[postIndex].like ?? []
                likeList.append(username)
                postsList[listIndex].postList[postIndex].like = likeList
                
                let like = LikeObj(userID: userID, userCreatedAt: Profile.decode(profile).createdAt, username: self.username, postUserID: post.userID, postCreatedAt: post.postCreatedAt)
                let newLike = try await api.like(like: like)
                postsList[listIndex].postList[postIndex].like = newLike
            } catch {
                print("\(error)")
            }
        }
    }
    
    @MainActor func unlike(post: Post, listIndex: Int, postIndex: Int) {
        Task {
            do {
                var likeList = postsList[listIndex].postList[postIndex].like ?? []
                if let index = likeList.firstIndex(of: username) {
                    likeList.remove(at: index)
                }
                postsList[listIndex].postList[postIndex].like = likeList
                
                let like = LikeObj(userID: userID, userCreatedAt: Profile.decode(profile).createdAt, username: self.username, postUserID: post.userID, postCreatedAt: post.postCreatedAt)
                let newLike = try await api.unlike(like: like)
                postsList[listIndex].postList[postIndex].like = newLike
            } catch {
                print("\(error)")
            }
        }
    }
    
    @MainActor func reportPost(post: Post, cb: @escaping () -> ()) {
        Task {
            do {
                guard let accessToken = try! Keychain().get("AccessToken") else { return }
                
                let obj = [
                    "userID": post.userID,
                    "createdAt": post.postCreatedAt,
                    "userCreatedAt": Profile.decode(profile).createdAt
                ]
                let respone = try await api.reportPost(accessToken: accessToken, obj: obj)
                
                if respone.message == "report success" {
                    cb()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func removeReportedPost(listIndex: Int, postIndex: Int) {
        postsList[listIndex].postList.remove(at: postIndex)
    }
}

