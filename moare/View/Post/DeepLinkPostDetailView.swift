//
//  DeepLinkPostDetailView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import AVKit
import NukeUI

struct DeepLinkPostDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var postVM = DeepLinkPostDetailViewModel()

    @State var currentIndex = 1
    
    @State var playerItems = [AVPlayerObj?]()
    @State var playButtonPresented = false
    
    @State var tabGestureEnabled = true
    
    // 더보기
    @State var truncated = false
    @State var expanded = false
    @State var contentHeight: CGFloat = 0
    
    init(yearAndMonth: String, postCreatedAt: String) {
        postVM.getPost(yearAndMonth: yearAndMonth, postCreatedAt: postCreatedAt)
    }

    var body: some View {
        if postVM.loading {
            ProgressView()
                .tint(Color("moare"))
        } else if !postVM.deletedPost.isEmpty {
            Text(postVM.deletedPost)
                .font(.body)
        } else {
            ZStack {
                if !postVM.post.mediaObj.isEmpty {
                    TabView(selection: $currentIndex) {
                        ForEach(postVM.post.mediaObj.indices, id: \.self) { i in
                            if postVM.post.mediaObj[i].type == "image" {
                                ZStack {
                                    Rectangle()
                                        .fill(.white)
                                    
                                    LazyImage(
                                        url: URL(string: postVM.post.mediaObj[i].url),
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
                        } // foreach
                    } // tabview
                    .innerShadow(Rectangle(), offset: CGSize(width: 0, height: contentHeight), width: 2000)
                    .tabViewStyle(.page)
                    .ignoresSafeArea()
                    .onAppear {
                        for item in postVM.post.mediaObj {
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
                }
                
                VStack() {
                    Rectangle()
                        .fill(.clear)
                        .background(ViewGeometry())
                        .onPreferenceChange(ViewSizeKey.self) { size in
                            contentHeight = size.height - UIScreen.main.bounds.height + 10
                        }
                    
                    HStack {
                        HStack {
                            AsyncImage(
                                url: URL(string: postVM.post.profileImage),
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
                            
                            Text(postVM.post.username)
                                .bold()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            CustomIndicator(count: postVM.post.mediaObj.count, current: $currentIndex)
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack {
                            if let like = postVM.post.like {
                                if like.contains(postVM.username) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 23))
                                        .padding(.trailing, 10)
                                        .foregroundColor(Color("moare"))
                                        .onTapGesture {
                                            postVM.unlike()
                                        }
                                } else {
                                    Image(systemName: "heart")
                                        .font(.system(size: 23))
                                        .padding(.trailing, 10)
                                        .onTapGesture {
                                            postVM.like()
                                        }
                                }
                            }
                            
                            Image(systemName: "paperplane")
                                .font(.system(size: 20))
                                .onTapGesture {
                                    ShareHelper.sharActionSheet(url: "https://moare.kr/post/one?yearAndMonth=\(postVM.post.yearAndMonth)&postCreatedAt=\(postVM.post.postCreatedAt)")
                                }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .bottomTrailing)
                    }
                    
                    HStack {
                        Text(postVM.post.sportHashtag.joined(separator: " "))
                            .font(.subheadline)
                            .foregroundColor(Color("moare"))
                            .padding(.bottom, 2)
                        
                        Spacer()
                        
                        if let like = postVM.post.like {
                            if !like.isEmpty {
                                Text("좋아요 \(postVM.post.like!.count)개")
                                    .font(.subheadline)
                            }
                        }
                    }
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        HStack(spacing: 0) {
                            Text(postVM.post.content)
                                .font(.body)
                                .lineLimit(expanded ? nil : 1)
                                .background(
                                    Text(postVM.post.content)
                                        .lineLimit(1)
                                        .background(GeometryReader { visibleTextGeometry in
                                            ZStack {
                                                Text(postVM.post.content)
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
                        
                        Text(String(postVM.post.place.split(separator: " ").last ?? ""))
                            .font(.subheadline)
                        
                        Text(" · ")
                            .font(.title3)
                        
                        if !postVM.post.postCreatedAt.isEmpty {
                            Text("\(DateHelper.getDays(createdAt: postVM.post.postCreatedAt))")
                                .font(.subheadline)
                        }
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
//            .navigationBarBackButtonHidden(true)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(.black)
//                        .opacity(0.2)
//                        .frame(width: 30, height: 30)
//                        .overlay {
//                            Image(systemName: "chevron.backward")
//                                .font(.system(size: 16))
//                                .foregroundColor(.white)
//                                .onTapGesture {
//                                    presentationMode.wrappedValue.dismiss()
//                                }
//                        }
//                }
//            }
        } // if else
    }
}
