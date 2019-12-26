/**
 * PhoneNoVC.swift
 *
 * @package GoferDriver
 * @author Trioangle Product Team
 * @version - Stable 1.0
 * @link http://trioangle.com
 */

import UIKit
import MessageUI
import AccountKit

class PhoneNoVC : UIViewController,CountryListDelegate,UITextFieldDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var viewObjectHolder: UIView!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var txtFldPhoneNo: UITextField!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblErrorMsg: UILabel!
    @IBOutlet var lblDialCode: UILabel!
    @IBOutlet var imgCountryFlag: UIImageView!
    @IBOutlet var viewNextHolder: UIView!
    @IBOutlet var btnVerify: UIButton!
    
    var spinnerView = JTMaterialSpinner()
    
    var strDialCode = ""
    var isFromProfile:Bool = false
    var isFromForgotPage:Bool = false
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            txtFldPhoneNo.keyboardType = .asciiCapableNumberPad
        } else {
            // Fallback on earlier versions
            txtFldPhoneNo.keyboardType = .numberPad
        }
        self.navigationController?.isNavigationBarHidden = true
        btnNext.layer.cornerRadius = btnNext.frame.size.width / 2
        btnNext.isUserInteractionEnabled = false
        btnNext.backgroundColor = UIColor.ThemeInactive
        
        btnVerify.isUserInteractionEnabled = false
        btnVerify.backgroundColor = UIColor.ThemeInactive
        
        txtFldPhoneNo.becomeFirstResponder()
        btnNext.isHidden = isFromProfile ? true : false
        btnVerify.isHidden = isFromProfile ? false : true
        
        lblDialCode.text = strDialCode
        
        var rect = lblDialCode.frame
        rect.size.width = UberSupport().onGetStringWidth(lblDialCode.frame.size.width, strContent: lblDialCode.text! as NSString, font: lblDialCode.font)
        lblDialCode.frame = rect
        if appDelegate.language == "en"{
            var rectTxtFld = txtFldPhoneNo.frame
            rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
            rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
            txtFldPhoneNo.frame = rectTxtFld
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.setCountryFlatAndDialCode()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .default)
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
        
         if appDelegate.language == "en"{
            var rectTxtFld = txtFldPhoneNo.frame
            rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
            rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
            txtFldPhoneNo.frame = rectTxtFld
        }
        
    }
    
    // DISPLAY PROGRESS
    func addProgress()
    {
        btnNext.titleLabel?.text = ""
        btnNext.setTitle("", for: .normal)
        btnNext.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
    }
    
    // REMOVE PROGRESS
    func removeProgress()
    {
        btnNext.titleLabel?.text = NEXT_ICON_NAME
        btnNext.setTitle(NEXT_ICON_NAME, for: .normal)
        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()
    }
    
    
    // MARK: API CALLING - VALIDATE MOBILE NO
    @IBAction func onNextTapped(_ sender:UIButton!)
    {
        self.lblErrorMsg.isHidden = true
        self.view.endEditing(true)
        addProgress()
        spinnerView.beginRefreshing()
        txtFldPhoneNo.resignFirstResponder()
        btnNext.isUserInteractionEnabled = false
        btnVerify.isUserInteractionEnabled = false
        var dicts = [AnyHashable: Any]()
        dicts["mobile_number"] = String(format:"%@",txtFldPhoneNo.text!)
        dicts["country_code"] = String(format:"%@",Constants().GETVALUE(keyname: USER_DIAL_CODE))
        
        if !isFromProfile
        {
            dicts["forgotpassword"] = "1"
        }
        
        UberAPICalls().GetRequest(dicts,methodName: METHOD_PHONENO_VALIDATION as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let genModel = response as! GeneralModel
            OperationQueue.main.addOperation
                {
                    if self.isFromProfile  // coming from profile for updating phone no
                    {
                        if genModel.status_code == "1"  // Number Not exist
                        {
                            self.gotoOTPPage(otpCode: genModel.otp_code)
                        }
                        else if genModel.status_code == "2"   // Number exist
                        {
                            self.lblErrorMsg.isHidden = false
                            self.lblErrorMsg.text = genModel.status_message as String
                        }
                        else if genModel.otp_code.count > 0
                        {
                            self.gotoOTPPage(otpCode: genModel.otp_code)
//                            self.appDelegate.createToastMessage(genModel.otp_code, bgColor: UIColor.black, textColor: UIColor.white)
                        }
                        else
                        {
                            if genModel.status_message == "user_not_found" || genModel.status_message == "token_invalid" || genModel.status_message == "Invalid credentials" || genModel.status_message == "Authentication Failed"
                            {
                                self.appDelegate.logOutDidFinish()
                                return
                            }
                            else{
                            
                            }
                        }
                    }
                    else if genModel.status_code == "1"   // Number exist
                    {
                        self.gotoOTPPage(otpCode: genModel.otp_code)
                    }
                    else if genModel.otp_code.count > 0
                    {
                        self.gotoOTPPage(otpCode: genModel.otp_code)
//                        self.appDelegate.createToastMessage(genModel.otp_code, bgColor: UIColor.black, textColor: UIColor.white)
                    }
                    else
                    {
                        self.lblErrorMsg.isHidden = false
                        self.lblErrorMsg.text = NSLocalizedString("Please enter registered mobile number", comment: "")
                        
                        if genModel.status_message == "user_not_found" || genModel.status_message == "token_invalid" || genModel.status_message == "Invalid credentials" || genModel.status_message == "Authentication Failed"
                        {
                            self.appDelegate.logOutDidFinish()
                            return
                        }
                        else if genModel.status_message == "Please enter registered mobile number"{
                            self.appDelegate.createToastMessage(NSLocalizedString("Please enter registered mobile number", comment: ""), bgColor: UIColor.black, textColor: UIColor.white)

                        }
                        else{
                            self.appDelegate.createToastMessage(genModel.status_message, bgColor: UIColor.black, textColor: UIColor.white)

                        }
                    }
                    
                    self.removeProgress()
                    
                    self.btnNext.isUserInteractionEnabled = true
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                self.btnNext.isUserInteractionEnabled = true
                self.removeProgress()
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }
    
    // MARK: - NAVIGATE TO OTP PAGE
    /*
     if phoneno is new
     */
    var givenNumber : MobileNumber?
    func gotoOTPPage(otpCode: String)
    {/*
        let otpView = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerifyVC") as! OTPVerifyVC
        otpView.strPhoneNo = String(format:"%@",txtFldPhoneNo.text!)
        otpView.strOTPCode = otpCode
        otpView.isFromProfile = isFromProfile
        otpView.strDialNo = lblDialCode.text!
        self.navigationController?.pushViewController(otpView, animated: true)*/
        guard let phone = self.txtFldPhoneNo.text else{return}
        let given_no = PhoneNumber(countryCode: strDialCode ?? "01", phoneNumber: phone)
        self.givenNumber = MobileNumber(number: phone,
                                        flag: FlagModel(forDialCode: strDialCode))
        let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                  for: .register)
        self.present(mobileValidationVC, animated: true, completion: nil)
//        AccountKitHelper.instance.verifyWithView(self, number: given_no, success: { (account) in
//            if given_no.phoneNumber == account?.phoneNumber?.phoneNumber{
//                if self.isFromProfile{
//                    let info: [AnyHashable: Any] = [
//                        "phone_no" : given_no.phoneNumber,
//                        "dial_no" : account?.phoneNumber?.countryCode ?? "01",
//                        ]
//                    
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "phonenochanged"), object: self, userInfo: info)
//                }else{//from forgot password
//                    let otpView = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
//                    otpView.strMobileNo = given_no.phoneNumber
//                    self.navigationController?.pushViewController(otpView, animated: true)
//                }
//            }else{
//                self.appDelegate.createToastMessage("Invalid data".localize, bgColor: .black, textColor: .white)
//            }
//        }, failure: {
//            
//        })
    }
    
    // MARK: CHANGE DIAL CODE
    /*
     */
    @IBAction func onChangeDialCodeTapped(_ sender:UIButton!)
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "CountryListVC") as! CountryListVC
        propertyView.delegate = self
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // MARK: CHANGE DIAL CODE DELEGATE METHOD
    internal func countryCodeChanged(countryCode:String, dialCode:String, flagImg:UIImage)
    {
        lblDialCode.text = "\(dialCode)"
        imgCountryFlag.image = flagImg
        self.strDialCode = dialCode
        Constants().STOREVALUE(value: dialCode, keyname: USER_DIAL_CODE)
        Constants().STOREVALUE(value: countryCode, keyname: USER_COUNTRY_CODE)
        
        var rect = lblDialCode.frame
        rect.size.width = UberSupport().onGetStringWidth(lblDialCode.frame.size.width, strContent: dialCode as NSString, font: lblDialCode.font)
        lblDialCode.frame = rect
        
        var rectTxtFld = txtFldPhoneNo.frame
        rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
        rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
        txtFldPhoneNo.frame = rectTxtFld
        
    }
  // Dissmiss keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: keyboardFrame.size.height, btnView: viewNextHolder)
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: 0, btnView: viewNextHolder)
    }
    
    
    // MARK: - TextField Delegate Method
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        self.lblErrorMsg.isHidden = true
        self.checkNextButtonStatus()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let ACCEPTABLE_CHARACTERS = "1234567890"
        let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered: String = string.components(separatedBy: cs).joined(separator: "")
        return string == filtered
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
     phone number filled or not
     and making user interaction enable/disable & background color
     */
    func checkNextButtonStatus()
    {
        btnNext.isUserInteractionEnabled = ((txtFldPhoneNo.text?.count)! > 5) ? true : false
        btnNext.backgroundColor = ((txtFldPhoneNo.text?.count)! > 5) ? UIColor.ThemeMain : UIColor.ThemeInactive
        btnVerify.isUserInteractionEnabled = ((txtFldPhoneNo.text?.count)! > 5) ? true : false
        btnVerify.backgroundColor = ((txtFldPhoneNo.text?.count)! > 5) ? UIColor.ThemeMain : UIColor.ThemeInactive
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: User When Click on Update Phone No
    @IBAction func onUpdatePhonoNoTapped(_ sender:UIButton!)
    {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension PhoneNoVC : MobileNumberValiadationProtocol{
    func verified(number: MobileNumber) {
        if let givenNO = self.givenNumber,
            givenNO.number == number.number{
            if self.isFromProfile{
                let info: [AnyHashable: Any] = [
                    "phone_no" : number.number,
                    "dial_no" : number.flag.dial_code,
                ]
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "phonenochanged"), object: self, userInfo: info)
            }else{//from forgot password
                let otpView = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
                otpView.strMobileNo = number.number
                self.navigationController?.pushViewController(otpView, animated: true)
            }
        }else{
            self.appDelegate.createToastMessage("Invalid data".localize, bgColor: .black, textColor: .white)
        }

    }
    
    
}

