//
//  ZOEAlertView.swift
//  AiyoyouCocoapods
//
//  Created by czc on 2021/10/18.
//  Copyright © 2021 aiyoyou. All rights reserved.
//

import Foundation
import UIKit

enum ZOEAlertViewStyle {
    case Default
    case SecureTextInput
    case PlainTextInput
    case TextViewInput
}

let kalertViewW = (300.0)

//默认属性参数
let klineSpacing = (5.0)
let kmessageFontSize = (15.0)
let kmessageTextColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
let koKButtonTitleTextColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)


/**
 alertView中的MsgCustomContentView区域是可以高度定制的（如果不自定义默认情况下有三种模板ZOEAlertViewStyle）；
 ZOEAlertView通过代理的形式将MsgCustomContentView区域委托出去
 代理对象只要通过heightForMessageContentView协议设置MsgCustomContentView的高度，
 通过messageContentViewWithZOEAlertView协议设置MsgCustomContentView的实例，就可以对MsgCustomContentView
 实现自定义
 调用handleKeyboard:方法可以解决自定义msgCustomContentView中输入框被键盘遮挡的问题。
 ___________________
 |                  title                  |
 |_______________________|
 | ______________________ |
 ||                                         ||
 ||     MessageContentView ||
 ||______________________ ||
 | ______________________ |
 ||                                         ||
 || MsgCustomContentView||
 ||______________________ ||
 |_______________________|
 |                     |                    |
 |   cancel       |    OK           |
 |___________|___________|
 
 */
protocol ZOEAlertViewDelegate:NSObjectProtocol {
    /**
     实现代理协议方法必须在方法前方添加 @objc，并且带参数的协议方法形参前必须加‘_’
     */
    func heightForMessageContentView() ->CGFloat
    func messageContentViewWithZOEAlertView(_ alertView:ZOEAlertView) ->UIView
}


open class ZOEAlertView: ZOEBaseView {
    
    @objc private(set) lazy var alertContentView:UIView? = {
        let contentView = UIView.init()
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10*scale
        contentView.backgroundColor = UIColor.white
        return contentView
    }()
    
    private(set) lazy var titleLabel:UILabel? = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        label.textColor = titleTextColor
        return label
    }()
    
    private(set) lazy var messageContentView:MessageContentView? = {
       let msgContentView = MessageContentView()
        msgContentView.backgroundColor = UIColor.clear
        return msgContentView
    }()
    
    //代理属性需要使用weak修饰，防止循环引用
    weak var _delegate:ZOEAlertViewDelegate?
    weak var delegate:ZOEAlertViewDelegate? {
        set {
            _delegate = newValue
            if _delegate != nil && _delegate!.responds(to:Selector(("messageContentViewWithZOEAlertView:"))) {
                msgCustomContentView = _delegate?.messageContentViewWithZOEAlertView(self)
                self.configFrame()
                alertContentView?.addSubview(msgCustomContentView!)
            }
        }
        get {
            return _delegate
        }
    }
    
    var _lineSpacing = klineSpacing
    var lineSpacing:CGFloat {
        set {
            _lineSpacing = newValue
            self.messageContentView?.paragraphStyle?.lineSpacing = _lineSpacing*scale
            self.configFrame()
        }
        
        get {
            return _lineSpacing
        }
    }//message lineSpacing,default is 5.
    
    var _titleFontSize = ktitleFontSize
    var titleFontSize:CGFloat {
        set {
            if titleLabel != nil {
                _titleFontSize = newValue
                titleLabel?.font = UIFont.systemFont(ofSize: _titleFontSize)
            }
        }
        get {
            return _titleFontSize
        }
    }//titleLabel font size,default is 16.
    
    var _messageFontSize = kmessageFontSize
    var messageFontSize:CGFloat {
        set {
            if (_message != nil) && (_message!.count>0) {
                _messageFontSize = newValue
                self.messageContentView?.messageLabel?.font = UIFont.systemFont(ofSize: _messageFontSize)
                self.configFrame()
            }
        }
        get {
            return _messageFontSize
        }
    }//messageLabel font size,default is 15.
    
    
    var _buttonFontSize = kbuttonFontSize
    var buttonFontSize:CGFloat {
        set {
            if !_otherButtonTitles.isEmpty {
                _buttonFontSize = newValue
                for btn in _otherButtonTitles {
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: _buttonFontSize)
                }
            }
        }
        get {
            return _buttonFontSize
        }
    }//uibutton font size,default is 15.
    
    private var isRedraw_showWithBlock:Bool = false//调用showWithBlock 方法时是否需要重绘，默认不需要重绘。
    var _buttonHeight = kBtnH
    var buttonHeight:CGFloat {
        set {
            _buttonHeight = newValue
            isRedraw_showWithBlock = true
        }
        get {
            return _buttonHeight
        }
    }
    
    var _scale:CGFloat = 0;
    var scale:CGFloat {
        set {
            _scale = newValue
            isRedraw_showWithBlock = true
        }
        get {
            if _scale==0 {
                _scale = UIScreen.main.bounds.size.height>480 ? UIScreen.main.bounds.size.height/667.0 : 0.851574
            }
            if _scale>1 {
                _scale = 1
            }
            return _scale
        }
    }//界面缩放比例

    var _titleTextColor:UIColor = ktitleTextColor
    var titleTextColor:UIColor {
        set {
            if titleLabel != nil {
                _titleTextColor = newValue
                titleLabel?.textColor = _titleTextColor
            }
        }
        get {
            return _titleTextColor
        }
    }
    
    private var _message:String?
    var _messageTextColor:UIColor = kmessageTextColor
    var messageTextColor:UIColor {
        set {
            if (_message != nil) && (_message!.count>0) {
                _messageTextColor = newValue
                self.messageContentView?.messageLabel?.textColor = _messageTextColor
            }
        }
        get {
            return _messageTextColor
        }
    }
    
    
    private var _otherButtonTitles:[UIButton] = {
        let otherBtnTitles = [UIButton]()
        return otherBtnTitles
    }()
    var _buttonTextColor:UIColor = kbuttonTextColor
    var buttonTextColor:UIColor {
        set {
            _buttonTextColor = newValue
            if !_otherButtonTitles.isEmpty {
                for btn in _otherButtonTitles {
                    btn.setTitleColor(_buttonTextColor, for: UIControl.State.normal)
                }
            }
        }
        get {
            return _buttonTextColor
        }
    }
    
    let cancelButtonIndex:Int = 0;
    
    
    var _messageTextAlignment:NSTextAlignment = NSTextAlignment.center
    /// messageLabel TextAlignment,default is NSTextAlignmentCenter
    var messageTextAlignment:NSTextAlignment {
        set {
            _messageTextAlignment = newValue
            self.configFrame()
        }
        get {
            return _messageTextAlignment
        }
    }
    
    
    var _alertViewStyle = ZOEAlertViewStyle.Default
    var alertViewStyle:ZOEAlertViewStyle {
        set {
            _alertViewStyle = newValue
            if (_alertViewStyle == ZOEAlertViewStyle.SecureTextInput)||(_alertViewStyle == ZOEAlertViewStyle.PlainTextInput) {
                self.messageContentView?.textField?.delegate = self
                self.alertContentView!.addSubview(self.messageContentView!)
                self.messageContentView!.addSubview(self.messageContentView!.textField!)
            }else if _alertViewStyle == ZOEAlertViewStyle.TextViewInput {
                self.messageContentView?.textView?.delegate = self
                self.alertContentView!.addSubview(self.messageContentView!)
                self.messageContentView!.addSubview(self.messageContentView!.textView!)
            }
            self.configFrame()
        }
        get {
            return _alertViewStyle
        }
    }
    
    var _textFieldPlaceholder:String?
    var textFieldPlaceholder:String? {
        set {
            _textFieldPlaceholder = newValue
            if (alertViewStyle == ZOEAlertViewStyle.SecureTextInput)||(alertViewStyle == ZOEAlertViewStyle.PlainTextInput) {
                self.messageContentView?.textField?.placeholder = _textFieldPlaceholder
            }
        }
        get {
            return _textFieldPlaceholder
        }
    }
    
    //disAble使用过程中是使用KVC取值的，也就是基于runtime，所以需要加"@objc"。其实只要是根据KVC取值的不管是属性还是方法都需要加"@objc"修饰
    @objc var disAble:Bool = true//是否可被代码dismiss（不点击操作button）,default is true
    
    private(set) lazy var textField:UITextField? = {
        if (alertViewStyle == ZOEAlertViewStyle.SecureTextInput)||(alertViewStyle == ZOEAlertViewStyle.PlainTextInput) {
            return self.messageContentView?.textField;
        }
        print("ZOEAlertViewStyle is ZOEAlertViewStyleDefault, so the textField returns nil")
        return nil
    }()
    
    var alertDescription:String?
    
    private var keyboardIsVisible:Bool = false
    private var _title:String?
    private var msgCustomContentView:UIView?//自定义View
    private lazy var operationalView:UIView? = {
       let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    private var _cancelButtonTitle:String?
    private var _animated:Bool = false
    private var clickButtonIndex:Int = 0
    private var isVisible:Bool = false
    @objc private var zoeStyle:ZOEStyle = ZOEStyle.Alert
    private var _shouldDisBlock:((Int)->(Bool))?
    private var _didDisBlock:((Int)->())?
    private lazy var tipLabel:UILabel? = {
        let label = UILabel()
        label.bounds = CGRect(x: 0, y: 30, width: 300, height: 30)
        label.center = CGPoint(x: self.alertContentView!.frame.size.width/2.0, y: self.alertContentView!.frame.size.height/2.0)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.init(white: 0, alpha: 0.7)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15*scale)
        label.textAlignment = NSTextAlignment.center
        label.isUserInteractionEnabled = false
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        return label
    }()

    private override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    convenience init (title:String?,message:String?,cancelButtonTitle:String?) {
        self.init(frame: UIScreen.main.bounds)
        self.initConfig(title: title, message: message, cancelButtonTitle: cancelButtonTitle)
        self.alertContentView?.addSubview(self.operationalView!)
        isRedraw_showWithBlock = false
        self.drawLine()
        self.configFrame()
    }
    
    convenience init (title:String?,message:String?,cancelButtonTitle:String?,otherButtonTitles:String...) {
        self.init(frame: UIScreen.main.bounds)
        self.initConfig(title: title, message: message, cancelButtonTitle: cancelButtonTitle)
        //添加other按钮
        if  otherButtonTitles.count>0 {
            for btnTitle in otherButtonTitles {
                self.addButtonWithTitle(title:btnTitle)
            }
        }
        self.alertContentView?.addSubview(self.operationalView!)
        isRedraw_showWithBlock = false
        self.drawLine()
        self.configFrame()
    }
    
    private func initConfig (title:String?,message:String?,cancelButtonTitle:String?) {
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow),name:UIResponder.keyboardWillShowNotification, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object:nil)
        _title = title
        _message = message
        _cancelButtonTitle = cancelButtonTitle
        textFieldPlaceholder = ""
        
        //添加子控件
        self.addSubview(self.alertContentView!)
        //添加titleLabel
        if _title != nil && _title!.count>0 {
            alertContentView?.addSubview(self.titleLabel!)
            self.titleLabel?.text = _title
        }
        
        //添加消息详情Label
        if _message != nil && _message!.count>0 {
            self.messageContentView?.messageLabel?.textColor = _messageTextColor
            self.messageContentView?.paragraphStyle?.lineSpacing = _lineSpacing
            self.messageContentView?.attrStrWithMessage(message: _message!)
            self.messageContentView?.messageLabel?.font = UIFont.systemFont(ofSize: messageFontSize)
            self.messageContentView?.addSubview(self.messageContentView!.messageLabel!)
            alertContentView?.addSubview(self.messageContentView!)
        }
        
        //取消按钮
        if _cancelButtonTitle != nil && _cancelButtonTitle!.count>0 {
            let cancelButton:UIButton = Self.createButton()
            cancelButton.setTitle(_cancelButtonTitle, for: UIControl.State.normal)
            cancelButton.addTarget(self, action: #selector(clickButton), for: UIControl.Event.touchUpInside)
            cancelButton.setTitleColor(buttonTextColor, for: UIControl.State.normal)
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize)
            _otherButtonTitles.append(cancelButton)
        }
    }
    
    private static func createButton()-> UIButton {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.backgroundColor = UIColor.clear
        return btn
    }
    
    //展示控件
    override public func showWithBlock(block:@escaping (_ buttonIndex:Int)->()) {
        myBlock = block
        _animated = false
        if  _otherButtonTitles.count>0 {
            if isRedraw_showWithBlock {
                isRedraw_showWithBlock = false
                self.drawLine()
                self.configFrame()
            }
            
            if !isVisible {
                let window:UIWindow = UIApplication.shared.delegate!.window!!
                window.endEditing(true)
            }
            
            if alertViewStyle == ZOEAlertViewStyle.Default {
                if !isVisible {
                    ZOEWindow.shareInstance.endEditing(false)
                }
            }else if alertViewStyle == ZOEAlertViewStyle.SecureTextInput || alertViewStyle == ZOEAlertViewStyle.PlainTextInput {
                self.messageContentView?.textField?.becomeFirstResponder()
            }else if alertViewStyle == ZOEAlertViewStyle.TextViewInput {
                self.messageContentView?.textView?.becomeFirstResponder()
            }
            
            isVisible = true
            //如果alertView重复调用show方法，先将数组中原来的对象移除，然后继续添加到数组的最后面，
            for view in ZOEWindow.stackArray {
                if view is ZOEAlertView {
                    let alertView = view as! ZOEAlertView
                    if alertView == self {
                        alertView.isHidden = false
                        ZOEWindow.stackArray.remove(view)
                        break
                    }
                }
            }
            ZOEWindow.stackArray.add(self)
            ZOEWindow.shareInstance.rootViewController?.view.addSubview(self)
            ZOEWindow.shareInstance.isHidden = false
            //有新的alertView被展现，所以要将前一个alertView暂时隐藏
            if (ZOEWindow.stackArray.count-1)>0 {
                let alertView:UIView = ZOEWindow.stackArray[ZOEWindow.stackArray.count-2] as! UIView
                alertView.isHidden = true
            }
            
            //设置延迟解决UILabel渲染缓慢的问题。
            self.alertContentView?.alpha = 0
            UIView.animate(withDuration: 0.2, delay: 0.00001, options: UIView.AnimationOptions()) {
                self.alertContentView?.alpha = 1
            } completion: { finished in
            }
            
        }else {
            ZOEWindow.shareInstance.isHidden = true
        }

        
    }
    
    override func showWithBlock(block:@escaping (_ buttonIndex:Int)->(),animated:Bool) {
        self.showWithBlock(block: block)
        _animated = animated
        if _animated {
            if _otherButtonTitles.count>0 {
                var center:CGPoint = self.alertContentView!.center
                center.y -= 100
                self.alertContentView?.center = center
                /**
                 usingSpringWithDamping 弹动比率 0~1，数值越小，弹动效果越明显
                 initialSpringVelocity 则表示初始的速度，数值越大一开始移动越快,值得注意的是，初始速度取值较高而时间较短时，也会出现反弹情况
                 **/
                UIView.animate(withDuration: 1, delay: 0.00001, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: UIView.AnimationOptions()) {
                    center.y += 100
                    self.alertContentView?.center = center
                } completion: { finished in
                }

            }
        }
    }
    
    private func configFrame() {
        //必须至少有一个操作按钮才能展现控件
        if !_otherButtonTitles.isEmpty {
            let allBtnH = _otherButtonTitles.count<3 ? self.buttonHeight : self.buttonHeight*CGFloat(_otherButtonTitles.count)
            var alertViewH = allBtnH+20//底部按钮操作区域高度+20点的空白
            
            //title区域frame设置
            if titleLabel != nil {
                alertViewH += 30+titleLabel!.font.pointSize
                titleLabel?.frame = CGRect(x: 15*scale, y: 30, width: kalertViewW*scale-30*scale, height: titleLabel!.font.pointSize)
            }
            
            //message区域frame设置
            //默认messageContentView模板frame设置
            if _message != nil && _message!.count>0 {
                var y:CGFloat = 0
                if titleLabel != nil {
                    y = titleLabel!.frame.maxY+20
                    alertViewH += 20
                }else {
                    y = 30
                    alertViewH += 30
                }
                
                self.messageContentView?.frame = CGRect(x: 28*scale, y: y, width: kalertViewW*scale-56*scale, height: 0)
                self.messageContentView?.messageLabel?.frame = self.messageContentView!.bounds
                self.messageContentView?.attrStrWithMessage(message: _message!)
                self.messageContentView?.messageLabel?.font = UIFont.systemFont(ofSize: _messageFontSize)
                self.messageContentView?.messageLabel?.sizeToFit()
                var textFieldH:CGFloat = 0
                var messageLBottom:CGFloat = 0
                if _alertViewStyle == ZOEAlertViewStyle.SecureTextInput || _alertViewStyle == ZOEAlertViewStyle.PlainTextInput {
                    textFieldH = 44*scale
                    messageLBottom = 20
                }else if alertViewStyle == ZOEAlertViewStyle.TextViewInput {
                    textFieldH = 88*scale
                    messageLBottom = 20
                }
                
                //alertViewH大于屏幕高度-200，那么对这个判断做等法判断出相等时messageContentView的高度
                if (self.messageContentView?.messageLabel!.frame.size.height)!+messageLBottom+textFieldH+alertViewH > self.frame.size.height-200*scale {
                    self.messageContentView?.frame = CGRect(x: 28*scale, y: y, width: kalertViewW*scale-56*scale, height: self.frame.size.height-200*scale-alertViewH)
                    if alertViewStyle != ZOEAlertViewStyle.Default {
                        self.messageContentView?.messageLabel?.frame = CGRect(x: 0, y: 0, width: kalertViewW*scale-56*scale, height: self.frame.size.height-200*scale-alertViewH-textFieldH-messageLBottom)
                        self.textFieldConfigByAlertViewStyleWithY(y: (self.messageContentView?.messageLabel?.frame.maxY)!)
                    }else {
                        self.messageContentView?.messageLabel?.frame = CGRect(x: 0, y: 0, width: kalertViewW*scale-56*scale, height: self.frame.size.height-200*scale-alertViewH-messageLBottom)
                    }
                }else {
                    self.messageContentView?.frame = CGRect(x: 28*scale, y: y, width: kalertViewW*scale-56*scale, height: (self.messageContentView?.messageLabel?.frame.size.height)!+messageLBottom+textFieldH)
                    if alertViewStyle != ZOEAlertViewStyle.Default {
                        self.messageContentView?.messageLabel?.frame = CGRect(x: 0, y: 0, width: kalertViewW*scale-56*scale, height: (self.messageContentView?.frame.size.height)!-textFieldH-messageLBottom)
                        self.textFieldConfigByAlertViewStyleWithY(y: (self.messageContentView?.messageLabel?.frame.maxY)!)
                    }else {
                        self.messageContentView?.messageLabel?.frame = CGRect(x: 0, y: 0, width: kalertViewW*scale-56*scale, height: self.messageContentView!.messageLabel!.frame.size.height)
                    }
                }
                //使用sizeToFit之后对齐方式失效，
                self.messageContentView?.messageLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
                self.messageContentView?.messageLabel?.textAlignment = messageTextAlignment
                alertViewH += (self.messageContentView?.frame.size.height)!
            }else {
                if alertViewStyle != ZOEAlertViewStyle.Default {
                    var y:CGFloat = 0
                    if titleLabel != nil {
                        y = titleLabel!.frame.maxY+20
                        alertViewH += 20
                    }else {
                        y = 30
                        alertViewH += 30
                    }
                    
                    var height = 44*scale
                    if alertViewStyle == ZOEAlertViewStyle.TextViewInput {
                        height = 88*scale
                    }
                    
                    self.messageContentView?.frame = CGRect(x: 28*scale, y: y, width: kalertViewW*scale-56*scale, height: height)
                    self.textFieldConfigByAlertViewStyleWithY(y: -20*scale)
                    self.messageContentView?.messageLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    self.messageContentView?.messageLabel?.textAlignment = messageTextAlignment
                    alertViewH += (self.messageContentView?.frame.size.height)!
                }
            }
            
            if self.delegate != nil && self.delegate!.responds(to:Selector(("heightForMessageContentView"))) {
                //代理视图
                var y:CGFloat = 0
                if titleLabel != nil {
                    y = titleLabel!.frame.maxY+20
                    alertViewH += 20
                }else {
                    y = 30
                    alertViewH += 30
                }
                let msgContentViewheight:CGFloat = self.delegate!.heightForMessageContentView()
                msgCustomContentView?.frame = CGRect(x: 28*scale, y: y+self.messageContentView!.frame.size.height, width: kalertViewW*scale-56*scale, height: msgContentViewheight)
                alertViewH += msgContentViewheight
            }
            
            //按钮操作区frame设置
            self.operationalView?.frame = CGRect(x: 0, y: alertViewH-allBtnH, width: kalertViewW*scale, height: allBtnH)
            if _otherButtonTitles.count == 2 {
                let btn = _otherButtonTitles[0];
                let btn1 = _otherButtonTitles[1];
                btn.frame = CGRect(x: 0, y: 0, width: kalertViewW*scale/2.0, height: self.buttonHeight)
                btn1.frame = CGRect(x: kalertViewW*scale/2.0, y: 0, width: kalertViewW*scale/2.0, height: self.buttonHeight)
            }else {
                for (i,btn) in _otherButtonTitles.enumerated() {
                    btn.frame = CGRect(x: 0, y: CGFloat(_otherButtonTitles.count-1-i)*self.buttonHeight, width: kalertViewW*scale, height: self.buttonHeight)
                }
            }
            alertContentView?.frame = CGRect(x: 0, y: 0, width: kalertViewW*scale, height: alertViewH)
            self.alertContentView?.center = self.center
        }
    }
    
    private func textFieldConfigByAlertViewStyleWithY(y:CGFloat) {
        if alertViewStyle == .PlainTextInput {
            self.messageContentView?.textField?.isSecureTextEntry = false
            self.messageContentView?.textField?.placeholder = textFieldPlaceholder
            self.messageContentView?.textField?.font = UIFont.systemFont(ofSize: messageFontSize)
            self.messageContentView?.textField!.frame = CGRect(x: 0, y: y+20*scale, width: kalertViewW*scale-56*scale, height: 44*scale)
        }else if alertViewStyle == .SecureTextInput {
            self.messageContentView?.textField?.isSecureTextEntry = true
            self.messageContentView?.textField?.placeholder = textFieldPlaceholder
            self.messageContentView?.textField?.font = UIFont.systemFont(ofSize: messageFontSize)
            self.messageContentView?.textField!.frame = CGRect(x: 0, y: y+20*scale, width: kalertViewW*scale-56*scale, height: 44*scale)
        }else if alertViewStyle == .TextViewInput {
            self.messageContentView?.textView!.frame = CGRect(x: 0, y: y+20*scale, width: kalertViewW*scale-56*scale, height: 88*scale)
        }
    }
    
    private func drawLine() {
        for view in self.operationalView!.subviews {
            if view.tag == 74129 {
                view.removeFromSuperview()
            }
        }
        var buttonIndex = (_cancelButtonTitle != nil && _cancelButtonTitle!.count>0) ? 0 : 1
        if  _otherButtonTitles.count == 2 {
            for btn in _otherButtonTitles {
                btn.tag = kBtnTagAppend+buttonIndex
                buttonIndex += 1
                self.operationalView?.addSubview(btn)
            }
            let line = UIView(frame: CGRect(x: 0, y: 0, width: kalertViewW*scale, height: 0.5))
            line.backgroundColor = UIColor(red: 207/255.0, green: 210/255.0, blue: 213/255.0, alpha: 1)
            line.tag = 74129
            self.operationalView?.addSubview(line)
            
            let line1 = UIView(frame: CGRect(x: kalertViewW*scale/2.0, y: 0, width: 0.5, height: self.buttonHeight))
            line1.backgroundColor = UIColor(red: 207/255.0, green: 210/255.0, blue: 213/255.0, alpha: 1)
            line1.tag = 74129
            self.operationalView?.addSubview(line1)
            
        }else {
            for (i,btn) in _otherButtonTitles.enumerated() {
                btn.tag = kBtnTagAppend+buttonIndex
                buttonIndex += 1
                self.operationalView?.addSubview(btn)
                let line = UIView(frame: CGRect(x: 0, y: 0+CGFloat(i)*self.buttonHeight, width: kalertViewW*scale, height: 0.5))
                line.backgroundColor = UIColor(red: 207/255.0, green: 210/255.0, blue: 213/255.0, alpha: 1)
                line.tag = 74129
                self.operationalView?.addSubview(line)
            }
        }
    }
    
    //操作按钮点击事件
    @objc private func clickButton(sender:UIButton) {
        clickButtonIndex = sender.tag-kBtnTagAppend
        self.removeFromSuperview()
        if self.myBlock != nil && isVisible {
            self.myBlock!(self.clickButtonIndex)
        }
    }
    
    open override func removeFromSuperview() {
        if _shouldDisBlock != nil && !_shouldDisBlock!(clickButtonIndex) {
            isVisible = true
            self.showWithBlock(block: self.myBlock!)
            print("Instance method 'shouldDismissWithBlock:' return NO")
            return
        }else {
            isVisible = false
        }
        super.removeFromSuperview()
        if _didDisBlock != nil {
            _didDisBlock!(clickButtonIndex)
        }
        
        //有可能不是按照数组倒序的顺序移除，所以需要遍历数组
        //执行ZOEWindow.stackArray.remove;_myBlock引用会消失（只出现在某个系统），所以这边做一下缓存。
        let myBlockTemp:((Int)->())? = myBlock
        for view in ZOEWindow.stackArray {
            if view is ZOEAlertView {
                if view is ZOEAlertView {
                    let alertView = view as! ZOEAlertView
                    if alertView == self {
                        ZOEWindow.stackArray.remove(view)
                        break
                    }
                }
                
            }
        }
        
        myBlock = myBlockTemp
        
        //将数组的最后一个alertView显示出来
        if ZOEWindow.stackArray.count>0 {
            let view = ZOEWindow.stackArray[ZOEWindow.stackArray.count-1]
            if view is ZOEAlertView {
                let alertView = view as! ZOEAlertView
                alertView.showWithBlock(block: alertView.myBlock!, animated: alertView._animated)
            }else {
                let actionSheet = view as! ZOEBaseView
                actionSheet.showWithBlock(block: actionSheet.myBlock!)
            }
        }
        
        //当数组中没有alertView时将父容器隐藏。
        if ZOEWindow.stackArray.count == 0 {
            ZOEWindow.shareInstance.isHidden = true
        }
    }
    
    /// 移除当前的alertView（不会触发block回调）
    func dismissZOEAlertView() {
        clickButtonIndex = -1
        self.removeFromSuperview()
    }
    
    
    /// alertView是否可以dismiss(满足点击按钮去执行一些验证操作，最终通过Block返回值判断是否需要dismiss控件😂)
    /// - Parameter shouldDisBlock: shouldDisBlock 回调
    func shouldDismissWithBlock(shouldDisBlock:@escaping (_ buttonIndex:NSInteger)->(Bool)) {
        _shouldDisBlock = shouldDisBlock
    }
    
    
    /// alertView已经消失
    /// - Parameter didDisBlock: didDisBlock 回调
    func didDismissWithBlock(didDisBlock:@escaping (_ buttonIndex:Int)->()) {
        _didDisBlock = didDisBlock
    }
    
    
    /// 根据buttonIndex 设置button文字颜色
    /// - Parameters:
    ///   - color: 文字颜色
    ///   - buttonIndex: 按钮索引，cancelButtonIndex=0 otherButtonTitles以此类推
    func setButtonTextColor(color:UIColor,buttonIndex:Int) {
        let btn:UIButton? = (self.operationalView?.viewWithTag(buttonIndex+kBtnTagAppend)) as! UIButton?
        if btn != nil {
            btn?.setTitleColor(color, for: UIControl.State.normal)
        }
    }
    
    
    /// 通过title添加Button
    /// - Parameter title: 按钮文本
    func addButtonWithTitle(title:String) {
        if title.isEmpty {
            return
        }
        let btn = ZOEAlertView.createButton()
        btn.setTitle(title, for: UIControl.State.normal)
        btn.addTarget(self, action:#selector(clickButton), for: UIControl.Event.touchUpInside)
        btn.setTitleColor(buttonTextColor, for:UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize)
        _otherButtonTitles.append(btn)
        isRedraw_showWithBlock = true
    }
    
    /// 移除所有ZOEAlertView（不会触发block回调）
    static func dismissAllZOEAlertView() {
        let predicate = NSPredicate(format: " disAble=1 AND zoeStyle = 0 ")
        let data = ZOEWindow.stackArray.filtered(using: predicate)
        for obj in data {
            let alertView = obj as! ZOEAlertView
            alertView.dismissZOEAlertView()
        }
    }
    
    /// 获取单前所有AlertView
    /// - Returns: AllAlertView
    static func getAllAlertView()->Array<Any> {
        let predicate = NSPredicate(format: " zoeStyle = 0 ")
        let resultArray = ZOEWindow.stackArray.filtered(using: predicate)
        return resultArray
    }
    
    
    /// 处理键盘遮挡输入框的问题
    /// - Parameter textFieldOrTextView: UITextField 或 UITextView
    func handleKeyboard(textFieldOrTextView:UIView) {
        if textFieldOrTextView is UITextField {
            let textField:UITextField = textFieldOrTextView as! UITextField
            textField.delegate = self
        }else if textFieldOrTextView is UITextView {
            let textView:UITextView = textFieldOrTextView as! UITextView
            textView.delegate = self
        }
    }
    
    
    /// 展示提示性信息
    /// - Parameter message: 提示文本
    func showTipViewWithMessage(message:String) {
        if message.isEmpty {
            return
        }
        self.tipLabel?.text = message
        self.tipLabel?.sizeToFit()
        var frame:CGRect = self.tipLabel!.frame
        frame.size.width = frame.size.width+40
        if frame.size.width>(UIScreen.main.bounds.size.width-30) {
            frame.size.width = UIScreen.main.bounds.size.width-30
        }
        frame.size.height = frame.size.height+15
        tipLabel?.layer.cornerRadius = frame.size.height/2.0
        tipLabel?.frame = frame
        tipLabel?.center = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height*0.8)
        self.tipLabel?.alpha = 1
        //键盘弹出需要时间，如果在键盘弹出之前就加载提示语，提示语会被键盘遮挡，所以这边做了一个延迟处理。
        self.perform(#selector(handleTipViewAnimate), with: nil, afterDelay: 0.01)
    }
    
    private func keyboardView()->UIView {
        var keyboard:UIView?
        for tempWindow in UIApplication.shared.windows {
            for view in tempWindow.subviews {
                keyboard = view
                if keyboard!.description.hasPrefix("(lessThen)UIKeyboard") == true {
                    return keyboard!
                }
            }
            
            for potentialKeyboard in tempWindow.subviews {
                let systemVersion:Double = Double(UIDevice.current.systemVersion)!
                if  systemVersion >= 8.0 {
                    if potentialKeyboard.description.hasPrefix("<UILayoutContainerView") == true {
                        keyboard = potentialKeyboard
                    }
                }else if  systemVersion >= 3.2 {
                    if potentialKeyboard.description.hasPrefix("<UIPeripheralHost") == true {
                        keyboard = potentialKeyboard
                    }
                }else {
                    if potentialKeyboard.description.hasPrefix("<UIKeyboard") == true {
                        keyboard = potentialKeyboard
                    }
                }
            }
            
        }
        return keyboard!
    }
    
    @objc private func keyboardWillShow() {
        keyboardIsVisible = true
    }
    
    @objc  private func keyboardWillHide() {
        keyboardIsVisible = false
    }
    
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTipViewAnimate() {
        if self.keyboardIsVisible {
            let keyview = self.keyboardView()
            keyview.addSubview(self.tipLabel!)
        }else {
            self.addSubview(self.tipLabel!)
        }
        UIView.animate(withDuration: 0.5, delay: 2, options: UIView.AnimationOptions()) {
            self.tipLabel?.alpha = 0
        } completion: { finished in
        }

    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ZOEWindow.shareInstance.endEditing(true)
        self.alertContentView?.center = self.center
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension ZOEAlertView:UITextFieldDelegate,UITextViewDelegate {
    //UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        //获取textField在屏幕上的坐标
        let textFieldPoint:CGPoint = (textField.superview?.convert(textField.frame.origin, to: ZOEWindow.shareInstance))!
        let offet:CGFloat = textFieldPoint.y+textField.frame.size.height-(ZOEWindow.shareInstance.frame.size.height-216.0)+90//键盘高度216
        let animationDuration:TimeInterval = 0.3
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(animationDuration)
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if offet>0 {
            var centerPoint = self.alertContentView?.center
            centerPoint!.y = centerPoint!.y-offet
            self.alertContentView?.center = centerPoint!
        }
        UIView.commitAnimations()
    }
    //输入框编辑完成以后，将视图恢复到原始状态
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.alertContentView?.center = self.center
    }
    
    //textViewDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ZOEWindow.shareInstance.endEditing(true)
        self.alertContentView?.center = self.center
        return true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        //获取textField在屏幕上的坐标
        let textFieldPoint:CGPoint = (textView.superview?.convert(textView.frame.origin, to: ZOEWindow.shareInstance))!
        let offet:CGFloat = textFieldPoint.y+textView.frame.size.height-(ZOEWindow.shareInstance.frame.size.height-216.0)+90//键盘高度216
        let animationDuration:TimeInterval = 0.3
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(animationDuration)
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if offet>0 {
            var centerPoint = self.alertContentView?.center
            centerPoint!.y = centerPoint!.y-offet
            self.alertContentView?.center = centerPoint!
        }
        UIView.commitAnimations()
    }
    public func textViewDidEndEditing(_ textView: UITextView) {
        self.alertContentView!.center = self.center;
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        /**
         判断输入的字是否是回车，即按下return
         返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
         **/
        if text == "\n" {
            ZOEWindow.shareInstance.endEditing(true)
            return false
        }
        return true
    }
    
    
}
