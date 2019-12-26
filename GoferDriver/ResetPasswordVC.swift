/**
* ResetPasswordVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import MessageUI

class ResetPasswordVC : UIViewController,UITextFieldDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var txtFldPassword: UITextField!
    @IBOutlet var txtFldConfirmPassword: UITextField!
    @IBOutlet var viewObjHolder: UIView!
    @IBOutlet var lblErrorMsg: UILabel!
    @IBOutlet var viewPasswordSepartor: UIView!
    @IBOutlet var viewConfirmPasswordSepartor: UIView!
    

    @IBOutlet weak var closeButtonOutlet: UIButton!
    @IBOutlet weak var resetTitleLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    var strMobileNo = ""
    var isFromProfile:Bool = false
    var isFromForgotPage:Bool = false
    var spinnerView = JTMaterialSpinner()
    
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            txtFldPassword.keyboardType = .asciiCapable
        } else {
            // Fallback on earlier versions
            txtFldPassword.keyboardType = .asciiCapable
        }
        
        if appDelegate.language == "ja" {
            closeButtonOutlet.setTitle("CLOSE".localize, for: .normal)
            resetTitleLabel.text = "RESET PASSWORD".localize
            txtFldPassword.placeholder = "PASSWORD".localize
            txtFldConfirmPassword.placeholder = "CONFIRM PASSWORD".localize
            
        }
        self.appDelegate.registerForRemoteNotification()
        self.navigationController?.isNavigationBarHidden = true
        btnSignIn.layer.cornerRadius = btnSignIn.frame.size.width / 2
//        UIApplication.shared.statusBarStyle = .lightContent
        lblErrorMsg.isHidden = true
        txtFldConfirmPassword.setLeftPaddingPoints(10)
        txtFldConfirmPassword.setRightPaddingPoints(10)
        
        txtFldPassword.setLeftPaddingPoints(10)
        txtFldPassword.setRightPaddingPoints(10)
        txtFldPassword.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    //Dissmiss the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UberSupport().keyboardWillShowOrHide(keyboarHeight: keyboardFrame.size.height, btnView: btnSignIn)
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        UberSupport().keyboardWillShowOrHide(keyboarHeight: 0, btnView: btnSignIn)
    }
    
    // MARK: TextField Delegate Method
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        self.checkNextButtonStatus()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == txtFldPassword)
        {
            viewPasswordSepartor.backgroundColor = UIColor(red: 31.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
            viewConfirmPasswordSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
        else
        {
            viewPasswordSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            viewConfirmPasswordSepartor.backgroundColor = UIColor(red: 31.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        }
        return true
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
    
    // MARK: - Checking Next Button status
    /*
     new & confirm Password filled or not
     and making user interaction enable/disable
     */
    func checkNextButtonStatus()
    {
        if (txtFldConfirmPassword.text?.count)!>5 && (txtFldPassword.text?.count)!>5
        {
            btnSignIn.backgroundColor = UIColor.ThemeMain
            btnSignIn.isUserInteractionEnabled = true
        }
        else
        {
            btnSignIn.backgroundColor = UIColor.ThemeInactive
            btnSignIn.isUserInteractionEnabled = false
        }
    }
    
    // MARK: API CALLING - UDPATE NEW PASSWORD
    /*
     After filled new & confirm Password
     */
    @IBAction func onSignInTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        if txtFldConfirmPassword.text != txtFldPassword.text
        {
            self.presentAlertWithTitle(title: "Password Mismatch".localize, message: "", options: "Ok") { (finished) in
                
            }
//            lblErrorMsg.isHidden = false
//            lblErrorMsg.text = "Password Mismatch".localize
            return
        }
        if YSSupport.checkDeviceType()
        {
            if !(UIApplication.shared.isRegisteredForRemoteNotifications)
            {
                let settingsActionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("Message!!!", comment: ""), message: NSLocalizedString("Please enable Push Notification in settings for continue to login.", comment: ""), preferredStyle:UIAlertController.Style.alert)
                
                settingsActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
                    self.appDelegate.registerForRemoteNotification()
                }))
                present(settingsActionSheet, animated:true, completion:nil)
                return
            }
        }
        addProgress()
        spinnerView.beginRefreshing()
        
        var dicts = [AnyHashable: Any]()
        dicts["mobile_number"] = String(format:"%@",strMobileNo)
        dicts["country_code"] = String(format:"%@",Constants().GETVALUE(keyname: USER_DIAL_CODE))
        dicts["password"] = String(format:"%@",txtFldPassword.text!)
        
        UberAPICalls().GetRequest(dicts,methodName: METHOD_UPDATE_PASSWORD as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let loginData = response as! LoginModel
            OperationQueue.main.addOperation {
                if loginData.status_code == "1"
                {
                    if loginData.user_status == "Active" || loginData.user_status == "Pending"
                    {
                        self.showPage()
                    }
                    else if loginData.user_status == "Car_details"
                    {
                        self.gotoVehicleDetailPage(arrCarDetails:loginData.car_details)
                    }
                    else if loginData.user_status == "Document_details"
                    {
                        self.gotoDocumentPage()
                    }
                }
                else
                {
                    self.lblErrorMsg.isHidden = false
                    self.lblErrorMsg.text = loginData.status_message
                    if loginData.status_message == "user_not_found" || loginData.status_message == "token_invalid" || loginData.status_message == "Invalid credentials" || loginData.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                    }
                    else{
                    
                    }
                }
                
                self.removeProgress()
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                self.removeProgress()
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }
    
    func showPage()
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set("driver", forKey:"getmainpage")
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        appDelegate.onSetRootViewController(viewCtrl: self)
        if Constants().GETVALUE(keyname: USER_PAYPAL_EMAIL_ID).count == 0
        {
            let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "AddPaymentVC") as! AddPaymentVC
            propertyView.isFromHomePage = true
            self.navigationController?.pushViewController(propertyView, animated: false)
        }
        else
        {
            let userDefaults = UserDefaults.standard
            userDefaults.set("driver", forKey:"getmainpage")
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.onSetRootViewController(viewCtrl: self)
        }
    }
    
    // NAVIGATE TO DOCUMENT PAGE
    /*
     IF USER NOT UPLODING DOCUMENT
     */
    func gotoDocumentPage()
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "DocumentMainVC") as! DocumentMainVC
        propertyView.isHideBackBtn = true
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // NAVIGATE TO ADD VEHICLE DETAILS PAGE
    /*
     IF USER NOT UPDATING HIS VEHICLE DETAILS
     */
    func gotoVehicleDetailPage(arrCarDetails:NSArray)
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "ChooseVehicle") as! ChooseVehicle
        propertyView.carDetailModel = arrCarDetails
        propertyView.isHideBackBtn = true
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    func addProgress()
    {
        lblErrorMsg.isHidden = true
        self.btnSignIn.isUserInteractionEnabled = false
        btnSignIn.titleLabel?.text = ""
        btnSignIn.setTitle("", for: .normal)
        btnSignIn.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
    }
    
    func removeProgress()
    {
        self.btnSignIn.isUserInteractionEnabled = true
        btnSignIn.titleLabel?.text = NEXT_ICON_NAME
        btnSignIn.setTitle(NEXT_ICON_NAME, for: .normal)
        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
}

