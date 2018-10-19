//
//  LCTextAnimationLabel.swift
//  TextAnimations
//
//  Created by 罗超 on 2018/10/18.
//  Copyright © 2018年 罗超. All rights reserved.
//

import UIKit

typealias void_voidClosure = ()->()
typealias textAnimationClosure = void_voidClosure
typealias effectAniamtableLayerClosure = (_ layer: CATextLayer)->CATextLayer

class LCTextAnimationLabel: UILabel{

    var oldCharTextLayers = [CATextLayer]()
    var newCharTextLayers = [CATextLayer]()
    
    let textStorage = NSTextStorage(string: "")
    let textLayoutManager = NSLayoutManager()
    let textContainer = NSTextContainer()
    
    var animationOut: textAnimationClosure?
    var animaionIn: textAnimationClosure?
    
    func setup() {
        textStorage.addLayoutManager(textLayoutManager)
        textLayoutManager.addTextContainer(textContainer)
        textLayoutManager.delegate = self
        textContainer.size = bounds.size
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            super.bounds = newValue
            textContainer.size = newValue.size
        }
    }
    
    override var numberOfLines: Int {
        get {
            return super.numberOfLines
        }
        set {
            super.numberOfLines = newValue
            textContainer.maximumNumberOfLines = newValue
        }
    }
    
    override var lineBreakMode: NSLineBreakMode {
        get {
            return super.lineBreakMode
        }
        set {
            super.lineBreakMode = newValue
            textContainer.lineBreakMode = newValue
        }
    }
    
    override var text: String! {
        get {
            return super.text
        }
        
        set {
            super.text = newValue
            self.attributedText = interanlAttributedText(string: newValue)
        }
    }
    
    override var attributedText: NSAttributedString! {
        get {
            return self.textStorage
        }
        
        set {
            clearOldCharTextLayers()
            oldCharTextLayers = newCharTextLayers
            textStorage.setAttributedString(newValue)
            
            startAniamtion{}
            endAnimation{}
        }
    }
    
    
}

//MARK: NSLayoutManagerDelegate
extension LCTextAnimationLabel: NSLayoutManagerDelegate{
    public func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        calculateTextLayers()
    }
    
}
//MARK: Private
extension LCTextAnimationLabel {
    func calculateTextLayers() {
//        guard newCharTextLayers.count > 0 else{
//            return
//        }
        newCharTextLayers.removeAll()
        let text = textStorage.string
        let textRange = NSMakeRange(0, text.count)
        let attributedString = interanlAttributedText(string: text)
        let layoutRect = textLayoutManager.usedRect(for: textContainer)
        var index = textRange.location
        let textCount = textRange.length
        while index < textCount {
            let glyphRange = NSMakeRange(index, 1)
            let charRange = textLayoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let charContainer = textLayoutManager.textContainer(forGlyphAt: index, effectiveRange: nil)
            var glyphRect = textLayoutManager.boundingRect(forGlyphRange: glyphRange, in: charContainer!)
            
            let kerningRange = textLayoutManager.range(ofNominallySpacedGlyphsContaining: index)
            if kerningRange.location == index, kerningRange.length > 1 {
                if newCharTextLayers.count > 0 {
                    let previousLayer = newCharTextLayers.last!
                    var frame = previousLayer.frame
                    frame.size.width = frame.size.width + glyphRect.maxX - frame.maxX
                    previousLayer.frame = frame
                }
            }
            glyphRect.origin.y = glyphRect.origin.y + (self.bounds.size.height - layoutRect.size.height) * 0.5
            let textLayer = CATextLayer.init()
            textLayer.frame = glyphRect
            textLayer.string = attributedString.attributedSubstring(from: charRange)
            print(attributedString.attributedSubstring(from: charRange))
            textLayer.opacity = 0
//            textLayer.borderColor = UIColor.red.cgColor
//            textLayer.borderWidth = 1
            
            layer.addSublayer(textLayer)
            newCharTextLayers.append(textLayer)
            
            index = index + charRange.length
            
        }

    }
    
    func interanlAttributedText(string: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: string)
        let textRange = NSMakeRange(0, string.count)
        let paragraphyStyle = NSMutableParagraphStyle()
        paragraphyStyle.alignment = textAlignment
        attributedText.setAttributes([
                                        .paragraphStyle : paragraphyStyle,
                                        .foregroundColor: textColor,
                                        .font : font
                                        ], range: textRange)
        
        return attributedText
    }
    
    func clearOldCharTextLayers() -> Void {
        for textLayer in oldCharTextLayers {
            textLayer.removeFromSuperlayer()
        }
        oldCharTextLayers.removeAll()
    }
    
    func startAniamtion(animationClosure: textAnimationClosure) {
        var defaultDuration = 0.0;
        var defaultIndex = -1
        var index = 0
        
        for textLayer in oldCharTextLayers {
            let duration = TimeInterval(arc4random()%100)/125.0 + 0.35
            let delay = TimeInterval(arc4random_uniform(100))/500.0
            let distance = CGFloat(arc4random()%50) + 25
            let angle = CGFloat(Double(arc4random())/Double.pi*2 - Double.pi/4)
            
            var transform = CATransform3DMakeTranslation(0, distance, 0)
            transform = CATransform3DMakeRotation(angle, 0, 0, 1)
            
            if duration + delay > defaultDuration {
                defaultDuration = duration + delay
                defaultIndex = index
            }
            
            LCLayerAnimation.animation(textLayer: textLayer, duration: duration, delay: delay, effectAnimation: { oldLayer -> CATextLayer in
                oldLayer.transform = transform
                oldLayer.opacity = 0
                return oldLayer
            }) {[weak self] finished in
                textLayer.removeFromSuperlayer()
                print(finished)
            }
            
            index = index+1
            
        }
    }
    
    func endAnimation(animationClosure:textAnimationClosure)
    {
        
        
        for textLayer in newCharTextLayers
        {
            //            textLayer.opacity = 0.0
            let duration = TimeInterval(arc4random()%200/100)+0.25
            let delay = 0.06//NSTimeInterval(arc4random_uniform(100)/500)
            
            LCLayerAnimation.animation(textLayer: textLayer, duration: duration, delay: delay, effectAnimation: { oldLayer -> CATextLayer in
                textLayer.opacity = 1.0
                return textLayer
            }, completion: { finished in
    
            })
        }
        
    }

    
}
