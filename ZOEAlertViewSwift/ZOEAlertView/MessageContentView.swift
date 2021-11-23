//
//  MessageContentView.swift
//  AiyoyouCocoapods
//
//  Created by czc on 2021/10/18.
//  Copyright © 2021 aiyoyou. All rights reserved.
//

import Foundation
import UIKit

open class MessageContentView: UIView {
    lazy var messageLabel: UILabel? = {
        let msgLabel = UILabel()
        msgLabel.backgroundColor = UIColor.clear
        msgLabel.numberOfLines = 0
        return msgLabel
    }()
    
    lazy var textField: UITextField? = {
        let textF = UITextField.init()
        textF.layer.borderColor = UIColor.init(red: 207/255.0, green: 210/255.0, blue: 213/255.0, alpha: 1).cgColor
        textF.layer.borderWidth = 0.5
        textF.textAlignment = NSTextAlignment.left
        let leftView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 15, height: 34))
        leftView.backgroundColor = UIColor.clear
        textF.leftView = leftView
        textF.leftViewMode = UITextField.ViewMode.always
        textF.backgroundColor = UIColor.clear
        return textF
    }()

    lazy var paragraphStyle :NSMutableParagraphStyle? = {
        let style = NSMutableParagraphStyle()
        return style
    }()
    
    lazy private var attrStr: NSMutableAttributedString? = {
        let attr = NSMutableAttributedString()
       return attr
    }()
    
    
    lazy var textView: UITextView? = {
        let textV = UITextView.init(frame: CGRect.init(x: 0, y: 0, width: 270, height:98))
        textV.backgroundColor = UIColor.init(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        textV.layer.cornerRadius = 5
        textV.layer.masksToBounds = true
        textV.font = UIFont.systemFont(ofSize: 14)
        return textV
    }()
    
    
    func attrStrWithMessage(message: String) -> NSMutableAttributedString {
        if message.contains("<html")&&message.contains("<html") {
            do {
                if let msgData = message.data(using: String.Encoding.unicode, allowLossyConversion: true) {
                    attrStr = try NSMutableAttributedString.init(data: msgData, options: [NSMutableAttributedString.DocumentReadingOptionKey.documentType : NSMutableAttributedString.DocumentType.html,], documentAttributes: nil)
                    
                }
            } catch {
                attrStr = NSMutableAttributedString.init(string: message)
            }
            
            
        }else {
            attrStr = NSMutableAttributedString.init(string: message)
        }
        attrStr?.addAttribute(NSMutableAttributedString.Key.paragraphStyle, value: self.paragraphStyle as Any, range:NSRange.init(location: 0, length: (attrStr?.string.count)!))
        if messageLabel != nil {
            messageLabel!.attributedText = attrStr;
        }
        return attrStr!
    }
    
}
