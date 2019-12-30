/**
* SignInVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import MessageUI

class SignInVC : UIViewController,CountryListDelegate,UITextFieldDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var txtFldPhoneNo: UITextField!
    @IBOutlet var txtFldPassword: UITextField!
    @IBOutlet var btnForgotPassword: UIButton!
    @IBOutlet var viewObjHolder: UIView!
    @IBOutlet var imgCountryFlag: UIImageView!
    @IBOutlet var lblDialCode: UILabel!
    @IBOutlet var viewPhoneSepartor: UIView!
    @IBOutlet var viewPassSepartor: UIView!

    @IBOutlet weak var closeButtonOutlet: UIButton!
    @IBOutlet weak var loginTitleLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    var strPhoneNo = ""
    var strLastName = ""
    var isFromProfile:Bool = false
    var isFromForgotPage:Bool = false
    var spinnerView = JTMaterialSpinner()
    
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        if appDelegate.language == "ja" {
            closeButtonOutlet.setTitle("CLOSE".localize, for: .normal)
            loginTitleLabel.text = "LOG IN".localize
            btnForgotPassword.setTitle("Forgot Password?".localize, for: .normal)
            txtFldPassword.placeholder = "PASSWORD".localize
        }
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            txtFldPhoneNo.keyboardType = .asciiCapableNumberPad
            txtFldPassword.keyboardType = .asciiCapable
            
        } else {
            // Fallback on earlier versions
            txtFldPhoneNo.keyboardType = .numberPad
            txtFldPassword.keyboardType = .default
        }
        self.appDelegate.registerForRemoteNotification()
        self.navigationController?.isNavigationBarHidden = true
        btnSignIn.layer.cornerRadius = 4
        if strPhoneNo.count > 0
        {
            txtFldPhoneNo.text = strPhoneNo
        }
        
        txtFldPhoneNo.setLeftPaddingPoints(10)
        txtFldPhoneNo.setRightPaddingPoints(10)
        txtFldPhoneNo.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.setCountryFlatAndDialCode()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .lightContent)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // Getting Country Dial Code and Flag from plist file
    func setCountryFlatAndDialCode()
    {
        let strDialCode = Constants().GETVALUE(keyname: USER_DIAL_CODE)
        let strCountryCode = Constants().GETVALUE(keyname: USER_COUNTRY_CODE)
        if strDialCode != "" && strCountryCode != ""
        {
            let flagImg = UIImage.imageFlagBundleNamed(named: (strCountryCode).lowercased() + ".png") as UIImage
            imgCountryFlag.image = flagImg
            
            var arrCountryList : NSMutableArray = NSMutableArray()
            let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
            arrCountryList = NSMutableArray(contentsOfFile: path!)!
            
            for i in 0 ..< arrCountryList.count
            {
                if strCountryCode == ((arrCountryList[i] as AnyObject).value(forKey: "code") as? String ?? String())
                {
                    lblDialCode.text = ((arrCountryList[i] as AnyObject).value(forKey: "dial_code") as? String ?? String())
                }
            }
        }
        
        var rect = lblDialCode.frame
        rect.size.width = UberSupport().onGetStringWidth(lblDialCode.frame.size.width, strContent: lblDialCode.text! as NSString, font: lblDialCode.font)
        lblDialCode.frame = rect
        if appDelegate.language == "en" {
            var rectTxtFld = txtFldPhoneNo.frame
            rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
            rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
            txtFldPhoneNo.frame = rectTxtFld
        }
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkNextButtonStatus()
    }
  
    //Dissmiss the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        let moveUpHeight : CGFloat = -25
        self.btnSignIn.transform = CGAffineTransform(translationX: 0, y: moveUpHeight)
        self.btnForgotPassword.transform = CGAffineTransform(translationX: 0, y: moveUpHeight)
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        self.btnSignIn.transform = .identity
        self.btnForgotPassword.transform = .identity
        changeSeparatorNormalColor()
    }
    
    func changeSeparatorNormalColor()
    {
        viewPhoneSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3);
        viewPassSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3);
    }

    
    // MARK: - TextField Delegate Method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == txtFldPhoneNo)
        {
            viewPhoneSepartor.backgroundColor = UIColor(red: 31.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
            viewPassSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
        else
        {
            viewPhoneSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            viewPassSepartor.backgroundColor = UIColor(red: 31.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        }
        return true
    }
    
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        self.checkNextButtonStatus()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        if textField == txtFldPhoneNo{
            
            let ACCEPTABLE_CHARACTERS = "1234567890"
            
            let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered: String = string.components(separatedBy: cs).joined(separator: "")
            return string == filtered
        }
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
     USER NAME & PASSWORD IS FILLED
     */
    func checkNextButtonStatus()
    {
        if (txtFldPhoneNo.text?.count)!>5 && (txtFldPassword.text?.count)!>5
        {
            btnSignIn.isUserInteractionEnabled = true
        }
        else
        {
            btnSignIn.isUserInteractionEnabled = false
        }
    }
    
    // MARK: API CALLING - Forgot Password
    /*
        Mobile number & Password filled or not
     */
    @IBAction func onForgotPasswordTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        
        let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                  for: .forgotPassword)
        self.present(mobileValidationVC, animated: true, completion: nil)
//        AccountKitHelper.instance.verifyWithView(self, number: nil, success: { (account) in
//            let number = account?.phoneNumber!
//            dump(number)
//            self.verifyToAPI(number: number!.phoneNumber, dialCode: number!.countryCode)
//
//        }) {
//
//        }
 
    }
    func verifyToAPI(number : String,dialCode : String){
        AccountInteractor.instance.checkRegistrationStatus(forNumber: number,
                                                           countryCode: dialCode,
                                                           { (isRegistered, message) in
                                                            if isRegistered{
                                                                let otpView = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
                                                                otpView.strMobileNo = number
                                                                self.navigationController?.pushViewController(otpView, animated: true)
                                                            }else{
                                                                self.appDelegate.createToastMessage(message)
                                                            }
        })
    }

    // MARK: API CALLING - LOGIN
    /*
     After filled Mobile number & Password
     */
    @IBAction func onSignInTapped(_ sender:UIButton!)
    {
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
        self.view.endEditing(true)
        var dicts = [String: Any]()
        dicts["country_code"] = self.lblDialCode.text?.replacingOccurrences(of: "+", with: "") ?? "1"
        dicts["mobile_number"] = String(format:"%@",txtFldPhoneNo.text!)
        dicts["password"] = String(format:"%@",txtFldPassword.text!)
        
        UberAPICalls().PostRequest(dicts,methodName: METHOD_LOGIN as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
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
                        self.gotoVehicleDetailPage(arrCarDetail: loginData.car_details)
                    }
                    else if loginData.user_status == "Document_details"
                    {
                        self.gotoDocumentPage()
                    }
                }
                else
                {
                    if loginData.status_message == "user_not_found" || loginData.status_message == "token_invalid" || loginData.status_message == "Invalid credentials" || loginData.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                    }
                    else if loginData.status_message == "Those credentials don't look right. Please try again" {
                        
                        self.appDelegate.createToastMessage(NSLocalizedString("Those credentials don't look right. Please try again", comment: ""), bgColor: UIColor.black, textColor: UIColor.white)

                    }
                    else{
                        
                        self.appDelegate.createToastMessage(loginData.status_message, bgColor: UIColor.black, textColor: UIColor.white)
                   
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
    func gotoVehicleDetailPage(arrCarDetail: NSArray)
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "ChooseVehicle") as! ChooseVehicle
        propertyView.carDetailModel = arrCarDetail
        propertyView.isHideBackBtn = true
        self.navigationController?.pushViewController(propertyView, animated: true)
    }

    // DISPLAY PROGRESS WHEN API CALLING
    func addProgress()
    {
        self.btnSignIn.isUserInteractionEnabled = false
        btnSignIn.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: btnSignIn.frame.size.width - 50, y: 5, width: 30, height: 30)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
        spinnerView.beginRefreshing()
    }
    
    // REMOVE PROGRESS WHEN API CALL DONE
    func removeProgress()
    {
        self.btnSignIn.isUserInteractionEnabled = true
        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()
    }
    
    
    // MARK: - CHANGE DIAL CODE
    /*
     */
    @IBAction func onChangeDialCodeTapped(_ sender:UIButton!)
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "CountryListVC") as! CountryListVC
        propertyView.delegate = self
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // MARK: - CHANGE DIAL CODE DELEGATE METHOD
    /*
     IF USER CHANGED THE COUNTRY CODE
     */
    internal func countryCodeChanged(countryCode:String, dialCode:String, flagImg:UIImage)
    {
        lblDialCode.text = "\(dialCode)"
        imgCountryFlag.image = flagImg
        Constants().STOREVALUE(value: dialCode, keyname: USER_DIAL_CODE)
        Constants().STOREVALUE(value: countryCode, keyname: USER_COUNTRY_CODE)
        
        var rect = lblDialCode.frame
        rect.size.width = UberSupport().onGetStringWidth(lblDialCode.frame.size.width, strContent: dialCode as NSString, font: lblDialCode.font)
        lblDialCode.frame = rect
        
        if appDelegate.language == "en" {
            var rectTxtFld = txtFldPhoneNo.frame
            rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
            rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x  - 20
            txtFldPhoneNo.frame = rectTxtFld
        }
    }

    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)

    }

   
}

// EXTENSION UITEXTFIELD PADDING SUPPORT
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension SignInVC : MobileNumberValiadationProtocol{
    func verified(number: MobileNumber) {
      
        let otpView = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
        otpView.strMobileNo = number.number
        self.navigationController?.pushViewController(otpView, animated: true)
    }
    
    
}

