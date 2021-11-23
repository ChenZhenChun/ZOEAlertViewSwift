//
//  ZOEBaseView.swift
//  AiyoyouCocoapods
//
//  Created by czc on 2021/11/23.
//  Copyright © 2021 aiyoyou. All rights reserved.
//

import Foundation
import UIKit

open class ZOEBaseView: UIView {
    var myBlock:((Int)->())?
    
    //展示控件
    func showWithBlock(block:@escaping (_ buttonIndex:Int)->()) {
        
    }
    
    func showWithBlock(block:@escaping (_ buttonIndex:Int)->(),animated:Bool) {
        
    }
}
