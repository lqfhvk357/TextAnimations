//
//  LCLayerAnimation.swift
//  TextAnimations
//
//  Created by 罗超 on 2018/10/19.
//  Copyright © 2018年 罗超. All rights reserved.
//

import UIKit

typealias completionClosure = (_ finished: Bool) -> ()

private let textAnimationGroupKey = "textAniamtionGroupKey"

class LCLayerAnimation: NSObject {
    var completion: completionClosure? = nil
    var textLayer: CATextLayer?
    
    class func animation(textLayer: CATextLayer, duration: TimeInterval, delay: TimeInterval, effectAnimation:@escaping effectAniamtableLayerClosure, completion:@escaping completionClosure) {
        
        let anim = LCLayerAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(delay * Double(NSEC_PER_SEC)))) {
            let oldLayer = anim.animatableLayerCopy(layer: textLayer)
            var newLayer = CATextLayer()
            var animGroup: CAAnimationGroup?
            anim.completion = completion
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            newLayer = effectAnimation(textLayer)
            CATransaction.commit()
            
            animGroup = anim.groupAnimationChange(from: oldLayer, with: newLayer)
            if animGroup != nil {
                anim.textLayer = textLayer
                animGroup?.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
                animGroup?.beginTime = CACurrentMediaTime()
                animGroup?.duration = duration
                animGroup?.delegate = anim
                textLayer.add(animGroup!, forKey: textAnimationGroupKey)
            }else{
                completion(true)
            }
            
        }
        
    }
    
    func groupAnimationChange(from oldLayer: CATextLayer, with newLayer: CATextLayer) -> CAAnimationGroup? {
        var animGroup: CAAnimationGroup?
        var animations = [CABasicAnimation]()
        
        if  !oldLayer.position.equalTo(newLayer.position) {
            let basicAnimation = CABasicAnimation()
            basicAnimation.fromValue = oldLayer.position
            basicAnimation.toValue = newLayer.position
            basicAnimation.keyPath = "position"
            animations.append(basicAnimation)
        }
        
        if !CATransform3DEqualToTransform(oldLayer.transform, newLayer.transform) {
            let basicAnimation = CABasicAnimation(keyPath: "transform")
            basicAnimation.fromValue = oldLayer.transform
            basicAnimation.toValue = newLayer.transform
            animations.append(basicAnimation)
        }
        
        if !oldLayer.frame.equalTo(newLayer.frame)
        {
            let basicAnimation = CABasicAnimation(keyPath: "frame")
            basicAnimation.fromValue = oldLayer.frame
            basicAnimation.toValue = newLayer.frame
            animations.append(basicAnimation)
        }
        
        if !oldLayer.bounds.equalTo(oldLayer.bounds)
        {
            let basicAnimation = CABasicAnimation(keyPath: "bounds")
            basicAnimation.fromValue = oldLayer.bounds
            basicAnimation.toValue = newLayer.bounds
            animations.append(basicAnimation)
        }
        
        if oldLayer.opacity != newLayer.opacity
        {
            let basicAnimation = CABasicAnimation(keyPath: "opacity")
            basicAnimation.fromValue = oldLayer.opacity
            basicAnimation.toValue = newLayer.opacity
            animations.append(basicAnimation)
            
        }
        
        if animations.count > 0 {
            animGroup = CAAnimationGroup()
            animGroup!.animations = animations
        }
        return animGroup
        
        
    }
    
    func animatableLayerCopy(layer: CATextLayer) -> CATextLayer {
        let copyLayer = CATextLayer()
        copyLayer.opacity = layer.opacity
        copyLayer.bounds = layer.bounds
        copyLayer.transform = layer.transform
        copyLayer.position = layer.position
        
        return copyLayer
        
    }

}

extension LCLayerAnimation: CAAnimationDelegate{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if self.completion != nil {
            self.textLayer?.removeAnimation(forKey: textAnimationGroupKey)
            self.completion?(flag)
        }
    }
}

