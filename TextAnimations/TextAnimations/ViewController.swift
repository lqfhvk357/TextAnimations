//
//  ViewController.swift
//  TextAnimations
//
//  Created by 罗超 on 2018/10/18.
//  Copyright © 2018年 罗超. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    weak var textL: UILabel?
    
    private var textArray = [
        "What is design?",
        "Design Code By Swift",
        "Design is not just",
        "what it looks like",
        "and feels like.",
        "Hello,Swift",
        "is how it works.",
        "- Steve Jobs",
        "Older people",
        "sit down and ask,",
        "'What is it?'",
        "but the boy asks,",
        "'What can I do with it?'.",
        "- Steve Jobs",
        "Swift",
        "Objective-C",
        "iPhone", "iPad", "Mac Mini",
        "MacBook Pro", "Mac Pro",
        "爱老婆"
    ]
    var index = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let animL = LCTextAnimationLabel.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 200))
        animL.textAlignment = .center
        animL.font = UIFont.systemFont(ofSize: 40)
        animL.text = "Swift"
        self.view.addSubview(animL)
        textL = animL
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if index >= textArray.count {
            index = 0
        }
        textL?.text = textArray[index]
        index = index + 1
    }

}


