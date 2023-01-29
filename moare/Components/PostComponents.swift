//
//  Post.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import AVKit
import NukeUI

struct PostListView: View {
    @EnvironmentObject var postVM: PostViewModel
    
    var body: some View {
        if postVM.noPost {
            Text(StringResources.noPostInCurrentLocation)
                .font(.body)
        } else {
            ScrollView {
                if postVM.loading {
                    ProgressView()
                } else {
                    VStack(spacing: 0) {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                            postVM.getPosts()
                        }
                        
                        ForEach(postVM.postsList.indices, id: \.self) { i in
                            let posts = postVM.postsList[i].postList
                            
                            LazyVStack(spacing: 2) {
                                HStack(spacing: 2) {
                                    if posts.count > 0 {
                                        PostListItemView(post: posts[0], listIndex: i, postIndex: 0)
                                        if posts.count > 1 {
                                            PostListItemView(post: posts[1], listIndex: i, postIndex: 1)
                                        } else {
                                            EmptyPostView()
                                        }
                                    }
                                }
                                
                                HStack(spacing: 2) {
                                    if posts.count > 2 {
                                        PostListItemView(post: posts[2], listIndex: i, postIndex: 2)
                                        if posts.count > 3 {
                                            PostListItemView(post: posts[3], listIndex: i, postIndex: 3)
                                        } else {
                                            EmptyPostView()
                                        }
                                    }
                                }
                                
                                HStack(spacing: 2) {
                                    if posts.count > 4 {
                                        PostListItemView(post: posts[4], listIndex: i, postIndex: 4)
                                            .onAppear {
                                                if !postVM.postsList[i].isLoaded {
                                                    postVM.loadMorePost()
                                                    postVM.postsList[i].isLoaded = true
                                                }
                                            }
                                        if posts.count > 5 {
                                            PostListItemView(post: posts[5], listIndex: i, postIndex: 0)
                                        } else {
                                            EmptyPostView()
                                        }
                                    }
                                }
                            } // lazyvstack
                        } // foreach
                    } // vstack
                } // if else - loading
            } // scrollview
            .coordinateSpace(name: "pullToRefresh")
        } // if else - nopost
    }
}

struct PostListItemView: View {
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
                    NavigationLazyView(PostDetailView(
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
                    NavigationLazyView(PostDetailView(
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

struct EmptyPostView: View {
    var text = StringResources.noMorePost
    
    var body: some View {
        ZStack {
            Rectangle()
                .opacity(0)
                .aspectRatio(0.5625, contentMode: .fit)
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct MediaPickerView: View {
    var placeholder: String = ""
    var infoRequired = false
    var infoAlertAction: () -> () = {}
    var isPreview: Bool = false
    @StateObject var mediaItems: PickedMediaItems
    @ObservedObject var postCreatVM: PostCreateViewModel
    
    var body: some View {
        Rectangle()
            .fill(.white)
            .aspectRatio(0.5625, contentMode: .fit)
            .overlay(
                VStack {
                    HStack {
                        Circle()
                            .foregroundColor(.secondary)
                            .frame(width: 5, height: 5)
                        
                        Spacer()
                        
                        Circle()
                            .foregroundColor(.secondary)
                            .frame(width: 5, height: 5)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Circle()
                            .foregroundColor(.secondary)
                            .frame(width: 5, height: 5)
                        
                        Spacer()
                        
                        Circle()
                            .foregroundColor(.secondary)
                            .frame(width: 5, height: 5)
                    }
                }
            )
            .overlay(
                HStack {
                    if infoRequired {
                        Button {
                            infoAlertAction()
                        } label: {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(placeholder)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            )
            .overlay(
                ZStack {
                    if mediaItems.items.first?.mediaType == .photo {
                        Rectangle()
                            .fill(.white)
                            .blendMode(isPreview ? .multiply : .normal)
                            .background {
                                if isPreview {
                                    ShadowView(
                                        offset: CGSize(width: 0, height: -30),
                                        width: 2000,
                                        height: 0
                                    )
                                } else {
                                    EmptyView()
                                }
                            }
                        
                        Image(uiImage: (mediaItems.items.first?.photo ?? UIImage()))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .blendMode(.multiply)
                    } else {
                        if let url = mediaItems.items.first?.videoUrl {
                            Rectangle()
                                .fill(.white)
                                .blendMode(isPreview ? .multiply : .normal)
                                .background {
                                    if isPreview {
                                        ShadowView(
                                            offset: CGSize(width: 0, height: -30),
                                            width: 2000,
                                            height: 0
                                        )
                                    } else {
                                        EmptyView()
                                    }
                                }
                            
                            CustomVideoPlayer(player: AVPlayer(url: url))
                                .blendMode(.multiply)
                        } else {
                            EmptyView()
                        }
                    }
                    
                    if isPreview {
                        VStack {
                            Spacer()
                            
                            HStack {
                                Text(postCreatVM.post.content)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(String(postCreatVM.currentLocation.split(separator: " ").last ?? ""))
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 4, trailing: 4))
                            .foregroundColor(.white)
                        }
                    }
                } // zstack
            )
    }
}

struct CustomIndicator: View {
    var count: Int
    @Binding var current: Int
    
    var body: some View {
        HStack {
            ForEach(0..<count, id: \.self) { index in
                ZStack {
                    if(current - 1) == index {
                        Circle()
                            .fill(Color("moare"))
                            .frame(width: 8, height: 8)
                    } else {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
    }
}
