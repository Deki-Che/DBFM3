//
//  orderButton.swift
//  DBFM3
//
//  Created by Deki on 15/10/21.
//  Copyright © 2015年 Deki. All rights reserved.
//

import UIKit

class orderButton: UIButton {
    var order:Int = 0
    let imageOrder1:UIImage = UIImage(named: "order1")!
    let imageOrder2:UIImage = UIImage(named: "order2")!
    let imageOrder3:UIImage = UIImage(named: "order3")!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         self.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func onClick(sender:UIButton) {
        order++
        if order == 1 {
            self.setImage(imageOrder1, forState: UIControlState.Normal)
        } else if order == 2 {
            self.setImage(imageOrder2, forState: .Normal)
        } else  if order == 3 {
            self.setImage(imageOrder3, forState: .Normal)
        } else if order > 3 {
            order = 1
            self.setImage(imageOrder1, forState: .Normal)
        }
    }
    
}
