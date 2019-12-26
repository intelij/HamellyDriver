/**
* PaymentEmailVC.swift
*
* @package UberClone
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation

protocol PaymentEmailVCDelegate
{
    func onPayPalEmailAdded(emailID: String)
}

class PaymentEmailVC : UIViewController,UITextFieldDelegate
{
    @IBOutlet var txtFldEmailID: UITextField!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var viewObjectHolder: UIView!
    @IBOutlet var lblTitle: UILabel!
    
    var delegate: PaymentEmailVCDelegate?
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate

    var strEmailID = ""
    var btnNextRect : CGRect = CGRect.zero
    var isFromOther : Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        txtFldEmailID.keyboardType = .emailAddress
        lblTitle.text = "\(NSLocalizedString("To add a new payout. Create a email for your", comment: "")) \(iApp.appName) \(NSLocalizedString("account.", comment: ""))"
        btnNext.isUserInteractionEnabled = false
        btnNext.backgroundColor = UIColor.ThemeInactive
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        btnNextRect = btnNext.frame
        if strEmailID.count > 0
        {
            txtFldEmailID.text? = strEmailID
        }
        var rectTblView = btnNext.frame
        rectTblView.size.width = self.btnNext.frame.size.width
        rectTblView.origin.x = (self.view.frame.size.width-rectTblView.size.width)/2
        btnNext.frame = rectTblView
        setupShareAppViewAnimationWithView(btnNext)
    }
    
    func setupShareAppViewAnimationWithView(_ view:UIButton)
    {
        view.transform = CGAffineTransform(translationX: 0, y: -150)
        UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                view.transform = CGAffineTransform.identity
                view.alpha = 1.0;
        }, completion: { (finished: Bool) -> Void in
            self.txtFldEmailID.becomeFirstResponder()
        })
    }
    
    //Dissmiss the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            var rectTblView = self.btnNext.frame
            rectTblView.size.width = self.view.frame.size.width
            rectTblView.origin.x = 0
            let rect = UberSupport().getScreenSize()
            rectTblView.origin.y = (rect.size.height) - self.btnNext.frame.size.height - keyboardFrame.size.height
            self.btnNext.frame = rectTblView
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        btnNext.frame = btnNextRect
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .lightContent)
        self.navigationController?.isNavigationBarHidden = true
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
        btnNext.isUserInteractionEnabled = ((txtFldEmailID.text?.count)!>0 && UberSupport().isValidEmail(testStr: txtFldEmailID.text!) && strEmailID != txtFldEmailID.text) ? true : false
        
        btnNext.backgroundColor = ((txtFldEmailID.text?.count)!>0 && UberSupport().isValidEmail(testStr: txtFldEmailID.text!) && strEmailID != txtFldEmailID.text) ? UIColor.ThemeMain : UIColor.ThemeInactive
    }
    
    // MARK: - API CALL -> ADD/UPDATE PAYPAL EMAIL ID FOR PAYOUT
    @IBAction func onSaveTapped(_ sender:UIButton!)
    {
        var dicts = [AnyHashable: Any]()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["email_id"] = txtFldEmailID.text!

        self.view.endEditing(true)
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        
        UberAPICalls().GetRequest(dicts,methodName: METHOD_UPDATE_PAYPAL_EMAIL as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let gModel = response as! GeneralModel
            OperationQueue.main.addOperation {
                UberSupport().removeProgress(viewCtrl: self)
                if gModel.status_code == "1"
                {
                    self.delegate?.onPayPalEmailAdded(emailID: self.txtFldEmailID.text!)
                    self.navigationController?.popViewController(animated: true)
                }
                else
                {
                    if gModel.status_message == "user_not_found" || gModel.status_message == "token_invalid" || gModel.status_message == "Invalid credentials" || gModel.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                    }
                    else{
                    
                    }
                }
                UberSupport().removeProgressInWindow(viewCtrl: self)
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation
                {
                    self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
                    UberSupport().removeProgressInWindow(viewCtrl: self)
            }
        })
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
}
