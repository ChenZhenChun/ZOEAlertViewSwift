//
//  ZOEActionSheet.swift
//  AiyoyouCocoapods
//
//  Created by czc on 2021/11/2.
//  Copyright © 2021 aiyoyou. All rights reserved.
//

import Foundation
import UIKit

open class ZOEActionSheet: ZOEBaseView {
    
    private(set) lazy var titleLabel:UILabel? = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        label.textColor = titleTextColor
        return label
    }()
    
    var _titleFontSize = ktitleFontSize
    var titleFontSize:CGFloat {
        set {
            if titleLabel != nil {
                _titleFontSize = newValue
                titleLabel?.font = UIFont.systemFont(ofSize: _titleFontSize)
                self.configFrame()
                self.drawLine()
            }
        }
        get {
            return _titleFontSize
        }
    }//titleLabel font size,default is 16.
    
    
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
    
    private var isRedraw_showWithBlock:Bool = false//调用showWithBlock
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
    
    //disAble使用过程中是使用KVC取值的，也就是基于runtime，所以需要加"@objc"。其实只要是根据KVC取值的不管是属性还是方法都需要加"@objc"修饰
    @objc var disAble:Bool = true//是否可被代码dismiss（不点击操作button）,default is true
    
    var actionDescription:String?
    @objc private var zoeStyle:ZOEStyle = ZOEStyle.Sheet
    @objc private(set) lazy var actionSheetContentView:UIView? = {
        let contentView = UIView.init()
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10*scale
        contentView.backgroundColor = UIColor.clear
        return contentView
    }()
    
    @objc private(set) lazy var contentView:UIView? = {
        let view = UIView.init()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10*scale
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private var _cancelButtonTitle:String?
    private var _title:String?
    private var _cancelButton:UIButton?
    private var clickButtonIndex:Int = 0
    private var oldCenterPoint:CGPoint = CGPoint()
    private var _animated:Bool = false//属性无用，只是为了容错。
    
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    convenience init (title:String?,cancelButtonTitle:String?) {
        self.init(frame: UIScreen.main.bounds)
        self.initConfig(title: title, cancelButtonTitle: cancelButtonTitle)
        isRedraw_showWithBlock = false
        self.drawLine()
        self.configFrame()
    }
    
    convenience init (title:String?,cancelButtonTitle:String?,otherButtonTitles:String...) {
        self.init(frame: UIScreen.main.bounds)
        self.initConfig(title: title, cancelButtonTitle: cancelButtonTitle)
        //添加other按钮
        if  otherButtonTitles.count>0 {
            for btnTitle in otherButtonTitles {
                self.addButtonWithTitle(title:btnTitle)
            }
        }
        isRedraw_showWithBlock = false
        self.drawLine()
        self.configFrame()
    }
    
    private func initConfig (title:String?,cancelButtonTitle:String?) {
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        _title = title
        _cancelButtonTitle = cancelButtonTitle
        
        //添加子控件
        self.addSubview(self.actionSheetContentView!)
        self.actionSheetContentView?.addSubview(self.contentView!)
        //添加titleLabel
        if _title != nil && _title!.count>0 {
            self.contentView?.addSubview(self.titleLabel!)
            self.titleLabel?.text = _title
        }

        //取消按钮
        if _cancelButtonTitle != nil && _cancelButtonTitle!.count>0 {
            _cancelButton = Self.createButton()
            _cancelButton!.backgroundColor = UIColor.white
            _cancelButton!.clipsToBounds = true
            _cancelButton!.layer.cornerRadius = 10*scale
            _cancelButton!.setTitle(_cancelButtonTitle, for: UIControl.State.normal)
            _cancelButton!.addTarget(self, action: #selector(clickButton), for: UIControl.Event.touchUpInside)
            _cancelButton!.setTitleColor(buttonTextColor, for: UIControl.State.normal)
            _cancelButton!.titleLabel!.font = UIFont.systemFont(ofSize: buttonFontSize)
            _otherButtonTitles.append(_cancelButton!)
        }
    }
    
    
    //展示控件
    override func showWithBlock(block:@escaping (_ buttonIndex:Int)->()) {
        myBlock = block
        if  _otherButtonTitles.count>0 {
            if isRedraw_showWithBlock {
                isRedraw_showWithBlock = false
                self.drawLine()
                self.configFrame()
            }
            
            let window:UIWindow = UIApplication.shared.delegate!.window!!
            window.endEditing(true)
            ZOEWindow.shareInstance.endEditing(true)

            //如果actionSheet重复调用show方法，先将数组中原来的对象移除，然后继续添加到数组的最后面，
            for view in ZOEWindow.stackArray {
                if view is ZOEActionSheet {
                    let actionSheet = view as! ZOEActionSheet
                    if actionSheet == self {
                        actionSheet.isHidden = false
                        ZOEWindow.stackArray.remove(view)
                        break
                    }
                } 
            }
            ZOEWindow.stackArray.add(self)
            ZOEWindow.shareInstance.rootViewController?.view.addSubview(self)
            ZOEWindow.shareInstance.isHidden = false
            //有新的actionSheet被展现，所以要将前一个actionSheet暂时隐藏
            if (ZOEWindow.stackArray.count-1)>0 {
                let actionSheet:UIView = ZOEWindow.stackArray[ZOEWindow.stackArray.count-2] as! UIView
                actionSheet.isHidden = true
            }
            
            //设置延迟解决UILabel渲染缓慢的问题。
            var center:CGPoint = oldCenterPoint
            center.y +=  self.actionSheetContentView!.frame.size.height
            
            self.actionSheetContentView?.center = center
            UIView.animate(withDuration: 0.2, delay: 0.00001, options: UIView.AnimationOptions()) {
                self.actionSheetContentView!.center = self.oldCenterPoint
            } completion: { finished in
            }
            
        }else {
            ZOEWindow.shareInstance.isHidden = true
        }

        
    }
    
    override func showWithBlock(block:@escaping (_ buttonIndex:Int)->(),animated:Bool) {
        self.showWithBlock(block: block)
    }
    
    private func configFrame() {
        //必须至少有一个操作按钮才能展现控件
        if !_otherButtonTitles.isEmpty {
            let allBtnH = self.buttonHeight*CGFloat(_otherButtonTitles.count)
            var actionSheeetViewH = allBtnH+(_cancelButton != nil ? 20*scale : 10*scale)

            //title区域frame设置
            if titleLabel != nil {
                actionSheeetViewH += 20*scale+titleLabel!.font.pointSize
                titleLabel?.frame = CGRect(x: 0, y: 10*scale, width: self.bounds.size.width-30*scale, height: titleLabel!.font.pointSize)
            }
            
            var contentViewH = actionSheeetViewH-(_cancelButton != nil ? (self.buttonHeight+20*scale) : 10*scale)
            //按钮操作区frame设置
            self.actionSheetContentView?.frame = CGRect(x: 15*scale, y: self.bounds.size.height-actionSheeetViewH, width: self.bounds.size.width-30*scale, height: actionSheeetViewH)
            oldCenterPoint = self.actionSheetContentView!.center
            self.contentView?.frame = CGRect(x: 0, y: 0, width: actionSheetContentView!.frame.size.width, height: contentViewH)
            
            for (i,btn) in _otherButtonTitles.enumerated() {
                if btn.tag == kBtnTagAppend {
                    btn.frame = CGRect(x: 0, y: actionSheetContentView!.frame.size.height-(10*scale+self.buttonHeight), width: actionSheetContentView!.frame.size.width, height: self.buttonHeight)
                }else {
                    btn.frame = CGRect(x: 0, y: contentViewH-CGFloat((btn.tag-kBtnTagAppend))*self.buttonHeight, width: contentView!.frame.size.width, height: self.buttonHeight)
                }
            }
            
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.configFrame()
        self.drawLine()
    }
    
    private func drawLine() {
        for view in self.contentView!.subviews {
            if view.tag == 74129 {
                view.removeFromSuperview()
            }
        }
        //设置按钮索引、绘制分割线
        let count = CGFloat(_cancelButton != nil ? (_otherButtonTitles.count-1) : _otherButtonTitles.count)
        let titleLH = CGFloat(titleLabel != nil ? 20*scale+titleLabel!.font.pointSize : 0)
        let contentViewH = self.buttonHeight*count + titleLH
        var buttonIndex:Int = (_cancelButtonTitle != nil && _cancelButtonTitle!.count>0) ? 0 :1
        for (i,btn) in _otherButtonTitles.enumerated() {
            btn.tag = kBtnTagAppend+buttonIndex
            buttonIndex += 1
            if btn.tag == kBtnTagAppend {
                self.actionSheetContentView!.addSubview(_cancelButton!)
                continue
            }
            self.contentView?.addSubview(btn)
            if titleLabel == nil && i==_otherButtonTitles.count-1 {
                break
            }
            
            let line = UIView(frame: CGRect(x: 0, y: contentViewH-CGFloat((btn.tag-kBtnTagAppend))*self.buttonHeight, width: self.bounds.size.width-30*scale, height: 0.5))
            line.backgroundColor = UIColor(red: 207/255.0, green: 210/255.0, blue: 213/255.0, alpha: 1)
            line.tag = 74129
            self.contentView?.addSubview(line)
        }
    }
    
    //操作按钮点击事件
    @objc private func clickButton(sender:UIButton) {
        clickButtonIndex = sender.tag-kBtnTagAppend
        var center:CGPoint = oldCenterPoint
        UIView.animate(withDuration: 0.2, delay: 0.00001, options: UIView.AnimationOptions()) {
            center.y +=  self.actionSheetContentView!.frame.size.height
            self.actionSheetContentView!.center = center
        } completion: { finished in
            self.removeFromSuperview()
            self.actionSheetContentView!.center = self.oldCenterPoint
            if self.myBlock != nil {
                self.myBlock!(self.clickButtonIndex)
            }
        }
    }
   
    //重写父类方法(移除当前actionSheet的同时将上一个actionSheet显示出来)
    open override func removeFromSuperview() {
        super.removeFromSuperview()

        //有可能不是按照数组倒序的顺序移除，所以需要遍历数组
        //执行ZOEWindow.stackArray.remove;_myBlock引用会消失（只出现在某个系统），所以这边做一下缓存。
        let myBlockTemp:((Int)->())? = myBlock
        for view in ZOEWindow.stackArray {
            if view is ZOEActionSheet {
                let actionSheet = view as! ZOEActionSheet
                if actionSheet == self {
                    ZOEWindow.stackArray.remove(view)
                    break
                }
            }
        }
        
        myBlock = myBlockTemp
        
        //将数组的最后一个actionSheet显示出来
        if ZOEWindow.stackArray.count>0 {
            let view = ZOEWindow.stackArray[ZOEWindow.stackArray.count-1]
            if view is ZOEActionSheet {
                let actionSheet = view as! ZOEActionSheet
                actionSheet.showWithBlock(block: actionSheet.myBlock!, animated: actionSheet._animated)
            }else {
                let alertView = view as! ZOEBaseView
                alertView.showWithBlock(block: alertView.myBlock!)
            }
        }
        
        //当数组中没有actionSheet时将父容器隐藏。
        if ZOEWindow.stackArray.count == 0 {
            ZOEWindow.shareInstance.isHidden = true
        }
    }
    
    /// 移除当前的actionSheet（不会触发block回调）
    func dismissZOEActionSheet() {
        clickButtonIndex = -1
        self.removeFromSuperview()
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var center:CGPoint = oldCenterPoint
        UIView.animate(withDuration: 0.2, delay: 0.00001, options: UIView.AnimationOptions()) {
            center.y +=  self.actionSheetContentView!.frame.size.height
            self.actionSheetContentView!.center = center
        } completion: { finished in
            self.dismissZOEActionSheet()
            self.actionSheetContentView?.center = self.oldCenterPoint
        }
    }
    
    /// 根据buttonIndex 设置button文字颜色
    /// - Parameters:
    ///   - color: 文字颜色
    ///   - buttonIndex: 按钮索引，cancelButtonIndex=0 otherButtonTitles以此类推
    func setButtonTextColor(color:UIColor,buttonIndex:Int) {
        var btn:UIButton?
        if buttonIndex == cancelButtonIndex {
            btn = self.actionSheetContentView!.viewWithTag(buttonIndex+kBtnTagAppend) as! UIButton
        }else {
            btn = contentView!.viewWithTag(buttonIndex+kBtnTagAppend) as! UIButton
        }
        
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
        let btn = ZOEActionSheet.createButton()
        btn.setTitle(title, for: UIControl.State.normal)
        btn.addTarget(self, action:#selector(clickButton), for: UIControl.Event.touchUpInside)
        btn.setTitleColor(buttonTextColor, for:UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize)
        _otherButtonTitles.append(btn)
        isRedraw_showWithBlock = true
    }
    
    /// 移除所有ZOEActionSheet（不会触发block回调）
    static func dismissAllZOEActionSheet() {
        let predicate = NSPredicate(format: " disAble=1 AND zoeStyle = 1 ")
        let data = ZOEWindow.stackArray.filtered(using: predicate)
        for obj in data {
            let actionSheet = obj as! ZOEActionSheet
            actionSheet.dismissZOEActionSheet()
        }
    }
    
    /// 获取单前所有ActionSheet
    /// - Returns: ActionSheet
    static func getAllActionSheet()->Array<Any> {
        let predicate = NSPredicate(format: " zoeStyle = 1 ")
        let resultArray = ZOEWindow.stackArray.filtered(using: predicate)
        return resultArray
    }
    
    private static func createButton()-> UIButton {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.backgroundColor = UIColor.clear
        return btn
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
