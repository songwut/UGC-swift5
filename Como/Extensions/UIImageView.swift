//
//  UIImageView.swift
//  Como
//
//  Created by Songwut on 8/7/20.
//  Copyright © 2020 Conicle.Co.,Ltd. All rights reserved.
//

import Foundation
import SDWebImage
import Alamofire

extension UIImageView {
    
    // MARK: Public methods
    
    /**
     Make layer of UIImageView to be circle (use height)
     */
    
    
    func setTintWith(color: UIColor) {
        if let _ = self.image {
            self.image? = (self.image?.withRenderingMode(.alwaysTemplate))!
            self.tintColor = color
        }
    }
    
    func render(_ image: UIImage, withColor color: UIColor) {
        self.image = image
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
    
    func setRounded() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
    
    /**
     Load image from url string use Alamofire 4.0 Framework
     
     - parameter urlConvertible: url string, URL Class (from Alamofire)
     - parameter placeholderImage: UIImage
     - completionHandler completion: UIImage output
     */
    
    func setLoadImage(_ urlString: String, placeholderImage: UIImage?, progress: @escaping ((_ p1:Int, _ p2:Int, _ url: URL?) -> Void)) {
        guard let url = URL(string: urlString) else {
            self.image = placeholderImage
            return
        }
        let phImg = placeholderImage
        
        sd_setImage(with: url, placeholderImage: phImg, options: [.progressiveLoad], progress: { (p1:Int, p2:Int, url: URL?) in
            progress(p1, p2, url)
        }) { (image:UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
            
        }
        
        
    }
    /*
    func setImage(_ urlString: String, placeholderImage: UIImage?, progressBlock :((_ progress: Progress) -> Void), completion :((_ image: UIImage?) -> Void)) {
        guard let url = URL(string:urlString) else { return }
        AF.download(url)
            .downloadProgress(queue: .main) { (progress) in
                progressBlock(progress)
                //Int(progress.fractionCompleted * 100) %
            }
            .responseData { (response: AFDownloadResponse<Data>) in
                switch response.result {
                    case .success(let data):
                        self.image = UIImage(data: data, scale:1)
                        completion(self.image)
                    case .failure(let error):
                        print("error--->",error)
                    }
            }
    }
    */
    func setImage(_ urlString: String, placeholderImage: UIImage?, completion :((_ image: UIImage) -> Void)? = nil) {
        
        guard let url = URL(string: urlString) else {
            self.image = placeholderImage
            return
        }
        
        self.sd_setImage(with: url, placeholderImage: placeholderImage, options: [.progressiveLoad], progress: { (receivedSize, expectedSize, url) in
            
        }) { (image, error, type, url) in
            if let img = image {
                completion?(img)
            }
        }
        /*//cash image may effect to memory
         let phImg = placeholderImage
         
         let cacheId = MD5(urlString)
         imageCache.queryCacheOperation(forKey: cacheId, done: { (image: UIImage?, data: Data?, cache: SDImageCacheType) in
         if let img = image {
         self.image = img
         completion?(img)
         } else {
         self.sd_setImage(with: url, placeholderImage: phImg, options: [progressiveLoad], completed: { (image, error, cacheType, url) in
         SDImageCache.shared.store(image, forKey: cacheId)
         if let img = image {
         completion?(img)
         }
         })
         }
         })
         */
    }
    
    func setRandomDownloadImage(_ width: Int, height: Int) {
        if self.image != nil {
            self.alpha = 1
            return
        }
        self.alpha = 0
        let url = URL(string: "http://lorempixel.com/\(width)/\(height)/")!
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode / 100 != 2 {
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.alpha = 1
                        }, completion: { (finished: Bool) -> Void in
                        })
                    })
                }
            }
        }
        task.resume()
    }
    
    func clipParallaxEffect(_ baseImage: UIImage?, screenSize: CGSize, displayHeight: CGFloat) {
        if let baseImage = baseImage {
            if displayHeight < 0 {
                return
            }
            let aspect: CGFloat = screenSize.width / screenSize.height
            let imageSize = baseImage.size
            let imageScale: CGFloat = imageSize.height / screenSize.height
            
            let cropWidth: CGFloat = floor(aspect < 1.0 ? imageSize.width * aspect : imageSize.width)
            let cropHeight: CGFloat = floor(displayHeight * imageScale)
            
            let left: CGFloat = (imageSize.width - cropWidth) / 2
            let top: CGFloat = (imageSize.height - cropHeight) / 2
            
            let trimRect : CGRect = CGRect(x: left, y: top, width: cropWidth, height: cropHeight)
            //self.image = baseImage.trim(trimRect: trimRect)
            self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: displayHeight)
        }
    }
    
    func shadow(_ radius: CGFloat, opacity: CGFloat, intensity: CGFloat) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = Float(opacity)
        self.layer.shadowOffset = CGSize(width: intensity, height: intensity)
        self.layer.shadowRadius = radius
    }
    
    func circle() {
        self.layer.cornerRadius = self.frame.size.height / 2;
    }
}
