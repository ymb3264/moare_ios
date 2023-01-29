//
//  PostCreateDetailView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import AVKit

struct PostCreateDetailView: View {
    @ObservedObject var postCreateVM: PostCreateViewModel
    @ObservedObject var mediaItems: PickedMediaItems
    @Environment(\.presentationMode) var presentationMode
    
    @State private var offset = CGSize.zero
    @State var currentIndex = 1
    @State var selection = 0
    @State var playButtonPresented = false
    
    @State var tabGestureEnabled = true
    
    // 더보기
    @State var truncated = false
    @State var expanded = false
    @State var contentHeight: CGFloat = 0
    
    var body: some View {
        TabView(selection: $selection) {
            ZStack {
                TabView(selection: $currentIndex) {
                    ForEach(mediaItems.items.indices, id: \.self) { i in
                        if mediaItems.items[i].mediaType == .photo {
                            ZStack {
                                Rectangle()
                                    .fill(.white)
                                
                                Image(uiImage: mediaItems.items[i].photo ?? UIImage())
                                    .resizable()
                                    .scaledToFit()
                            }
                            .edgesIgnoringSafeArea(.top)
                            .tag(i+1)
                        } else {
                            Rectangle()
                                .fill(.white)
                                .overlay {
                                    CustomVideoPlayer(player: mediaItems.playerItems[i]!.player)
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
                    if mediaItems.playerItems[currentIndex-1] != nil {
                        mediaItems.playerItems[currentIndex-1]?.player.play()
                        mediaItems.playerItems[currentIndex-1]?.isPlaying = true
                    }
                    
                }
                .onChange(of: currentIndex) { _ in
                    // pause every player when changing currentIndex
                    for (i, item) in mediaItems.playerItems.enumerated() {
                        if item != nil {
                            mediaItems.playerItems[i]?.player.pause()
                            mediaItems.playerItems[i]?.isPlaying = false
                        }
                    }
                    
                    if mediaItems.playerItems[currentIndex-1] != nil {
                        mediaItems.playerItems[currentIndex-1]?.player.play()
                        mediaItems.playerItems[currentIndex-1]?.isPlaying = true
                    }
                }
                .onDisappear {
                    // pause every player
                    for (i, item) in mediaItems.playerItems.enumerated() {
                        if item != nil {
                            mediaItems.playerItems[i]?.player.pause()
                            mediaItems.playerItems[i]?.isPlaying = false
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
                                url: URL(string: Profile.decode(postCreateVM.profile).profileImage),
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
                            
                            Text(Profile.decode(postCreateVM.profile).username)
                                .font(.body)
                                .bold()
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            CustomIndicator(count: mediaItems.items.count, current: $currentIndex)
                        }
                        .frame(maxWidth: .infinity)

                        HStack {
                            Image(systemName: "heart")
                                .font(.system(size: 23))
                                .padding(.trailing, 10)
                            Image(systemName: "paperplane")
                                .font(.system(size: 20))
                        }
                        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .bottomTrailing)
                    }
                    
                    HStack {
                        Text(postCreateVM.post.sportHashtag.joined(separator: " "))
                            .font(.body)
                            .foregroundColor(Color("moare"))
                            .padding(.bottom, 2)

                        Spacer()
                    }
                    .font(.system(size: 14))
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        HStack(spacing: 0) {
                            Text(postCreateVM.post.content)
                                .font(.body)
                                .lineLimit(expanded ? nil : 1)
                                .background(
                                    Text(postCreateVM.post.content)
                                        .lineLimit(1)
                                        .background(GeometryReader { visibleTextGeometry in
                                            ZStack {
                                                Text(postCreateVM.post.content)
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
                        
                        Text(String(postCreateVM.currentLocation.split(separator: " ").last ?? ""))
                            .font(.subheadline)
                        
                        Text(" · ")
                            .font(.title3)
                        
                        Text(StringResources.today)
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
                            if mediaItems.playerItems[currentIndex-1] != nil {
                                if mediaItems.playerItems[currentIndex-1]!.isPlaying {
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
            .tabItem { Image(systemName: "rectangle.on.rectangle") }
            .tag(0)
            .onTapGesture {
                if mediaItems.playerItems[currentIndex-1] != nil {
                    if mediaItems.playerItems[currentIndex-1]!.isPlaying {
                        mediaItems.playerItems[currentIndex-1]!.player.pause()
                        mediaItems.playerItems[currentIndex-1]!.isPlaying = false
                        withAnimation(.spring()) {
                            playButtonPresented = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation(.easeOut) {
                                playButtonPresented = false
                            }
                        }
                    } else {
                        mediaItems.playerItems[currentIndex-1]!.player.play()
                        mediaItems.playerItems[currentIndex-1]!.isPlaying = true
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
        } // tabview
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(.black)
//                    .opacity(0.2)
//                    .frame(width: 30, height: 30)
//                    .overlay {
//                        Image(systemName: "chevron.backward")
//                            .font(.system(size: 16))
//                            .foregroundColor(.white)
//                            .onTapGesture {
//                                presentationMode.wrappedValue.dismiss()
//                            }
//                    }
//            }
//        }
    }
}
