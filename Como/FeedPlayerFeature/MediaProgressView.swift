//
//  MediaProgressView.swift
//  LoadingView
//
//  Created by Songwut Maneefun on 6/10/2559 BE.
//  Copyright © 2559 Songwut Maneefun. All rights reserved.
//

import UIKit

class MediaProgressView: UIView, CAAnimationDelegate {
    private let animateKeyAll = "animateAll"
    private let animateKeyPerEach = "animatePerEach"
    private let tagBackAnimation = 1
    private let tagFrontAnimation = 2
    private let backRatio: CGFloat = 0.12
    private let frontRatio: CGFloat = 0.88
    
    private var circle = UIView()
    private var circleFront = UIView()
    private var circleBack = UIView()
    
    private var progressPerEach: CGFloat = 0.0
    private var progressAll: CGFloat = 0.0
    private var animation: CABasicAnimation!
    private var animationFront: CABasicAnimation!
    private var backProgressColor = UIColor(white: 1, alpha: 1)
    private var frontProgressColor = UIColor.gray
    private var progressPerEachLayer: CAShapeLayer!
    private var progressAllLayer: CAShapeLayer!
    
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
        self.setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    func setUpView() {
        let circlePath = UIBezierPath(ovalIn: self.bounds)
        
        self.circle.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        var circle = CAShapeLayer()
        circle = CAShapeLayer ()
        circle.path = circlePath.cgPath
        circle.fillColor = UIColor(white: 1, alpha: 0.3).cgColor
        self.circle.layer.addSublayer(circle)
        self.addSubview(self.circle)
        
        self.circleBack.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        self.progressPerEachLayer = CAShapeLayer()
        let perEachPoint = CGPoint( x: self.circleBack.frame.size.width / 2, y: self.circleBack.frame.size.height / 2);
        let perEachRadius = self.circleBack.frame.size.width / 2
        let perEachPath = CGMutablePath();
        //arcPath.move(to: CGPoint(x: perEachPoint.x, y: perEachPoint.y - CGFloat(perEachRadius) / 2),
        //arcPath.addArc(center: perEachPoint, radius: CGFloat(perEachRadius)/2, startAngle: 3 * CGFloat(M_PI) / 2, endAngle: 3 * CGFloat(M_PI) / 2, clockwise: true, transform: CGAffineTransform(-CGFloat(M_PI)/2))
        
        self.progressPerEachLayer.path = perEachPath;
        self.progressPerEachLayer.fillColor = UIColor.clear.cgColor
        self.progressPerEachLayer.strokeColor = self.backProgressColor.cgColor
        self.progressPerEachLayer.strokeEnd = 0;
        self.progressPerEachLayer.lineWidth = CGFloat(perEachRadius)
        self.circleBack.layer.addSublayer(self.progressPerEachLayer)
        
        self.addSubview(self.circleBack)
        
        let foregroundSize = self.bounds.size.width * 0.85
        self.circleFront.frame = CGRect(x: (self.circle.frame.size.width - foregroundSize) / 2, y: (self.circle.frame.size.height - foregroundSize) / 2, width: foregroundSize, height: foregroundSize)
        self.addSubview(self.circleFront)
        
        let foregroundPath = UIBezierPath(ovalIn: circleFront.bounds)
        var circleForeground = CAShapeLayer()
        circleForeground = CAShapeLayer ()
        circleForeground.path = foregroundPath.cgPath
        circleForeground.fillColor = self.frontProgressColor.cgColor
        self.circleFront.layer.addSublayer(circleForeground)
        
        
        
        self.progressAllLayer = CAShapeLayer()
        let maskWidth = self.circleFront.frame.size.width
        let maskHeight = self.circleFront.frame.size.height
        let center = CGPoint( x: maskWidth/2, y: maskHeight/2);
        
        let radius = ((self.circleFront.frame.size.width * frontRatio) / 2) + 1
        
        let arcPath = CGMutablePath();
        //arcPath.move(to: CGPoint(x: center.x, y: center.y - CGFloat(radius) / 2))
        //arcPath.addArc(center: center, radius: CGFloat(radius)/2, startAngle: 3 * CGFloat(M_PI) / 2, endAngle: 3 * CGFloat(M_PI) / 2, clockwise: true, transform: CGAffineTransform(rotationAngle: -CGFloat(M_PI)/2) )
        
        self.progressAllLayer.path = arcPath;
        self.progressAllLayer.fillColor = UIColor.clear.cgColor
        self.progressAllLayer.strokeColor = UIColor.black.cgColor
        self.progressAllLayer.strokeEnd = 0;
        self.progressAllLayer.lineWidth = CGFloat(radius)
        self.circleFront.layer.mask = self.progressAllLayer
        self.circleFront.layer.mask!.frame = self.circleFront.layer.bounds;
        //self.circleFront.layer.addSublayer(self.progressAllLayer)
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        //print("animationDidStart")
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //TODO: some
        //print("animationDidStop", anim)
    }
    
    func setProgress(progress: CGFloat, duration: Double) {
        self.setProgress(progress: progress, duration: duration, animated: true)
    }
    
    func setAllProgress(progress: CGFloat) {
        self.setAllProgress(progress: progress, animated: true)
    }
    
    func setAllProgress(progress: CGFloat, animated: Bool) {
        if(progress > 0) {
            if(animated) {
                self.animationFront = CABasicAnimation(keyPath: "path")
                self.animationFront.delegate = self;
                self.animationFront.duration =  1;
                self.animationFront.isRemovedOnCompletion = false;
                self.animationFront.fromValue = self.progressAll
                self.animationFront.toValue = progress
                self.animationFront.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                self.progressAllLayer.strokeEnd = progress;
                self.progressAllLayer.add(self.animationFront, forKey: animateKeyAll)
                
            } else {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.progressAllLayer.strokeEnd = progress;
                CATransaction.commit()
            }
        } else {
            self.progressAllLayer.strokeEnd = 0.0;
            self.progressAllLayer.removeAnimation(forKey: animateKeyAll)
            
        }
        //if set self.progress = it will be error
        self.progressAll = progress;
    }
    
    func setProgress(progress: CGFloat, duration: Double, animated: Bool) {
        if(progress > 0) {
            if(animated) {
                self.animation = CABasicAnimation(keyPath: "path")
                self.animation.delegate = self;
                self.animation.duration =  duration;
                self.animation.isRemovedOnCompletion = false;
                self.animation.fromValue = self.progressPerEach
                self.animation.toValue = progress
                self.animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                self.progressPerEachLayer.strokeEnd = progress;
                self.progressPerEachLayer.add(self.animation, forKey: animateKeyPerEach)
                
            } else {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.progressPerEachLayer.strokeEnd = progress;
                CATransaction.commit()
            }
        } else {
            self.progressPerEachLayer.strokeEnd = 0.0;
            self.progressPerEachLayer.removeAnimation(forKey: animateKeyPerEach)
            
        }
        //if set self.progress = it will be error
        self.progressPerEach = progress;
    }

}
