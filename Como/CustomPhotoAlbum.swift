//
//  CustomPhotoAlbum.swift
//  Como
//
//  Created by Songwut Maneefun on 6/22/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import Photos

class CustomPhotoAlbum {
    
    static let albumName = "Como"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    init() {
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                return (collection.firstObject!)
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }
    
    func saveFile(file: AnyObject, vc: UIViewController) {
        let photoLibrarytSatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoLibrarytSatus {
        case .authorized:
            // Access has been granted.
            if file.isKind(of: UIImage.self) {
                let image = file as! UIImage
                self.saveImage(image: image, vc: vc)
                
            } else if file.isKind(of: NSURL.self) {
                let url = file as! NSURL
                self.saveVideo(url: url as URL, vc: vc)
            }
            break
        case .denied:
            alertWithTitle(title: "Require Access to PhotoLibrary", message: "Go to Setting > Como > Photo (On)", viewController: vc, toFocus: nil)
            break
        case .notDetermined:
            break
        case .restricted:
            break
        @unknown default:
            break
        }
    }
    
    func saveImage(image: UIImage, vc: UIViewController) {
        if self.assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceholder!] as NSFastEnumeration)
            }, completionHandler: { success, error in
                alertWithTitle(title: "Image Saved", message: "Save image to camera roll", viewController: vc, toFocus: nil)
        })
    }
    
    func saveVideo(url: URL, vc: UIViewController) {
        DispatchQueue.global(qos: .default ).async {
            // background things
            let urlData = NSData(contentsOf: url)
            var filePath = ""
            if(urlData != nil) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                filePath="\(documentsPath)/tempFile.mp4"
            }
            DispatchQueue.main.async {
                print("main thread dispatch")
                do {
                    try urlData?.write(toFile: filePath, options: [.atomic])
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { (completed, error) in
                        if completed {
                            alertWithTitle(title: "Video Saved", message: "Save image to camera roll", viewController: vc, toFocus: nil)
                        }
                    }
                } catch {/* error handling here */
                    
                }
                
            }
        }
    }
}
