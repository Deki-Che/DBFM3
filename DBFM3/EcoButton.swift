//
//  EcoButton.swift
//  DBFM3
//
//  Created by Deki on 15/10/21.
//  Copyright © 2015年 Deki. All rights reserved.
//

import UIKit

class EcoButton: UIButton {

    var isPlay: Bool = true
    let imgPlay : UIImage = UIImage(named: "play")!
    let imgPause: UIImage = UIImage(named: "pause")!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "onClick", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    func onClick() {
        isPlay = !isPlay
        if isPlay {
            self.setImage(imgPause, forState: UIControlState.Normal)
        } else {
            self.setImage(imgPlay, forState: UIControlState.Normal)
        }
    }
    
    func onPlay() {
        isPlay = true
        self.setImage(imgPause, forState: UIControlState.Normal)
    }
}
