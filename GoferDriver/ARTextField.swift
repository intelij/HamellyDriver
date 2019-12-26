//
//  myTextField.swift
//  RebuStar
//
//  Created by Abservetech on 17/11/18.
//  Copyright © 2018 Abservetech. All rights reserved.
//

import Foundation
import UIKit

protocol ARTFDelegate {
    func onValueSet(_ textField : UITextField,value : String)
}

class ARTextField: UIView {
    //MARK: Outlets
    @IBOutlet weak var title : UILabel!
    @IBOutlet weak var icon: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var bar : UILabel!
    
    @IBOutlet weak var textFieldHeight : NSLayoutConstraint!
    @IBOutlet weak var barHeight : NSLayoutConstraint!
    
    //MARK:-Private variable
    fileprivate var showingTitle = true
    fileprivate var defaultTitleFont : UIFont!
    fileprivate var setIcon : Bool = false
    fileprivate var textMainColor : UIColor = .ThemeMain
    fileprivate var textHightLightColor : UIColor = .ThemeLight
    fileprivate var title_text = String()
    fileprivate var nextFocusTextField : UITextField?
    fileprivate var secureText = false
    fileprivate var showingError = false
    let show = #imageLiteral(resourceName: "StarFull1").withRenderingMode(.alwaysTemplate)
    let hide = #imageLiteral(resourceName: "StarFull").withRenderingMode(.alwaysTemplate)
    var translationHeight : CGFloat?
 
    var arTFDelegate : ARTFDelegate?
    //MARK:- ViewLife Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
      //  self.initView()
    }
    override func prepareForInterfaceBuilder() {
       // self.initView()
    }
    //MARK:- initalizers
    func initViews(){
        self.textField.textColor = self.textMainColor
        self.title.textColor = self.textMainColor.withAlphaComponent(0.5)
        self.bar.backgroundColor = self.textMainColor
        self.icon.tintColor = self.textHightLightColor
        self.defaultTitleFont = self.title.font
        self.textField.delegate = self
        self.toggle()
    
    }
    
    class func initilazieTextField(on view :inout ARTextField,_ title : String = String()){
        let mtf = ARTextField.getView
        mtf.frame = view.bounds
        mtf.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        view.addSubview(mtf)
        mtf.initViews()
        mtf.setTitle(title)
        view = mtf
    }
    class var getView: ARTextField{
        return UINib(nibName: "ARTextField", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ARTextField
    }
    //MARK: Actions
    @IBAction func showHidePassAct(_ sender: UIButton) {
        if self.secureText{
            self.textField.isSecureTextEntry = !self.textField.isSecureTextEntry
            self.icon.setImage(self.textField.isSecureTextEntry ? hide : show, for: .normal)
        }
    }
    func setAnimation(height : CGFloat?){
        self.translationHeight = height
    }
    //MARK: UDF
    func addToolBar(){
        let toolBar = UIToolbar(frame: CGRect(origin: CGPoint.zero,
                                              size: CGSize(width: self.frame.width,
                                                           height: 30)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done,
                                    target: self,
                                    action: #selector(self.doneAction))
        toolBar.setItems([space,done], animated: true)
        toolBar.sizeToFit()
        self.textField.inputAccessoryView = toolBar
    }
    @objc func doneAction(){
        self.textField.becomeFirstResponder()
        self.textField.resignFirstResponder()
    }
    fileprivate func toggle(){
        self.title.text = self.title_text
        UIView.animate(withDuration: 0.3) {
            if self.showingTitle{
                self.title.transform = .identity
                self.title.font = self.defaultTitleFont
                self.title.textColor = self.textMainColor.withAlphaComponent(0.5)
                self.bar.backgroundColor = self.textMainColor.withAlphaComponent(0.5)
            }else{
                if self.showingError{
                    self.title.textColor = self.textMainColor.withAlphaComponent(0.5)
                    self.bar.backgroundColor = self.textMainColor.withAlphaComponent(0.5)
                    self.icon.tintColor = self.textMainColor
                }
                let height = self.translationHeight ?? self.title.frame.minY
                self.title.transform =  CGAffineTransform(translationX: 0,
                                                          y: -height)
                self.title.font = UIFont(name: iApp.GoferFont.bold.rawValue, size: 20)
                self.title.textColor = self.textMainColor.withAlphaComponent(0.5)
                self.bar.backgroundColor = self.textMainColor.withAlphaComponent(0.5)
            }
        }
        self.showingTitle = !self.showingTitle
    }
    func setColor(_ color : UIColor){
        self.textMainColor = color
        //self.title.textColor = color.withAlphaComponent(0.75)
        self.textField.textColor = color
        self.bar.backgroundColor = color.withAlphaComponent(0.75)
        self.title.textColor = color.withAlphaComponent(0.75)
        self.icon.tintColor = color.withAlphaComponent(0.75)
    }
    
    func setTitle(_ title : String,_ fontSize : CGFloat = -1){
        self.title_text = title
        self.title.text = title
        guard fontSize != -1 else{return}
        self.title.font = UIFont(name: iApp.GoferFont.bold.rawValue, size: fontSize)
    }
    func setValue(_ value : String,_ fontSize : CGFloat = -1){
        if !self.showingTitle && !value.isEmpty{
            self.toggle()
        }
        self.textField.text = value
        guard fontSize != -1 else{return}
        self.textField.font = UIFont(name: iApp.GoferFont.bold.rawValue, size: fontSize)
    }
    func setFontSize(title : CGFloat,value : CGFloat){
        self.title.font = UIFont(name: iApp.GoferFont.bold.rawValue, size: title)
        self.textField.font = UIFont(name: iApp.GoferFont.bold.rawValue, size: value)
    }

    func setHintIcon(_ img :UIImage){
        self.setIcon = true
        self.icon.setImage(img.withRenderingMode(.alwaysTemplate), for: .normal)
        self.icon.tintColor = .ThemeMain
        self.icon.isHidden = false
    }
  
    func nextFocus(_ textF : UITextField){
        self.nextFocusTextField = textF
        self.textField.returnKeyType = .next
    
    }
  
    func isSecureText(_ val : Bool){
        self.secureText = val
        self.textField.isSecureTextEntry = val
        self.icon.setImage(hide, for: .normal)
        self.tintColor = .ThemeMain
    }

    func showError(_ message : String){
        //self.textField.resignFirstResponder()
        
        self.textField.text = ""
        self.showingTitle = false
        self.toggle()
        self.showingError = true
        self.showingTitle = false
        self.title.text = message
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeLinear], animations: {
           
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                self.title.textColor = .red
                self.bar.backgroundColor = .red
                self.icon.tintColor = .red
               self.title.transform =  CGAffineTransform(translationX: 0, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: {
                self.title.transform = CGAffineTransform(translationX: -5, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6, animations: {
                self.title.transform = CGAffineTransform(translationX: 5, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.8, animations: {
                self.title.transform = CGAffineTransform(translationX: -5, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.9, animations: {
                self.title.transform = CGAffineTransform(translationX: 5, y: 0)
            })
        }) { (_) in
            self.title.transform =  .identity
            
            
        }
      
    }
    
}
extension ARTextField : UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
       
        self.textField.textColor = self.textMainColor
        self.title.textColor = self.textHightLightColor
        self.bar.backgroundColor = self.textHightLightColor
        self.icon.tintColor = self.textHightLightColor
        if textField.text?.count == 0{
            if !self.showingTitle{
                self.toggle()
            }
        }
        if showingError{
            textField.text = String()
            self.showingError = false
        }
        self.icon.isHidden = !(self.setIcon || self.secureText) 
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0{
            if self.showingTitle{
                self.toggle()
            }
            self.icon.isHidden = !self.setIcon
        }
        self.arTFDelegate?.onValueSet(textField, value: textField.text ?? "")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        self.endEditing(true)
        if let nextTF = self.nextFocusTextField{
            nextTF.becomeFirstResponder()
        }else{
            self.endEditing(true)
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        self.resignFirstResponder()
        return true
    }
    

}
extension ARTextField {
    
}
