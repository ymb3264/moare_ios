//
//  PhotoPickerModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import Photos
import PhotosUI

struct PhotoPickerModel: Identifiable {
    enum MediaType {
        case photo, video, livePhoto
    }
    
    var id: String
//    var num: Int
    var photo: UIImage?
    var videoUrl: URL?
    var livePhoto: PHLivePhoto?
    var mediaType: MediaType = .photo
    
    init(_ photo: UIImage) {
        id = UUID().uuidString
//        self.num = num
        self.photo = photo
        self.mediaType = .photo
    }
    
    init(_ videoURL: URL) {
        id = UUID().uuidString
//        self.num = num
        self.videoUrl = videoURL
        self.mediaType = .video
    }
    
    init(_ livePhoto: PHLivePhoto) {
        id = UUID().uuidString
//        self.num = num
        self.livePhoto = livePhoto
        self.mediaType = .livePhoto
    }
}

struct AVPlayerObj {
    var playerItem: AVPlayerItem
    var player: AVQueuePlayer
    var playerLooper: AVPlayerLooper
    var isPlaying: Bool
}

class PickedMediaItems: ObservableObject {
    @Published var items = [PhotoPickerModel]()
    @Published var playerItems = [AVPlayerObj?]()
    var assetIdentifiers = [String]()
    var selection = [String: PHPickerResult]()
    var itemProviders = [String: NSItemProvider]()
    var filter: PHPickerFilter
    var limit: Int
    
    init(filter: PHPickerFilter, limit: Int) {
        self.filter = filter
        self.limit = limit
    }
    
    func append(item: PhotoPickerModel) {
        self.items.append(item)
//        self.items = self.items.sorted { $0.num < $1.num }
    }
}
