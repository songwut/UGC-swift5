//
//  AppLoading.swift
//  Como
//
//  Created by Songwut Maneefun on 6/21/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

var AppLoadingActivity = AppLoading()
private var appLoading:AppLoading!
private var activityView: ActivityLoad!
private var loadingLabel: UILabel!


class AppLoading: UIView {

    var blurView: UIVisualEffectView!
    var vibrancyView: UIVisualEffectView!
    let blurEffect = UIBlurEffect(style: .dark)
    var isCreate = false
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func loadingOnScreen(view: UIView, loadingText: String) {
        print("loadingOnScreen", view.frame)
        appLoading = AppLoading(frame: view.frame)
        loadingLabel.text = loadingText
        view.addSubview(appLoading)
        
        activityView.startLoading()
    }
    
    func hideBackground(hide: Bool) {
        if hide == true {
            blurView.alpha = 0
        } else {
            blurView.alpha = 0.8
        }
    }
    
    func remove(animate: Bool) {
        if animate == true {
            UIView.animate(withDuration: 1.0, animations: {
                appLoading.alpha = 0
                }, completion: { (done) in
            })
        } else {
            appLoading.alpha = 0
        }
        
    }
    
    func AppLoadingProgress(progress: Float) {
        activityView.progress = progress
        if progress == 1.0 {
            AppLoadingProgressDone(done: true)
        }
    }
    
    func AppLoadingProgressDone(done: Bool) {
        if done == false {
            activityView.strokeColor = UIColor.red
        }
        activityView.completeLoading(success: done)
    }
    
    @IBInspectable var loadingText: String! {
        didSet {
            loadingLabel.text = loadingText
        }
    }
    
    @IBInspectable var loadColor: UIColor? {
        didSet {
            activityView.strokeColor = loadColor!
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
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
        
        if self.isCreate == false {
            self.blurView = UIVisualEffectView(effect: self.blurEffect)
            self.addSubview(self.blurView)
        }
        self.blurView.alpha = 0.8
        self.blurView.frame = self.frame
        
        
        
        // Vibrancy effect
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: self.blurEffect))
        self.vibrancyView.frame = self.bounds
        
        loadingLabel = UILabel()
        loadingLabel.font = UIFont.systemFont(ofSize: 30)
        loadingLabel.sizeToFit()
        loadingLabel.center = CGPoint(x: self.center.x, y: self.center.y + 60)
        
        if self.isCreate == false {
            self.vibrancyView.contentView.addSubview(loadingLabel)
            self.blurView.contentView.addSubview(self.vibrancyView)
        }
        
        
        let activityFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        if self.isCreate == false {
            activityView = ActivityLoad(frame: activityFrame)
            self.addSubview(activityView)
        }
        activityView.center = self.center
        activityView.strokeColor = UIColor(hex: "#FF3B65")
        self.isCreate = true
    }
}
