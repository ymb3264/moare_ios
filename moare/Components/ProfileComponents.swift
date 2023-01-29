//
//  Profile.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import NukeUI
import AVKit

struct ProfileButton: View {
    var text: String
    var enabled: Bool = true
    var loading = false
    var action: () -> () = {}
    
    var body: some View {
        Button(action: action) {
            Rectangle()
                .fill(enabled ? Color("moare") : .secondary)
                .frame(width: 2, height: 30)
            
            if loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .tint(enabled ? Color("moare") : .secondary)
            } else {
                Text(text)
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .font(.body)
                    .foregroundColor(enabled ? Color("moare") : .secondary)
            }
            
            Rectangle()
                .fill(enabled ? Color("moare") : .secondary)
                .frame(width: 2, height: 30)
        }
    }
}

struct ProfileImageAddButton: View {
    @Binding var image: UIImage
    var profileImage: String = ""
    @Binding var isDefaultImage: Bool
    var action1: () -> () = {}
    var action2: () -> () = {}
    
    var body: some View {
        if isDefaultImage {
            Button(action: action1) {
                Circle()
                    .stroke()
                    .foregroundColor(.secondary)
                    .frame(maxWidth: 180, maxHeight: 180)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(.white)
                                .frame(height: 2)
                                .blendMode(.multiply)
                            
                            Circle()
                                .trim(from: 0.5, to: 1)
                                .rotation(.degrees(90))
                                .stroke()
                                .foregroundColor(.secondary)
                                .frame(width: 70, height: 70)
                            
                            Rectangle()
                                .foregroundColor(.secondary)
                                .frame(height: 2)
                        }
                    )
                    .overlay(
                        Text(StringResources.addProfilePhoto)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    )
            }
        } else if image != UIImage() || !profileImage.isEmpty {
            Menu {
                Button("라이브러리에서 선택") { action1() }
                Button("기본이미지로 변경") { action2() }
            } label: {
                    Circle()
                        .stroke()
                        .foregroundColor(.secondary)
                        .frame(maxWidth: 180, maxHeight: 180)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(.white)
                                    .frame(height: 2)
                                    .blendMode(.multiply)
                                
                                Circle()
                                    .trim(from: 0.5, to: 1)
                                    .rotation(.degrees(90))
                                    .stroke()
                                    .foregroundColor(.secondary)
                                    .frame(width: 70, height: 70)
                                
                                Rectangle()
                                    .foregroundColor(.secondary)
                                    .frame(height: 2)
                            }
                        )
                        .overlay(
                            Text(StringResources.addProfilePhoto)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        )
                        .overlay {
                            if image != UIImage() {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.white))
                            } else if !profileImage.isEmpty {
                                LazyImage(
                                    url: URL(string: profileImage),
                                    resizingMode: .aspectFit
                                )
                                .frame(maxWidth: 180, maxHeight: 180)
                                .clipShape(Circle())
                            }
                        }
            }
        } else {
            Button(action: action1) {
                Circle()
                    .stroke()
                    .foregroundColor(.secondary)
                    .frame(maxWidth: 180, maxHeight: 180)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(.white)
                                .frame(height: 2)
                                .blendMode(.multiply)
                            
                            Circle()
                                .trim(from: 0.5, to: 1)
                                .rotation(.degrees(90))
                                .stroke()
                                .foregroundColor(.secondary)
                                .frame(width: 70, height: 70)
                            
                            Rectangle()
                                .foregroundColor(.secondary)
                                .frame(height: 2)
                        }
                    )
                    .overlay(
                        Text(StringResources.addProfilePhoto)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    )
                    .overlay {
                        if image != UIImage() {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.white))
                        } else if !profileImage.isEmpty {
                            AsyncImage(
                                url: URL(string: profileImage),
                                content: { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 180, height: 180)
                                        .clipShape(Circle())
                                },
                                placeholder: {
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 140))
                                        .foregroundColor(.secondary)
                                        .frame(width: 180, height: 180)
                                }
                            )
                        }
                    }
            }
        }
    }
}

struct FollowListTabBarButton: View {
    @Binding var selection: Selected
    var tab: Selected
    let namespace: Namespace.ID
    
    var body: some View {
        Button(action: {
            selection = tab
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .stroke()
                    .fill(.white.opacity(0))
                    .frame(height: 50)
                    .overlay(
                        Text(tab.tabName)
                            .font(.body)
                            .foregroundColor(
                                selection == tab ? Color("moare") : .secondary
                            )
                    )
                
                if selection == tab {
                    RoundedRectangle(cornerRadius: 30)
                        .stroke()
                        .fill(Color("moare"))
                        .matchedGeometryEffect(id: "button", in: namespace)
                        .frame(height: 50)
                }
            }
            .animation(.spring(), value: selection)
            
        }

    }
}

struct ProfileTextField: View {
    var placeholder: String
    @Binding var text: String
    var readOnly = false
    var required = false
    var filled = false
    var infoRequired = false
    var infoAlertAction: () -> () = {}
    
    var body: some View {
        HStack {
            if required {
                Rectangle()
                    .fill(Color("moare"))
                    .frame(maxWidth: 1, maxHeight: filled ? .infinity : 5)
                    .animation(.spring(), value: filled)
            }
            
            if infoRequired {
                Button {
                    infoAlertAction()
                } label: {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.secondary)
                }
            }
            
            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .disabled(readOnly)
                .overlay {
                    if readOnly {
                        HStack(spacing: 2) {
                            Text(text)
                                .font(.subheadline)
                                .opacity(0)
                            
                            Text(StringResources.hostPlaceholder)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
        .padding(.horizontal)
    }
}

struct ProfileUsernameTextField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var loading: Bool
    var readOnly = false
    var required = false
    var filled = false
    var infoRequired = false
    
    var body: some View {
        HStack {
            if required {
                Rectangle()
                    .fill(Color("moare"))
                    .frame(maxWidth: 1, maxHeight: filled ? .infinity : 5)
                    .animation(.spring(), value: filled)
            }
            
            if infoRequired {
                Button {
                    
                } label: {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.secondary)
                }
            }
            
            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .disabled(readOnly)
            
            if loading {
                ProgressView()
                    .padding(.trailing, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
        .padding(.horizontal)
    }
}

struct ProfilePostListView: View {
    @ObservedObject var profileVM: MyProfileViewModel
    
    var body: some View {
        if profileVM.postNetworkError {
            Text(StringResources.failedToGetUserPost)
                .font(.body)
        } else {
            ScrollView {
                if profileVM.postLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 0) {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                            profileVM.getUserPosts()
                        }
                        
                        ForEach(profileVM.postsList.indices, id: \.self) { i in
                            let posts = profileVM.postsList[i].postList
                            
                            LazyVStack(spacing: 2) {
                                HStack(spacing: 2) {
                                    if posts.count > 0 {
                                        ProfilePostListItemView(post: posts[0], listIndex: i, postIndex: 0)
                                        if posts.count > 1 {
                                            ProfilePostListItemView(post: posts[1], listIndex: i, postIndex: 1)
                                        } else {
                                            EmptyPostView(text: "")
                                        }
                                    }
                                }
                                
                                HStack(spacing: 2) {
                                    if posts.count > 2 {
                                        ProfilePostListItemView(post: posts[2], listIndex: i, postIndex: 2)
                                        if posts.count > 3 {
                                            ProfilePostListItemView(post: posts[3], listIndex: i, postIndex: 3)
                                        } else {
                                            EmptyPostView(text: "")
                                        }
                                    }
                                }
                                
                                HStack(spacing: 2) {
                                    if posts.count > 4 {
                                        ProfilePostListItemView(post: posts[4], listIndex: i, postIndex: 4)
                                            .onAppear {
                                                if !profileVM.postsList[i].isLoaded {
                                                    profileVM.loadMorePost()
                                                    profileVM.postsList[i].isLoaded = true
                                                }
                                            }
                                        if posts.count > 5 {
                                            ProfilePostListItemView(post: posts[5], listIndex: i, postIndex: 5)
                                        } else {
                                            EmptyPostView(text: "")
                                        }
                                    }
                                }
                            } // lazyvstack
                        } // foreach
                    } // vstack
                } // if else - loading
            } // scrollView
            .coordinateSpace(name: "pullToRefresh")
        } // if else - error
    }
}

struct ProfilePostListItemView: View {
    let post: Post
    let listIndex: Int
    let postIndex: Int
    
    @State var videoDetail = false
    @State var imageDetail = false
    
    var body: some View {
        if post.mediaObj.first?.type == "video" {
            NavigationLink(
                isActive: $videoDetail,
                destination: {
                    NavigationLazyView(ProfilePostDetailView(
                        post: post,
                        listIndex: listIndex,
                        postIndex: postIndex
                    ))
                }
            ) {
                Rectangle()
                    .fill(.white)
                    .aspectRatio(0.5625, contentMode: .fit)
                    .overlay(
                        ZStack {
                            Rectangle()
                                .fill(.white)
                                .blendMode(.multiply)
                                .background {
                                    ShadowView(
                                        offset: CGSize(width: 0, height: -30),
                                        width: 2000,
                                        height: 0
                                    )
                                }
                            
                            CustomVideoPlayer(player: AVPlayer(url: URL(string: post.mediaObj.first!.url)!))
                                .blendMode(.multiply)
                            
                            VStack {
                                HStack(spacing: 0) {
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.gray)
                                        .opacity(0.7)
                                        .padding(4)
                                        .frame(width: 30, height: 30)
                                        .overlay {
                                            Image(systemName: "play")
                                                .foregroundColor(.white)
                                                .font(.caption)
                                        }
                                    
                                    if post.mediaObj.count > 1 {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(.gray)
                                            .opacity(0.7)
                                            .padding(4)
                                            .frame(width: 30, height: 30)
                                            .overlay {
                                                Text("+\(post.mediaObj.count)")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            }
                                    }
                                }
                                
                                Spacer()
                                
                                HStack {
                                    Text(post.content)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Text(String(post.place.split(separator: " ").last!))
                                        .font(.subheadline)
                                }
                                .padding(EdgeInsets(top: 0, leading: 4, bottom: 4, trailing: 4))
                                .foregroundColor(.white)
                            }
                        }
                    )
            } // navigationlink
            .disabled(true)
            .onTapGesture {
                self.videoDetail = true
            }
        } else {
            NavigationLink(
                isActive: $imageDetail,
                destination: {
                    NavigationLazyView(ProfilePostDetailView(
                        post: post,
                        listIndex: listIndex,
                        postIndex: postIndex
                    ))
                }
            ) {
                Rectangle()
                    .fill(.white)
                    .aspectRatio(0.5625, contentMode: .fit)
                    .overlay(
                        ZStack {
                            Rectangle()
                                .fill(.white)
                                .blendMode(.multiply)
                                .background {
                                    ShadowView(
                                        offset: CGSize(width: 0, height: -30),
                                        width: 2000,
                                        height: 0
                                    )
                                }
                            
                            LazyImage(
                                url: URL(string: post.mediaObj.first?.url ?? ""),
                                resizingMode: .aspectFit
                            )
                            .blendMode(.multiply)
                            
                            VStack {
                                if post.mediaObj.count > 1 {
                                    HStack {
                                        Spacer()
                                        
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(.gray)
                                            .opacity(0.7)
                                            .padding(4)
                                            .frame(width: 30, height: 30)
                                            .overlay {
                                                Text("+\(post.mediaObj.count)")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            }
                                    }
                                }
                                
                                Spacer()
                                
                                HStack {
                                    Text(post.content)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Text(String(post.place.split(separator: " ").last!))
                                        .font(.subheadline)
                                }
                                .padding(EdgeInsets(top: 0, leading: 4, bottom: 4, trailing: 4))
                                .foregroundColor(.white)
                            }
                        }
                    )
            }
            .disabled(true)
            .onTapGesture {
                self.imageDetail = true
            }
        } // if else
    }
}

struct UserProfilePostListView: View {
    @StateObject var profileVM: UserProfileViewModel
    
    var body: some View {
        if profileVM.postNetworkError {
            Text(StringResources.failedToGetUserPost)
                .font(.body)
        } else {
            ScrollView {
                if profileVM.postLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 0) {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                            profileVM.getUserPosts()
                        }
                        
                        ForEach(profileVM.postsList.indices, id: \.self) { i in
                            let posts = profileVM.postsList[i].postList
                            
                            LazyVStack(spacing: 2) {
                                HStack(spacing: 2) {
                                    if posts.count > 0 {
                                        UserProfilePostListItemView(profileVM: profileVM, post: posts[0], listIndex: i, postIndex: 0)
                                        if posts.count > 1 {
                                            UserProfilePostListItemView(profileVM: profileVM, post: posts[1], listIndex: i, postIndex: 1)
                                        } else {
                                            EmptyPostView(text: "")
                                        }
                                    }
                                }
                                
                                HStack(spacing: 2) {
                                    if posts.count > 2 {
                                        UserProfilePostListItemView(profileVM: profileVM, post: posts[2], listIndex: i, postIndex: 2)
                                        if posts.count > 3 {
                                            UserProfilePostListItemView(profileVM: profileVM, post: posts[3], listIndex: i, postIndex: 3)
                                        } else {
                                            EmptyPostView(text: "")
                                        }
                                    }
                                }
                                
                                HStack(spacing: 2) {
                                    if posts.count > 4 {
                                        UserProfilePostListItemView(profileVM: profileVM, post: posts[4], listIndex: i, postIndex: 4)
                                            .onAppear {
                                                if !profileVM.postsList[i].isLoaded {
                                                    profileVM.loadMorePost()
                                                    profileVM.postsList[i].isLoaded = true
                                                }
                                            }
                                        if posts.count > 5 {
                                            UserProfilePostListItemView(profileVM: profileVM, post: posts[5], listIndex: i, postIndex: 5)
                                        } else {
                                            EmptyPostView(text: "")
                                        }
                                    }
                                }
                            } // lazyvstack
                        } // foreach
                    } // vstack
                    .environmentObject(profileVM)
                } // if else - loading
            } // scrollView
            .coordinateSpace(name: "pullToRefresh")
        } // if else - error
    }
}

struct UserProfilePostListItemView: View {
    @StateObject var profileVM: UserProfileViewModel
    
    let post: Post
    let listIndex: Int
    let postIndex: Int
    
    @State var videoDetail = false
    @State var imageDetail = false
    
    var body: some View {
        if post.mediaObj.first?.type == "video" {
            NavigationLink(
                isActive: $videoDetail,
                destination: {
                    NavigationLazyView(UserProfilePostDetailView(
                            profileVM: profileVM,
                            post: post,
                            listIndex: listIndex,
                            postIndex: postIndex
                    ))
                }
            ) {
                Rectangle()
                    .fill(.white)
                    .aspectRatio(0.5625, contentMode: .fit)
                    .overlay(
                        ZStack {
                            Rectangle()
                                .fill(.white)
                                .blendMode(.multiply)
                                .background {
                                    ShadowView(
                                        offset: CGSize(width: 0, height: -30),
                                        width: 2000,
                                        height: 0
                                    )
                                }
                            
                            CustomVideoPlayer(player: AVPlayer(url: URL(string: post.mediaObj.first!.url)!))
                                .blendMode(.multiply)
                            
                            VStack {
                                HStack(spacing: 0) {
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.gray)
                                        .opacity(0.7)
                                        .padding(4)
                                        .frame(width: 30, height: 30)
                                        .overlay {
                                            Image(systemName: "play")
                                                .foregroundColor(.white)
                                                .font(.caption)
                                        }
                                    
                                    if post.mediaObj.count > 1 {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(.gray)
                                            .opacity(0.7)
                                            .padding(4)
                                            .frame(width: 30, height: 30)
                                            .overlay {
                                                Text("+\(post.mediaObj.count)")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            }
                                    }
                                }
                                
                                Spacer()

                                HStack {
                                    Text(post.content)
                                        .font(.subheadline)
                                        .lineLimit(1)

                                    Spacer()

                                    Text(String(post.place.split(separator: " ").last!))
                                        .font(.subheadline)
                                }
                                .padding(EdgeInsets(top: 0, leading: 4, bottom: 4, trailing: 4))
                                .foregroundColor(.white)
                            }
                        }
                    )
            } // navigationlink
            .disabled(true)
            .onTapGesture {
                self.videoDetail = true
            }
        } else {
            NavigationLink(
                isActive: $imageDetail,
                destination: {
                    NavigationLazyView(UserProfilePostDetailView(
                        profileVM: profileVM,
                        post: post,
                        listIndex: listIndex,
                        postIndex: postIndex
                    ))
                }
            ) {
                Rectangle()
                    .fill(.white)
                    .aspectRatio(0.5625, contentMode: .fit)
                    .overlay(
                        ZStack {
                            Rectangle()
                                .fill(.white)
                                .blendMode(.multiply)
                                .background {
                                    ShadowView(
                                        offset: CGSize(width: 0, height: -30),
                                        width: 2000,
                                        height: 0
                                    )
                                }
                            
                            LazyImage(
                                url: URL(string: post.mediaObj.first?.url ?? ""),
                                resizingMode: .aspectFit
                            )
                            .blendMode(.multiply)

                            VStack {
                                if post.mediaObj.count > 1 {
                                    HStack {
                                        Spacer()
                                        
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(.gray)
                                            .opacity(0.7)
                                            .padding(4)
                                            .frame(width: 30, height: 30)
                                            .overlay {
                                                Text("+\(post.mediaObj.count)")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            }
                                    }
                                }
                                
                                Spacer()

                                HStack {
                                    Text(post.content)
                                        .font(.subheadline)
                                        .lineLimit(1)

                                    Spacer()

                                    Text(String(post.place.split(separator: " ").last!))
                                        .font(.subheadline)
                                }
                                .padding(EdgeInsets(top: 0, leading: 4, bottom: 4, trailing: 4))
                                .foregroundColor(.white)
                            }
                        }
                    ) // overlay
            } // navigationlink
            .disabled(true)
            .onTapGesture {
                self.imageDetail = true
            }
        } // if else
    }
}
