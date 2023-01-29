//
//  DeepLinkPostDetailViewModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

class DeepLinkPostDetailViewModel: ObservableObject {
    private let api = PostAPI()
    
    @AppStorage("userID") var userID = ""
    @AppStorage("username") var username = ""
    @AppStorage("profile") var profile = ""
    
    @Published var post = Post(userID: "", postCreatedAt: "", userCreatedAt: "", username: "", profileImage: "", yearAndMonth: "", mediaObj: [], content: "", sportHashtag: [], place: "", x: "", y: "", like: [])
    
    @Published var loading = false
    
    @Published var deletedPost = ""
    
    @MainActor func getPost(yearAndMonth: String, postCreatedAt: String) {
        loading = true
        Task {
            do {
                self.post = try await api.getPost(yearAndMonth: yearAndMonth, postCreatedAt: postCreatedAt)
                loading = false
            } catch APIError.requestError(let response) {
                loading = false
                if response.message == "not found" {
                    deletedPost = StringResources.deletedPostMessage
                }
            } catch {
                print(error)
            }
        }
    }
    
    func like() {
        Task {
            do {
                let like = LikeObj(userID: userID, userCreatedAt: Profile.decode(profile).createdAt, username: self.username, postUserID: self.post.userID, postCreatedAt: self.post.postCreatedAt)
                self.post.like = try await api.like(like: like)
            } catch {
                print("\(error)")
            }
        }
    }
    
    func unlike() {
        Task {
            do {
                let like = LikeObj(userID: userID, userCreatedAt: Profile.decode(profile).createdAt, username: self.username, postUserID: self.post.userID, postCreatedAt: self.post.postCreatedAt)
                self.post.like = try await api.unlike(like: like)
            } catch {
                print("\(error)")
            }
        }
    }
}
