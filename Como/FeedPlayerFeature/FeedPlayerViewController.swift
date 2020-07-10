//
//  FeedPlayerViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 6/9/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class FeedPlayerViewController: UIViewController, FeedControlViewDelegate, ControlMomentViewDelegate ,PlayerViewDelegate{

    //@IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var controlMomentView: ControlMomentView!
    @IBOutlet weak var feedControlView: FeedControlView!
    
    var mediaProgressView: MediaProgressView!
    //default controlViewPositionY = -60 , show = 60
    @IBOutlet weak var controlViewPositionY: NSLayoutConstraint!
    
    var moments = NSMutableArray()
    var activityView = ActivityLoad(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("FeedPlayer moments", self.moments.count)
        
        self.activityView.startLoading()
        self.activityView.strokeColor = UIColor(hex: "#FF3B65")
        self.activityView.center = view.center
        self.activityView.alpha = 1
        self.view.addSubview(self.activityView)
        
        self.playerView.frame = self.view.frame
        self.playerView.setupMomentsToPlayList(moments: self.moments, isAutoPlay: true)
        self.showLoading(show: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(_:)))
        self.feedControlView.addGestureRecognizer(tap)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        
        self.feedControlView.delegate = self
        self.controlMomentView.delegate = self
        self.playerView.delegate = self
        
        let progressFrame = CGRect(x: self.view.frame.size.width - (40 + 8), y: 8, width: 44, height: 44)
        self.mediaProgressView = MediaProgressView(frame: progressFrame)
        self.view.addSubview(mediaProgressView)
    }
    
    @objc func imageViewTapped(_ recognizer: UITapGestureRecognizer) {
        print("did skip")
        self.playerView.skip()
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .right :
                print("Swiped right")
            case .down:
                print("Swiped down")
                self.dismiss(animated: true, completion: {
                    self.playerView.pause()
                })
            case .left:
                print("Swiped left")
            case .up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    func showLoading(show: Bool) {
        if show == true {
            self.activityView.startLoading()
            self.activityView.alpha = 1
        } else {
            //self.activityView.completeLoading(true)
            self.activityView.alpha = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func showMoment(moment: Moment) {
        self.controlMomentView.alpha = 1
        self.feedControlView.alpha = 1
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func protocolPlayerViewDidSelectedMoment(_ moment: Moment) {
        self.feedControlView.timeLabel.text = moment.timestamp
        self.feedControlView.userNameLabel.text = moment.userName
        self.feedControlView.userImageView.setImage(moment.userImage, placeholderImage: nil)
    }
    
    func protocolPlayerViewDidEndPlayList() {
        //TODO play
    }
    
    func protocolPlayerViewDidUpdatePlayList(_ updatedMoments: NSMutableArray) {
        if updatedMoments.count == 0 {
            self.dismiss(animated: true, completion: {
                self.playerView.pause()
            })
        }
        let ratioleft:CGFloat = CGFloat(updatedMoments.count / self.moments.count)
        print("momentleft: ", ratioleft)
        self.showLoading(show: false)
        self.mediaProgressView.setAllProgress(progress: ratioleft, animated: true)
    }
    
    func protocolPlayerViewDidUpdateImageMoment(_ moment: Moment, duration: Double) {
        print("UpdateImage duration: ", duration)
        self.showLoading(show: false)
        let endAngle = (-90.0 * 3.142) / 180
        self.mediaProgressView.setProgress(progress: CGFloat(endAngle), duration: duration)
        //self.mediaProgressView.setProgress(CGFloat(1.0), duration: duration, animated: true)
    }
    
    func protocolPlayerViewDidUpdateVideoMoment(_ moment: Moment, progress: Float) {
        print("UpdateVideo progress: ", progress)
        self.showLoading(show: false)
        self.mediaProgressView.setProgress(progress: CGFloat(progress), duration: 1)
    }
    
    func protocolPlayerViewDidLoadingVideoMoment(_ moment: Moment) {
        self.showLoading(show: true)
    }
    
    func protocolFeedControlViewDidShowControlView() {
        //show controlView
        self.controlViewPositionY.constant = 0
    }
    
    func protocolControlMomentViewDidHideControlView() {
        feedControlView.downButton.alpha = 1
        self.controlViewPositionY.constant = -60
    }
    
    func protocolControlMomentViewDidDownload() {
        print("DidDownload")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
