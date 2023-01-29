//
//  PostCreateViewModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import KeychainAccess
import SwiftUI
import AVFoundation

class PostCreateViewModel: ObservableObject {
    private let api = PostAPI()
    
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("currentLocation") var currentLocation = ""
    @AppStorage("username") var username = ""
    @AppStorage("profile") var profile = ""
    
    @Published var post = CreatePost(postCreatedAt: "", userCreatedAt: "", username: "", profileImage: "", yearAndMonth: "", mediaObj: [], content: "", sportHashtag: [], place: "", x: "", y: "")
    
    @Published var completeBtnEnabled = false
    @Published var loading = false
    
    var compressedURLList = [URL]()
    
    // 앱 열자마자 실행된다
    init() {
        if !currentLocation.isEmpty {
            let locationList = UserDefaults.standard.stringArray(forKey: "locationList") ?? [String]()
            let encodedLocation = locationList.filter { item in
                let userDefault = UserDefaultLocation.decode(responseString: item)
                return self.currentLocation == userDefault.address
            }
            let location = UserDefaultLocation.decode(responseString: encodedLocation.first!)
            
            self.post.place = location.address
            self.post.x = location.x
            self.post.y = location.y
        }
    }
    
    @MainActor func createPost(mediaItems: PickedMediaItems, completed: @escaping () -> ()) {
        guard let token = try! Keychain().get("AccessToken") else { return }
        
        self.loading = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        post.postCreatedAt = dateFormatter.string(from: Date())
        
        dateFormatter.dateFormat = "YYYY-MM"
        post.yearAndMonth = dateFormatter.string(from: Date())
        
        post.username = self.username
        post.profileImage = Profile.decode(profile).profileImage
        post.userCreatedAt = Profile.decode(profile).createdAt
       
        Task {
            do {
                let mediaData =  await mediaToData(mediaItems: mediaItems)
                try await self.api.createPost(token: token, post: self.post, mediaData: mediaData)
                
                // 생성된 영상 임시 파일 삭제(영상 추가 과정에서 생긴파일, 압축 과정에서 생긴파일)
                try mediaItems.items.forEach { media in
                    if media.mediaType == .video {
                        if media.videoUrl != nil {
                            try FileManager.default.removeItem(at: media.videoUrl!)
                        }
                    }
                }
                try compressedURLList.forEach { url in
                    try FileManager.default.removeItem(at: url)
                }
                
                completed()
            } catch {
                // toast error
                self.loading = false
                print("\(error)")
            }
        }
        
    }
    
    func mediaToData(mediaItems: PickedMediaItems) async -> [MediaData] {
            var data = [MediaData]()
            for media in mediaItems.items {
                if media.mediaType == .photo {
                    if let compressed = media.photo?.jpegData(compressionQuality: 0.1) {
                        let mediaData = MediaData(data: compressed, mediaType: "image", filename: "test.jpeg")
                        data.append(mediaData)
                    }
                } else if media.mediaType == .video {
                    if let videoUrl = media.videoUrl {
                        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
                        guard let da = try? Data(contentsOf: videoUrl) else {
                            return []
                        }
                        print("File size before compression: \(Double(da.count / 1048576)) mb")
                        await compressVideo(inputURL: videoUrl, outputURL: compressedURL) { exportSession in
                            guard let session = exportSession else {
                                return
                            }

                            switch session.status {
                            case .unknown:
                                break
                            case .waiting:
                                break
                            case .exporting:
                                break
                            case .completed:
                                guard let compressedData = try? Data(contentsOf: compressedURL) else {
                                    return
                                }

                                let mediaData = MediaData(data: compressedData, mediaType: "video", filename: "test.mp4")
                                data.append(mediaData)
                                self.compressedURLList.append(compressedURL)
                                print("File size after compression: \(Double(compressedData.count / 1048576)) mb")
                            case .failed:
                                break
                            case .cancelled:
                                break
                            default:
                                break
                            } // switch
                        } // compressvideo
                    } // videourl
                } // if else
            } // for in
        return data
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?) -> Void) async {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        await exportSession.export()
        handler(exportSession)
    }
    
    func checkContent(mediaItems: PickedMediaItems) -> Bool {
        mediaItems.items.isEmpty && post.sportHashtag.isEmpty && post.content.isEmpty
    }
    
    func checkCompleteBtn(mediaItems: PickedMediaItems) {
        self.completeBtnEnabled = !mediaItems.items.isEmpty && !post.sportHashtag.isEmpty && !post.place.isEmpty
    }
}
