//
//  EkoImage.swift
//  DBFM3
//
//  Created by Deki on 15/10/19.
//  Copyright © 2015年 Deki. All rights reserved.
//

import UIKit

class EkoImage: UIImageView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).CGColor
        
    }
    
    func onRatation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = M_PI*2
        animation.duration = 5
        animation.repeatCount = 10000
        self.layer.addAnimation(animation, forKey: nil) 
    }
}
