//
//  StickerView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/15/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

@objc protocol StickerViewDelegate {
    @objc optional
    func protocolStickerViewDidActiveEditing(_ stickerView: StickerView)
    func protocolStickerViewDidBeginEditing(_ stickerView: StickerView)
    func protocolStickerViewDidEndEditing(_ stickerView: StickerView)
    func protocolStickerViewDidCancelEditing(_ stickerView: StickerView)
    func protocolStickerViewDidMove(_ stickerView: StickerView, position: CGPoint)
    //func protocolStickerViewDidClose(stickerView: StickerView)
    func protocolStickerViewDidLongPressed(_ stickerView: StickerView)
    //func protocolStickerViewDidCustomButtonTap(stickerView: StickerView)
}

class StickerView: UIView, UIGestureRecognizerDelegate {
    
    var delegate: StickerViewDelegate?
    var isFlipHor = false
    var isMoveHor = true
    var isMoveVer = true
    var contentView = UIView()
    
    private var deltaAngle: Float = 0.0
    private var lastScale: Float = 0.0
    private var lastDistance: Float = 0.0
    private var lastRotation: Float = 0.0
    private var activeRecognizers = NSMutableSet()
    private var rotateTransform = CGAffineTransform()
    
    private let controlView = UIView()
    private var preventsResizing = false
    private var preventsDeleting = false
    private var preventsFlipping = false
    private var preventsCustomButton = true
    private var preventsPositionOutsideSuperview = false
    //private var isShowingEditingHandles =  true
    private var minWidth: CGFloat = 0.0
    private var minHeight: CGFloat = 0.0
    
    private var touchStart: CGPoint!
    
    private let kSPUserResizableViewGlobalInset: CGFloat = 5.0
    private let kSPUserResizableViewDefaultMinWidth: CGFloat = 48.0
    private let kSPUserResizableViewInteractiveBorderSize: CGFloat = 10.0
    private let kZDStickerViewControlSize: CGFloat = 36.0
    private let SHADOW_SIZE = CGSize(width: 0.5, height: 0.5)
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    setNeedsDisplay()
        for touch: AnyObject? in touches {
            touchStart = touch?.location(in: self.superview)
            self.delegate?.protocolStickerViewDidBeginEditing(self)
        }
    }
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    setNeedsDisplay()
        self.delegate?.protocolStickerViewDidEndEditing(self)
    }
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
    super.touchesCancelled(touches!, with: event)
    
    setNeedsDisplay()
        self.delegate?.protocolStickerViewDidCancelEditing(self)
    }
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    setNeedsDisplay()
        for touch in touches {
            let touchPoint = touch.location(in: self.superview)
            self.delegate!.protocolStickerViewDidMove(self, position: touchPoint)
            self.translateUsingTouchLocation(touchPoint: touchPoint)
            touchStart = touchPoint;
        }
    }
    
    func translateUsingTouchLocation(touchPoint: CGPoint) {
        var newCenter = CGPoint(x: self.center.x + touchPoint.x - touchStart.x,
                                y: self.center.y + touchPoint.y - touchStart.y);
        if (self.preventsPositionOutsideSuperview) {
            // Ensure the translation won't cause the view to move offscreen.
            let midPointX = self.bounds.midX;
            if (newCenter.x > self.superview!.bounds.size.width - midPointX) {
                newCenter.x = self.superview!.bounds.size.width - midPointX
            }
            if (newCenter.x < midPointX) {
                newCenter.x = midPointX;
            }
            let midPointY = self.bounds.midY
            if (newCenter.y > self.superview!.bounds.size.height - midPointY) {
                newCenter.y = self.superview!.bounds.size.height - midPointY
            }
            if (newCenter.y < midPointY) {
                newCenter.y = midPointY;
            }
        }
        if self.isMoveHor == true && self.isMoveVer == true {
            self.center = newCenter
            
        } else if self.isMoveHor == true {
            self.center = CGPoint(x: newCenter.x, y: self.center.y)
            
        } else if self.isMoveVer == true {
            self.center = CGPoint(x: self.center.x, y: newCenter.y)
        }
    }
    
    func removeWithAnimate(animate: Bool) {
        if animate == true {
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = self.transform.scaledBy(x: 0.3, y: 0.3)
                self.alpha = 0
            }) { (done) in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
        
    }
    
    func setSticker(view :UIView) {
        contentView.removeFromSuperview()
        contentView = view;
        contentView.frame = self.bounds.insetBy(dx: kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, dy: kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView)
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
        self.isUserInteractionEnabled = true
        if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5) {
            self.minWidth = kSPUserResizableViewDefaultMinWidth;
            self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
        } else {
            self.minWidth = self.bounds.size.width * 0.5;
            self.minHeight = self.bounds.size.height * 0.5;
        }
        
        deltaAngle = atan2(Float(self.frame.origin.y) + Float(self.frame.size.height) - Float(self.center.y), Float(self.frame.origin.x) + Float(self.frame.size.width) - Float(self.center.x));
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.contentTapped(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.scaleSticker(_:)))
        let rotatation = UIRotationGestureRecognizer(target: self, action: #selector(self.rotateSticker(_:)))
        
        self.addGestureRecognizer(longpress)
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(pinch)
        self.addGestureRecognizer(rotatation)
    }
    
    @objc func longPress(_ recognizer: UIPanGestureRecognizer) {
        if (recognizer.state == .began) {
            delegate!.protocolStickerViewDidLongPressed(self)
        }
    }
    
    @objc func contentTapped(_ recognizer: UITapGestureRecognizer) {
        delegate!.protocolStickerViewDidActiveEditing!(self)
    }
    
    @objc func scaleSticker(_ recognizer: UIPinchGestureRecognizer) {
        if(recognizer.state == .began) {
            lastScale = 1.0;
        }
        
        let scale: CGFloat = 1.0 - (CGFloat(lastScale) - recognizer.scale)
        let currentTransform = self.transform;
        let newTransform = currentTransform.scaledBy(x: scale, y: scale)
        self.transform = newTransform
        
        lastScale = Float(recognizer.scale)
    }
    
    @objc func rotateSticker(_ recognizer: UIRotationGestureRecognizer) {
        if(recognizer.state == .ended) {
            lastRotation = 0.0
            return;
        }
        
        let rotation: CGFloat = 0.0 - (CGFloat(lastRotation) - recognizer.rotation)
        
        let currentTransform: CGAffineTransform = self.transform
        let newTransform = currentTransform.rotated(by: rotation)
        self.transform = newTransform
        
        lastRotation = Float(recognizer.rotation)
    }

    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && gestureRecognizer.isKind(of: UITapGestureRecognizer.self)
    }
}
