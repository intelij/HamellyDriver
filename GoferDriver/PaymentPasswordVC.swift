/**
* PaymentPasswordVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation

class PaymentPasswordVC : UIViewController,UITextFieldDelegate,ForgotPasswordDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var txtFldPassword: UITextField!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var viewObjectHolder: UIView!
    @IBOutlet var lblTitle: UILabel!
    
    var strPhoneNo = ""
    var btnNextRect : CGRect = CGRect.zero
    var isFromOther : Bool = false
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        txtFldPassword.keyboardType = .asciiCapable
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        btnNextRect = btnNext.frame
        var rectTblView = btnNext.frame
        rectTblView.size.width = self.btnNext.frame.size.width
        rectTblView.origin.x = (self.view.frame.size.width-rectTblView.size.width)/2
        btnNext.frame = rectTblView

        setupShareAppViewAnimationWithView(btnNext)
    }
    //set the animation if the page loaded
    func setupShareAppViewAnimationWithView(_ view:UIButton)
    {
        view.transform = CGAffineTransform(translationX: 0, y: -150)
        UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                view.transform = CGAffineTransform.identity
                view.alpha = 1.0;
        }, completion: { (finished: Bool) -> Void in
            self.txtFldPassword.becomeFirstResponder()
        })
    }
   // Show the keyboards
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UberSupport().keyboardWillShowOrHide(keyboarHeight: keyboardFrame.size.height, btnView: btnNext)
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            var rectTblView = self.btnNext.frame
            rectTblView.size.width = self.view.frame.size.width
            rectTblView.origin.x = 0
            self.btnNext.frame = rectTblView
        })
    }
    // Hide the keyboards

    @objc func keyboardWillHide(notification: NSNotification)
    {
        btnNext.frame = btnNextRect
    }
    
    // MARK: TextField Delegate Method
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        self.checkNextButtonStatus()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if range.location == 0 && (string == " ") {
            return false
        }
        if (string == "") {
            return true
        }
        else if (string == " ") {
            return false
        }
        else if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }

    // MARK: Checking Next Button status
    /*
        Password filled or not
        and making user interaction enable/disable
     */
    func checkNextButtonStatus()
    {
        btnNext.isUserInteractionEnabled = ((txtFldPassword.text?.count)!>0) ? true : false
    }
    
    // MARK: Navigating to First & Last Name View
    @IBAction func onNextTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "DocumentMainVC") as! DocumentMainVC
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // MARK: Navigating to First & Last Name View
    @IBAction func onButtonsTapped(_ sender:UIButton!)
    {
        if sender.tag == 11
        {
            let viewForgot = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
            viewForgot.view.backgroundColor = UIColor.clear
            viewForgot.delegate = self
            viewForgot.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            present(viewForgot, animated: false, completion: nil)
        }
        else
        {
        }
    }

    // MARK: FORGOT PASSWORD DELEGATE METHOD
    internal func onForgotAlertBtnTapped(btnTag:Int)
    {
        if btnTag == 11
        {
        }
        else
        {
            // Goto OTP Page
        }
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
}
