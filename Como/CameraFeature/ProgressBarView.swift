//
//  ProgressBarView.swift
//  Como
//
//  Created by Songwut Maneefun on 5/19/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit


@objc protocol ProgressBarViewDelegate {
    @objc optional func protocolProgressBarViewProgressed(progressBarView: ProgressBarView)
}

class ProgressBarView: UIView {
    
    weak var delegate: ProgressBarViewDelegate?
    
    var progressView = UIView(frame: CGRect.zero)
    
    @IBInspectable var progressColor: UIColor = UIColor.gray {
        didSet {
            self.progressView.backgroundColor = progressColor
        }
    }
    
    @IBInspectable var progress: CGFloat = 0.0 {
        didSet {
            self.alpha = 1
            let widthFromPercent = bounds.size.width * progress
            self.progressView.frame = CGRect(x: 0, y: 0, width: widthFromPercent, height: bounds.size.height)
            if progress == 1.0 {
                self.progressView.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.size.height)
                self.alpha = 0
            }
        }
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        setUpView()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
        setUpView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    
    func setUpView() {
        if self.progressView.tag != 10 {
            self.progressView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            self.addSubview(self.progressView);
            self.progressView.tag = 10
        }
        self.progressView.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.size.height)
    }
    
    func autoProgressing() {
        self.alpha = 1
        //start from left
        let startFrame = CGRect(x: 0, y: 0, width: 0, height: bounds.size.height)
        self.progressView.frame = startFrame
        
        //end on right with animation
        let stopFrame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        UIView.animate(withDuration: Double(videoTime), animations: {
            self.progressView.frame = stopFrame
        }) { (value: Bool) in
            self.alpha = 0
            self.delegate?.protocolProgressBarViewProgressed!(progressBarView: self)
        }
        
        
    }
}
