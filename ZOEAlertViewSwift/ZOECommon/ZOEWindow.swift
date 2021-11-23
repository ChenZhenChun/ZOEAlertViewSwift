//
//  ZOEWindow.swift
//  AiyoyouCocoapods
//
//  Created by czc on 2021/10/18.
//  Copyright © 2021 aiyoyou. All rights reserved.
//

import Foundation
import UIKit

 final class ZOEWindow : UIWindow  {
    static let shareInstance = ZOEWindow(frame: UIScreen.main.bounds)
    static var stackArray:NSMutableArray = NSMutableArray()
    static let workName = Bundle.main.infoDictionary?["CFBundleExecutable"] as! String
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.windowLevel = UIWindow.Level.alert
        self.backgroundColor = UIColor.clear
        
        let class_VC = NSClassFromString("\(ZOEWindow.workName).ZOEAlertViewRootViewController") as! UIViewController.Type
        let rootViewController = class_VC.init()
        self.rootViewController = rootViewController

        self.makeKeyAndVisible()
        let window = UIApplication.shared.delegate?.window
        window!!.makeKeyAndVisible()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


