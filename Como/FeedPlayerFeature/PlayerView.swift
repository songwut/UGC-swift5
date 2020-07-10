//
//  PlayerView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/9/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol PlayerViewDelegate {
    func protocolPlayerViewDidSelectedMoment(_ moment: Moment)
    func protocolPlayerViewDidEndPlayList()
    func protocolPlayerViewDidUpdatePlayList(_ updatedMoments: NSMutableArray)
    func protocolPlayerViewDidUpdateImageMoment(_ moment: Moment, duration: Double)
    func protocolPlayerViewDidUpdateVideoMoment(_ moment: Moment, progress: Float)
    func protocolPlayerViewDidLoadingVideoMoment(_ moment: Moment)
    //func protocolPlayerViewDidSkip()
}

class PlayerView: UIView {

    var player: AVPlayer!
    private var imageSource: UIImage!
    private var videoLayer: AVPlayerLayer!
    var mediaUrl: URL!
    var playList = NSMutableArray()
    var imageView: UIImageView!
    var selectedMoment: Moment!
    var readyToNext = false
    var delegate: PlayerViewDelegate?
    var updater: CADisplayLink!
    var durationTime: Timer!
    var isVideoPlayer: Bool!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func pause() {
        if self.player != nil {
            self.player.pause()
            //updater.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            updater.remove(from: RunLoop.current, forMode: RunLoop.Mode.common)
            updater.isPaused = true
            updater = nil
        }
    }
    
    func checkDelay(delay: Int) -> Double {
        if delay > 0 {
            return Double(delay)
        }
        return Double(5)
    }
    
    func skip() {
        if self.durationTime != nil {
            self.durationTime.invalidate()
            //self.durationTime = nil
        }
        self.playList.remove(self.selectedMoment as Any)
        print("did skip")
        self.delegate!.protocolPlayerViewDidUpdatePlayList(self.playList)
        self.readyToNext = true
        self.startAutoPlay()
    }
    
    func setupMomentsToPlayList(moments: NSMutableArray, isAutoPlay: Bool) {
        self.layoutSubviews()
        self.layoutIfNeeded()
        print("playerview framr", self.frame)
        for moment in moments {
            self.playList.add(moment)
        }
        print("self.playList", self.playList.count)
        print("moments", moments.count)
        if isAutoPlay == true {
            self.readyToNext = true
            self.startAutoPlay()
        }
        
    }
    
    func startAutoPlay() {
        if self.playList.count > 0  && self.readyToNext == true {
            for moment in self.playList {
                self.selectedMoment = (moment as! Moment)
                self.delegate?.protocolPlayerViewDidSelectedMoment(self.selectedMoment)
                let url = URL(string: self.selectedMoment.path)
                let duration:Int = self.selectedMoment.duration / millisec
                
                self.isVideoPlayer = self.isVideo(url: url!)
                if self.isVideoPlayer == true {
                    self.playVideoWithUrl(url: url!)
                    break
                } else {
                    self.showImage(url: url!, duration: self.checkDelay(delay: duration))
                    break
                }
            }
            //let momentToPlay = self.playList.first as! Moment
            
        } else if self.playList.count == 0 {
            print("all video aready play")
            self.delegate?.protocolPlayerViewDidEndPlayList()
        }
    }
    
    func isVideo(url: URL) -> Bool {
        print("url string", url.absoluteString as Any)
        if url.absoluteString.hasSuffix(".mp4") {
            return true
        }
        return false
    }
    
    func showImage(url: URL, duration: Double) {
        self.delegate?.protocolPlayerViewDidUpdateImageMoment(self.selectedMoment, duration: duration)
        /*
        self.imageView.setLoadImage(url, placeholderImage: nil) { (p1, p2, url) in
            
        }

        self.imageView.setImage(url, placeholderImage: nil) { (progress) in
            self.imageView.alpha = 1;
            self.imageView.frame = self.frame
            print("self.imageView.frame", self.imageView.frame)
            let timeDelay = NSTimeInterval(duration)
            self.durationTime = NSTimer.scheduledTimerWithTimeInterval(timeDelay, target: self, selector: #selector(self.showImageEnd(_:)), userInfo: nil, repeats: false)
        } completion: { (image) in
            
        }
        */
    }
    
    func showImageEnd(timer : Timer) {
        self.playList.remove(self.selectedMoment as Any)
        self.delegate!.protocolPlayerViewDidUpdatePlayList(self.playList)
        self.readyToNext = true
        self.startAutoPlay()
    }
    
    func playVideoWithUrl(url: URL) {
        self.mediaUrl = url
        self.superview!.setNeedsLayout()
        self.superview!.layoutIfNeeded()
        self.imageView.image = nil
        self.imageView.alpha = 0;
        
        let videoItem = AVPlayerItem(asset: AVURLAsset(url: url))
        self.player = AVPlayer(playerItem: videoItem)
        self.videoLayer = AVPlayerLayer(player: self.player)
        self.videoLayer.frame = self.frame
        self.videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.layer.addSublayer(self.videoLayer)
        self.player.actionAtItemEnd = .none
        
        updater = CADisplayLink(target: self, selector: #selector(self.trackPlayer))
        updater.frameInterval = 1
        updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        
        
        self.player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        
        
        
    }
    
    @objc func trackPlayer() {
        if self.isVideoPlayer == true {
            let currentTime: Double = CMTimeGetSeconds(self.player.currentTime())
            let duration: Double = CMTimeGetSeconds(self.playerItemDuration())
            let normalizedTime = Float(currentTime * 100.0 / duration)
            
            if normalizedTime >= 0 {
                //print("normalizedTime progress", normalizedTime)
                let progress = normalizedTime / 100
                self.delegate!.protocolPlayerViewDidUpdateVideoMoment(self.selectedMoment, progress: progress)
            } else {
                self.delegate!.protocolPlayerViewDidLoadingVideoMoment(self.selectedMoment)
            }
            
            
        }
        
    }

    @objc func playerItemDidEnd(_ notification: NSNotification) {
        //TODO: end play go next video
        self.player.pause()
        self.playList.remove(self.selectedMoment!)
        self.delegate!.protocolPlayerViewDidUpdatePlayList(self.playList)
        self.readyToNext = true
        print("playerItemDidEnd")
        self.startAutoPlay()
        
    }
    
    func playerItemDuration() -> CMTime {
        let playerItem: AVPlayerItem = self.player.currentItem!
        if playerItem.status == .readyToPlay {
            return playerItem.duration
        }
        return(CMTime.invalid);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpView()
        self.imageView.frame = self.frame
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
        self.imageView = UIImageView(frame: self.frame)
        self.addSubview(self.imageView)
    }
}
