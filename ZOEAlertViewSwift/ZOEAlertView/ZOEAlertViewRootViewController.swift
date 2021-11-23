//
//  ZOEAlertViewRootViewController.swift
//  AiyoyouCocoapods
//
//  Created by czc on 2021/10/18.
//  Copyright © 2021 aiyoyou. All rights reserved.
//

import Foundation
import UIKit

open class ZOEAlertViewRootViewController: UIViewController {
    
    open override var shouldAutorotate: Bool {
        true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait,.landscapeLeft,.landscapeRight]
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in self.view.subviews {
            view.frame = self.view.bounds
            
            if view.isKind(of: NSClassFromString("\(ZOEWindow.workName).ZOEAlertView") ?? self.classForCoder) {
                let contentView = view.value(forKeyPath:"alertContentView") as! UIView
                contentView.center = self.view.center
            }else if view.isKind(of: NSClassFromString("\(ZOEWindow.workName).ZOEActionSheet") ?? self.classForCoder) {
                view.layoutSubviews();
            }
        }
        
    }

}

