//
//  ZOECommonHead.swift
//  AiyoyouCocoapods
//
//  Created by czc on 2021/10/18.
//  Copyright © 2021 aiyoyou. All rights reserved.
//

import Foundation
import UIKit

let kBtnH = (45.0)
let kBtnTagAppend = (200)
let ktitleFontSize = (16.0)
let kbuttonFontSize = (15.0)
let ktitleTextColor :UIColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
let kbuttonTextColor :UIColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)

//枚举使用"@objc"修饰时，枚举的原始值必须是整型（这里枚举需要使用kvc去读取，所以需要使用"@objc"进行修饰）
@objc enum ZOEStyle:Int {
    case Alert
    case Sheet
}



