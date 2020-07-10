//
//  MediaView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/2/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices



var normalisedTime: Double = 0.0
//    var normalisedTime: Double {
//        set {
//            scrubber.value = Float(newValue)
//        }
//        get {
//            return Double(scrubber.value)
//        }
//    }

@IBDesignable

class MediaView: UIView {

    private var view: UIView!
    private let nibName: String = "MediaView"
    
    private var imageSource: UIImage!
    private var videoLayer: AVPlayerLayer!
    
    static let pixelBufferAttributes: [String:AnyObject] = [
        String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
    let ciContext = CIContext()
    var videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
    var player: AVPlayer!
    var videoTransform: CGAffineTransform?
    var unfilteredImage: CIImage?
    //var currentURL: NSURL?
    var mediaUrl: URL!
    var failedPixelBufferForItemTimeCount = 0
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var filteredVideoVendor: FilteredVideoVendor = {
        [unowned self] in
        
        let vendor = FilteredVideoVendor()
        vendor.delegate = self
        return vendor
        }()
    
    private func createText(value: Int) -> String {
        let string = "\(value)"
        return string
    }
    
    @IBInspectable var image: UIImage? {
        didSet {
            self.imageView.alpha = 1;
            self.imageView.image = image
            self.imageView.contentMode = .scaleAspectFill
        }
    }
    
    func pause() {
        if self.player != nil {
            self.player.pause()
        }
    }
    
    func filterImage(filter: Filter) {
        self.imageSource = UIImage(cgImage: self.image!.cgImage!)
        let filteredImage = filteredImageWithCIImage(image: self.image!, filterName: filter.ciImageName)
        checkImageOrientation(image: filteredImage, name: "filteredImage")
        self.imageView.image = filteredImage
        imageFilteredOutPut = filteredImage
    }
    
    func filterVideo(filter: Filter) {
        self.imageView.alpha = 1
        filteredVideoVendor.openMovie(url: self.mediaUrl)
        filteredVideoVendor.ciFilter = CIFilter(name: filter.ciImageName)
        self.videoLayer.removeFromSuperlayer()
    }
    
    func playVideoWithUrl(url: URL) {
        self.mediaUrl = url
        self.superview!.setNeedsLayout()
        self.superview!.layoutIfNeeded()
        self.imageView.alpha = 0;
        
        self.player = AVPlayer(url: url)
        self.videoLayer = AVPlayerLayer(player: self.player)
        self.videoLayer.frame = self.frame
        self.videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.layer.addSublayer(self.videoLayer)
        self.player.play()
        self.player.actionAtItemEnd = .none
        
        filteredVideoVendor.paused = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(MediaView.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        
    }
    
    @objc func playerItemDidReachEnd(_ notification: NSNotification) {
        //Loop play
        self.player.seek(to: CMTime.zero)
        self.player.play()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    private func setUpView() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        setNeedsDisplay()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self ,options: nil)[0] as! UIView
        return view
    }
}

// MARK: FilteredVideoVendorDelegate

extension MediaView: FilteredVideoVendorDelegate {
    
    func finalOutputUpdated(_ image: UIImage) {
        imageView.image = image
        print("finalOutputUpdated", image)
    }
    
    func vendorNormalisedTimeUpdated(_ normalisedTime: Float) {
        //print("vendorNormalisedTimeUpdated", normalisedTime)
        //normalisedTime = Double(normalisedTime)
    }
}
