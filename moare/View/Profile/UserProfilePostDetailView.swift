//
//  UserProfilePostDetailView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/16.
//

import SwiftUI
import AVKit
import NukeUI

struct UserProfilePostDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var profileVM: UserProfileViewModel
    
    var post: Post
    let listIndex: Int
    let postIndex: Int
    let date: String
    @State var currentIndex = 1
    
    @State var playerItems = [AVPlayerObj?]()
    @State var playButtonPresented = false
    
    @State var tabGestureEnabled = true
    
    // see more(content)
    @State var truncated = false
    @State var expanded = false
    @State var contentHeight: CGFloat = 0
    
    // report
    @State var alert = false
    @State var alertState: PostDetailAlertState = .report
    
    init(profileVM: UserProfileViewModel, post: Post, listIndex: Int, postIndex: Int) {
        self._profileVM = StateObject(wrappedValue: profileVM)
        self.post = post
        self.listIndex = listIndex
        self.postIndex = postIndex
        if self.post.like == nil {
            self.post.like = []
        }
        print(post.yearAndMonth)
        print(post.postCreatedAt)
        self.date = DateHelper.getDays(createdAt: post.postCreatedAt)
    }

    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ForEach(post.mediaObj.indices, id: \.self) { i in
                    if post.mediaObj[i].type == "image" {
                        ZStack {
                            Rectangle()
                                .fill(.white)

                            LazyImage(
                                url: URL(string: post.mediaObj[i].url),
                                resizingMode: .aspectFit
                            )
                        }
                        .edgesIgnoringSafeArea(.top)
                        .tag(i+1)
                    } else {
                        Rectangle()
                            .fill(.white)
                            .overlay {
                                if !playerItems.isEmpty {
                                    CustomVideoPlayer(player: playerItems[i]?.player)
                                }
                            }
                            .edgesIgnoringSafeArea(.top)
                            .tag(i+1)
                    }
                }
            }
            .innerShadow(Rectangle(), offset: CGSize(width: 0, height: contentHeight), width: 2000)
            .tabViewStyle(.page)
            .ignoresSafeArea()
            .onAppear {
                for item in post.mediaObj {
                    if item.type == "video" {
                        let playerItem = AVPlayerItem(url: URL(string: item.url)!)
                        let player = AVQueuePlayer(playerItem: playerItem)
                        self.playerItems.append(
                            AVPlayerObj(
                                playerItem: playerItem,
                                player: player,
                                playerLooper: AVPlayerLooper(player: player, templateItem: playerItem),
                                isPlaying: false)
                        )
                    } else {
                        self.playerItems.append(nil)
                    }
                }

                if playerItems[currentIndex-1] != nil {
                    playerItems[currentIndex-1]?.player.play()
                    playerItems[currentIndex-1]?.isPlaying = true
                }
            }
            .onChange(of: currentIndex) { _ in
                for (i, item) in playerItems.enumerated() {
                    if item != nil {
                        playerItems[i]?.player.pause()
                        playerItems[i]?.isPlaying = false
                    }
                }

                if playerItems[currentIndex-1] != nil {
                    playerItems[currentIndex-1]?.player.play()
                    playerItems[currentIndex-1]?.isPlaying = true
                }
            }
            .onDisappear {
                for (i, item) in playerItems.enumerated() {
                    if item != nil {
                        playerItems[i]?.player.pause()
                        playerItems[i]?.isPlaying = false
                    }
                }
            }
            
            
            VStack {
                    Rectangle()
                        .fill(.clear)
                        .background(ViewGeometry())
                        .onPreferenceChange(ViewSizeKey.self) { size in
                            contentHeight = size.height - UIScreen.main.bounds.height + 10
                        }
                
                        HStack {
                            HStack {
                                AsyncImage(
                                    url: URL(string: post.profileImage),
                                    content: { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())
                                    },
                                    placeholder: {
                                        Image(systemName: "person.crop.circle")
                                            .font(.system(size: 30))
                                            .foregroundColor(.secondary)
                                            .frame(width: 30, height: 30)
                                    }
                                )
                                
                                Text(post.username)
                                    .font(.headline)
                                    .bold()
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                CustomIndicator(count: post.mediaObj.count, current: $currentIndex)
                            }
                            .frame(maxWidth: .infinity)
                            
                            HStack {
                                if post.like!.contains(profileVM.myUsername) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 23))
                                        .padding(.trailing, 10)
                                        .foregroundColor(Color("moare"))
                                        .onTapGesture {
                                            profileVM.unlike(post: post, listIndex: listIndex, postIndex: postIndex)
                                        }
                                } else {
                                    Image(systemName: "heart")
                                        .font(.system(size: 23))
                                        .padding(.trailing, 10)
                                        .onTapGesture {
                                            profileVM.like(post: post, listIndex: listIndex, postIndex: postIndex)
                                        }
                                }
                                
                                Image(systemName: "paperplane")
                                    .font(.system(size: 20))
                                    .onTapGesture {
                                        ShareHelper.sharActionSheet(url: "https://moare.kr/post/one?yearAndMonth=\(post.yearAndMonth)&postCreatedAt=\(post.postCreatedAt)")
                                    }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .bottomTrailing)
                        }
                        
                        HStack {
                            Text(post.sportHashtag.joined(separator: " "))
                                .font(.body)
                                .foregroundColor(Color("moare"))
                                .padding(.bottom, 2)
                            
                            Spacer()
                            
                            if !post.like!.isEmpty {
                                Text("좋아요 \(post.like!.count)개")
                                    .font(.subheadline)
                            }
                        }
                        .font(.system(size: 14))
                        
                HStack(alignment: .bottom, spacing: 0) {
                            HStack(spacing: 0) {
                                Text(post.content)
                                    .font(.body)
                                    .lineLimit(expanded ? nil : 3)
                                    .background(
                                        Text(post.content)
                                            .lineLimit(1)
                                            .background(GeometryReader { visibleTextGeometry in
                                                ZStack {
                                                    Text(post.content)
                                                        .background(GeometryReader { fullTextGeometry in
                                                            Color.clear.onAppear {
                                                                truncated = fullTextGeometry.size.height > visibleTextGeometry.size.height
                                                            }
                                                        })
                                                }
                                                .frame(height: .greatestFiniteMagnitude)
                                            })
                                            .hidden()
                                    )
                                
                                if truncated {
                                    Text(StringResources.seeMore)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.leading, 2)
                                }
                                
                                Spacer()
                            }
                            .onTapGesture {
                                truncated.toggle()
                                expanded.toggle()
                            }
                            
                            Text(String(post.place.split(separator: " ").last ?? ""))
                                .font(.subheadline)
                            
                            Text(" · ")
                                .font(.title3)
                            
                            Text("\(date)")
                                .font(.subheadline)
                        }
            } // vstack
            .foregroundColor(.white)
            .padding(.bottom, 10)
            .padding(.horizontal)
            .edgesIgnoringSafeArea(.top)
            
            if playButtonPresented {
                Circle()
                    .fill(.black)
                    .opacity(0.2)
                    .frame(width: 50, height: 50)
                    .overlay {
                        if playerItems[currentIndex-1] != nil {
                            if playerItems[currentIndex-1]!.isPlaying {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "pause.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                        }
                    }
            }
        } // zstack
        .onTapGesture {
            if playerItems[currentIndex-1] != nil {
                if playerItems[currentIndex-1]!.isPlaying {
                    playerItems[currentIndex-1]!.player.pause()
                    playerItems[currentIndex-1]!.isPlaying = false
                    withAnimation(.spring()) {
                        playButtonPresented = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation(.easeOut) {
                            playButtonPresented = false
                        }
                    }
                } else {
                    playerItems[currentIndex-1]!.player.play()
                    playerItems[currentIndex-1]!.isPlaying = true
                    withAnimation(.spring()) {
                        playButtonPresented = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation(.easeOut) {
                            playButtonPresented = false
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        alertState = .report
                        alert = true
                    } label: {
                         Text(StringResources.report)
                            .font(.body)
                            .foregroundColor(.red)
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.black)
                        .opacity(0.2)
                        .frame(width: 30, height: 30)
                        .overlay {
                            VStack(spacing: 2) {
                                Circle()
                                    .frame(width: 4, height: 4)
                                Circle()
                                    .frame(width: 4, height: 4)
                                Circle()
                                    .frame(width: 4, height: 4)
                            }
                            .foregroundColor(.white)
                        }
                }
            }
        }
        .alert(isPresented: $alert) {
            if alertState == .report {
                return Alert(
                    title: Text(StringResources.reportPostAlertTitle),
                    message: Text(StringResources.reportPostAlertMessage),
                    primaryButton: .cancel(Text(StringResources.cancel)),
                    secondaryButton: .destructive(Text(StringResources.report)) {
                        profileVM.reportPost(post: post, listIndex: listIndex, postIndex: postIndex) {
                            alertState = .reportSuccess
                            alert = true
                        }
                    }
                )
            } else {
                return Alert(
                    title: Text(StringResources.reportPostAlertTitle),
                    message: Text(StringResources.reportSuccessMessgae),
                    dismissButton: .cancel(Text(StringResources.confirm))
                )
            }
        }
    }
}
