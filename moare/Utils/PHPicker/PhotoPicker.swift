//
//  PhotoPicker.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    @StateObject var mediaItems: PickedMediaItems
    @Binding var cropperPresented: Bool
    @Binding var selectedImage: UIImage
    @Binding var isDefaultImage: Bool
    @Binding var alert: Bool
    @Binding var postCreateAlertState: PostCreateAlertState
    var checkCompleteBtn: () -> () = {}
    
    var isPost: Bool = true
    @Environment(\.presentationMode) var mode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = mediaItems.filter
        config.selectionLimit = mediaItems.limit
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        if isPost {
            config.preselectedAssetIdentifiers = mediaItems.assetIdentifiers
        }
        
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        var photoPicker: PhotoPicker
        
        init(_ photoPicker: PhotoPicker) {
            self.photoPicker = photoPicker
        }
        
        @MainActor func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            self.photoPicker.mode.wrappedValue.dismiss()
            Task {
                if results.count > 10 {
                    self.photoPicker.mediaItems.items.removeAll()
                    self.photoPicker.mediaItems.playerItems.removeAll()
                    self.photoPicker.mediaItems.assetIdentifiers.removeAll()
                    self.photoPicker.mediaItems.selection.removeAll()
                    self.photoPicker.mediaItems.itemProviders.removeAll()
                    
                    self.photoPicker.postCreateAlertState = .mediaCountLimit
                    self.photoPicker.alert = true
                    return
                }
                
                let existingSelection: [String: PHPickerResult] = photoPicker.mediaItems.selection
                var newSelection = [String: PHPickerResult]()
                
                let existingItemProvider: [String: NSItemProvider] = photoPicker.mediaItems.itemProviders
                var newItemProvider = [String: NSItemProvider]()
                
                photoPicker.mediaItems.items = [PhotoPickerModel]()
                photoPicker.mediaItems.playerItems = [AVPlayerObj?]()
                
                let dispatchGroup = DispatchGroup()
                var mediaItemsDic = [String:PhotoPickerModel]()
                var playerItemsDic = [String:AVPlayerObj?]()
                var mediaItemList = [PhotoPickerModel]()
                var playerItemList = [AVPlayerObj?]()
                
                photoPicker.mediaItems.assetIdentifiers = results.map(\.assetIdentifier!)
                
                for result in results {
                    let itemProvider: NSItemProvider
                    let identifier = result.assetIdentifier!
                    
                    dispatchGroup.enter()
                    
                    newItemProvider[identifier] = existingItemProvider[identifier] ?? result.itemProvider
                    
                    if newItemProvider[identifier] == nil {
                        itemProvider = result.itemProvider
                    } else {
                        itemProvider = newItemProvider[identifier]!
                    }
                    
                    newSelection[identifier] = existingSelection[identifier] ?? result
                    
                    guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                          let utType = UTType(typeIdentifier)
                    else { continue }
                    
                    if utType.conforms(to: .movie) {
                        itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                            do {
                                if let url = url {
                                    let videoAsset = AVURLAsset(url: url)
                                    let videoDuration = videoAsset.duration.seconds

                                    DispatchQueue.main.async {
                                        if videoDuration >= 31 {
                                            self.photoPicker.mediaItems.items.removeAll()
                                            self.photoPicker.mediaItems.playerItems.removeAll()
                                            self.photoPicker.mediaItems.assetIdentifiers.removeAll()
                                            self.photoPicker.mediaItems.selection.removeAll()
                                            self.photoPicker.mediaItems.itemProviders.removeAll()
                                            
                                            self.photoPicker.postCreateAlertState = .videoDurationLimit
                                            self.photoPicker.alert = true
                                            return
                                        }
                                    }
                                    
                                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                                    guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent) else { return }
                                    
                                    if FileManager.default.fileExists(atPath: targetURL.path) {
                                        try FileManager.default.removeItem(at: targetURL)
                                    }

                                    try FileManager.default.copyItem(at: url, to: targetURL)

                                    // add AVPlayerObj
                                    let playerItem = AVPlayerItem(url: targetURL)
                                    let player = AVQueuePlayer(playerItem: playerItem)
                                    let avPlayerObj = AVPlayerObj(
                                        playerItem: playerItem,
                                        player: player,
                                        playerLooper: AVPlayerLooper(player: player, templateItem: playerItem),
                                        isPlaying: false)

                                    
                                    DispatchQueue.main.async {
                                        let item = PhotoPickerModel(targetURL)
                                        mediaItemsDic[identifier] = item
                                        playerItemsDic[identifier] = avPlayerObj
                                        
                                        self.photoPicker.checkCompleteBtn()
                                    }
                                    
                                    dispatchGroup.leave()
                                }
                            } catch {
                                print("\(error)")
                            }
                        }
                    } else {
                        if itemProvider.canLoadObject(ofClass: UIImage.self) {
                            itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                }

                                if let image = object as? UIImage {
                                    DispatchQueue.main.async {
                                        self.photoPicker.checkCompleteBtn()

                                        if !self.photoPicker.isPost {
                                            if let photo = self.photoPicker.mediaItems.items.first?.photo {
                                                self.photoPicker.selectedImage = photo
                                                self.photoPicker.isDefaultImage = false
                                                self.photoPicker.cropperPresented = true
                                            }
                                        }
                                        
                                        let item = PhotoPickerModel(image)
                                        mediaItemsDic[identifier] = item
                                        playerItemsDic[identifier] = nil as AVPlayerObj?
                                    }
                                }
                                
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    for key in self.photoPicker.mediaItems.assetIdentifiers {
                        mediaItemList.append(mediaItemsDic[key]!)
                        playerItemList.append(playerItemsDic[key]!)
                    }
                    
                    self.photoPicker.mediaItems.items = mediaItemList
                    self.photoPicker.mediaItems.playerItems = playerItemList
                    self.photoPicker.mediaItems.selection = newSelection
                    self.photoPicker.mediaItems.itemProviders = newItemProvider
                }
            }
        }
    } // class
}
