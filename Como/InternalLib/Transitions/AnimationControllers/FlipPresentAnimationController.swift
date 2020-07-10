//
//  FlipPresentAnimationController.swift
//  GuessThePet
//
//  Created by Vesza Jozsef on 08/07/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

class FlipPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        let containerView = transitionContext.containerView
        let initialFrame = originFrame
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
        
        snapshot!.frame = initialFrame
        snapshot?.layer.cornerRadius = 25
        snapshot?.layer.masksToBounds = true
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot!)
        toVC.view.isHidden = true
        
        AnimationHelper.perspectiveTransformForContainerView(containerView: containerView)
        
        //snapshot.layer.transform = AnimationHelper.yRotation(M_PI_2)
        snapshot!.layer.transform = AnimationHelper.scale(scaleFactor: 1)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                /*
                 UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3, animations: {
                 //fromVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
                 fromVC.view.layer.transform = AnimationHelper.scale(1)
                 })
                 
                 UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                 //snapshot.layer.transform = AnimationHelper.yRotation(0.0)
                 fromVC.view.layer.transform = AnimationHelper.scale(2)
                 })
                 
                 UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                 snapshot.frame = finalFrame
                 })
                 */
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1, animations: {
                    snapshot!.frame = finalFrame
                    snapshot!.alpha = 0
                })
        },
            completion: { _ in
                toVC.view.isHidden = false
                snapshot!.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
