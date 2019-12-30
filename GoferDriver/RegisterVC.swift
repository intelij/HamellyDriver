/**
* RegisterVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import MessageUI
import TTTAttributedLabel
import AccountKit

class RegisterVC : UIViewController, UIScrollViewDelegate,UITextFieldDelegate,CountryListDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet var txtFldEmail: UITextField!
    @IBOutlet var txtFldFirstName: UITextField!
    @IBOutlet var txtFldLastName: UITextField!
    @IBOutlet var txtFldPhone: UITextField!
    @IBOutlet var txtFldPassword: UITextField!
    @IBOutlet var txtFldCity: UITextField!
    @IBOutlet var scrollMainView: UIScrollView!
    @IBOutlet var lblErrorMsg: UILabel!
    @IBOutlet var lblDialCode: UILabel!
    @IBOutlet var imgCountryFlag: UIImageView!
    @IBOutlet var viewNextHolder: UIView!

    @IBOutlet weak var loginHolderLoginButtonOutlet: UIButton!
    @IBOutlet var viewEmailSepartor: UIView!
    @IBOutlet var viewFirstNameSepartor: UIView!
    @IBOutlet var viewLastNameSepartor: UIView!
    @IBOutlet var viewPhoneSepartor: UIView!
    @IBOutlet var viewPasswordSepartor: UIView!
    @IBOutlet var viewCitySepartor: UIView!
    @IBOutlet var viewLoginHolder: UIView!
    @IBOutlet var lblLoginError: UILabel!
    @IBOutlet var terms_and_condition: TTTAttributedLabel!

    @IBOutlet weak var signUpTitleLabel: UILabel!
    
    var spinnerView = JTMaterialSpinner()
    var strLastName = ""
    var isFromProfile:Bool = false
    var isFromForgotPage:Bool = false
    var verified_mobile_number : String?
    var country_dial_code : String?
    
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
        if appDelegate.language == "ja" {
            signUpTitleLabel.text = "SIGN UP".localize
            txtFldFirstName.placeholder = "First Name".localize
            txtFldLastName.placeholder = "Last Name".localize
            txtFldEmail.placeholder = "name@example.com".localize
            txtFldPassword.placeholder = "Password".localize
            txtFldCity.placeholder = "City".localize
            loginHolderLoginButtonOutlet.setTitle("Login".localize, for: .normal)
        }
        
        if #available(iOS 10.0, *) {
            txtFldEmail.keyboardType = .asciiCapable
            txtFldFirstName.keyboardType = .asciiCapable
            txtFldLastName.keyboardType = .asciiCapable
            txtFldPhone.keyboardType = .asciiCapableNumberPad
            txtFldPassword.keyboardType = .asciiCapable
            txtFldCity.keyboardType = .asciiCapable

        } else {
            // Fallback on earlier versions
            txtFldEmail.keyboardType = .emailAddress
            txtFldFirstName.keyboardType = .asciiCapable
            txtFldLastName.keyboardType = .asciiCapable
            txtFldPhone.keyboardType = .numberPad
            txtFldPassword.keyboardType = .asciiCapable
            txtFldCity.keyboardType = .asciiCapable
        }
        self.appDelegate.registerForRemoteNotification()
        self.navigationController?.isNavigationBarHidden = true
        btnSignUp.layer.cornerRadius = btnSignUp.frame.size.width / 2

        var rect = txtFldFirstName.frame as CGRect
        rect.size.width = (self.view.frame.size.width/2) - 15
        txtFldFirstName.frame = rect
        
        var rectFirstNameSepartor = viewFirstNameSepartor.frame as CGRect
        rectFirstNameSepartor.origin.y = txtFldFirstName.frame.size.height+txtFldFirstName.frame.origin.y+5
        viewFirstNameSepartor.frame = rectFirstNameSepartor
        
        var rectLastNameSepartor = viewLastNameSepartor.frame as CGRect
        rectLastNameSepartor.origin.y = txtFldFirstName.frame.size.height+txtFldFirstName.frame.origin.y+5
        viewLastNameSepartor.frame = rectLastNameSepartor
        
        var rectEmailSepartor = viewEmailSepartor.frame as CGRect
        rectEmailSepartor.origin.y = txtFldEmail.frame.size.height+txtFldEmail.frame.origin.y+5
        viewEmailSepartor.frame = rectEmailSepartor
        
        viewLoginHolder.isHidden = true

        txtFldFirstName.becomeFirstResponder()
        
        //GETTING COUNTRY DIAL CODE & FLAG
        self.setCountryFlatAndDialCode()
        
        scrollMainView.contentSize = CGSize(width: scrollMainView.frame.size.width, height:  viewCitySepartor.frame.origin.y+20)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.setHyperLink()
        self.view.addAction(for: .tap) {
            self.view.endEditing(true)
        }
        if let phoneNumber = verified_mobile_number{
            self.txtFldPhone.text = phoneNumber
            self.txtFldPhone.isUserInteractionEnabled = false
            let flag = FlagModel(forDialCode: self.country_dial_code ?? "+01")
            self.imgCountryFlag.image = flag.flag
            self.lblDialCode.text = flag.dial_code
            self.txtFldPhone.textColor = .gray
            self.lblDialCode.textColor = .gray
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .default)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //SETTING COUNTRY DIAL CODE & FLAG
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
                    var rectTxtFld = txtFldPhone.frame
                    rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
                    rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
                    txtFldPhone.frame = rectTxtFld
        }

    }
    //MARK: initWithStory
    
    class func initWithStory(withNumber number: String?,_ code : String? ) -> RegisterVC{
        let view = Stories.main.instance.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        view.verified_mobile_number = number
        view.country_dial_code = code
        return view
    }
    // MARK: - CHANGE DIAL CODE
    /*
     
     */
    @IBAction func onChangeDialCodeTapped(_ sender:UIButton!)
    {
        return
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "CountryListVC") as! CountryListVC
        propertyView.delegate = self
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // MARK: - CHANGE DIAL CODE DELEGATE METHOD
    /*
      IF USER CHANGED THE DIAL CODE OR FLAG
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
            var rectTxtFld = txtFldPhone.frame
            rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
            rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
            txtFldPhone.frame = rectTxtFld
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkNextButtonStatus()
    }
   // Dissmiss the Keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: keyboardFrame.size.height, btnView: viewNextHolder)
        scrollMainView.contentSize = CGSize(width: scrollMainView.frame.size.width, height:  scrollMainView.frame.size.height+250)
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        self.changeSeparatorNormalColor()
        scrollMainView.contentSize = CGSize(width: scrollMainView.frame.size.width, height:  viewCitySepartor.frame.origin.y+82)
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: 0, btnView: viewNextHolder)
    }
    
    // CHANGE SEPARATE COLOR AS NORMAL WHEN KEYBOARD IS DISAPPEARING
    func changeSeparatorNormalColor()
    {
        viewEmailSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3);
        viewFirstNameSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3);
        viewLastNameSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3);
        viewPhoneSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3);
        viewPasswordSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3);
        viewCitySepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3);
    }

    // MARK: - TextField Delegate Method
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
    {
        if !viewLoginHolder.isHidden
        {
            self.viewLoginHolder.isHidden = true
        }

        self.changeSeparatorNormalColor()
        if textField.tag == 1   // EMAIL ID
        {
            scrollMainView.setContentOffset(CGPoint(x: 0,y :50), animated: true)
            viewEmailSepartor.backgroundColor = UIColor(red: 31.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        }
        else if textField.tag == 2   // FIRST NAME
        {
            scrollMainView.setContentOffset(CGPoint(x: 0,y :0), animated: true)
            viewFirstNameSepartor.backgroundColor = UIColor(red: 31.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        }
        else if textField.tag == 3   // LAST NAME
        {
            scrollMainView.setContentOffset(CGPoint(x: 0,y :0), animated: true)
            viewLastNameSepartor.backgroundColor = UIColor(red: 31.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        }
        else if textField.tag == 4   // PHONE NUMBER
        {
           
            scrollMainView.setContentOffset(CGPoint(x: 0,y :150), animated: true)
            viewPhoneSepartor.backgroundColor = UIColor(red: 31.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        }
        else if textField.tag == 5   // CREATE PASSWORD
        {
            scrollMainView.setContentOffset(CGPoint(x: 0,y :200), animated: true)
            viewPasswordSepartor.backgroundColor = UIColor(red: 31.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        }
        else if textField.tag == 6   // CITY
        {
            scrollMainView.setContentOffset(CGPoint(x: 0,y :250), animated: true)
            viewCitySepartor.backgroundColor = UIColor(red: 31.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        }

        return true
    }
    
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        self.checkNextButtonStatus()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
       
        if textField == txtFldPhone{
            
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

        else if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    // MARK: - Checking Next Button status
    /*
     First, Last name, Email, Phoneno, password, city  filled or not
     and making user interaction enable/disable
     */
    func checkNextButtonStatus()
    {
        if ((txtFldEmail.text?.count)!>0 && UberSupport().isValidEmail(testStr: txtFldEmail.text!)) && (txtFldFirstName.text?.count)!>0 && (txtFldLastName.text?.count)!>0 && (txtFldPhone.text?.count)!>5 && (txtFldPassword.text?.count)!>5 && (txtFldCity.text?.count)!>0
        {
            btnSignUp.isUserInteractionEnabled = true
            btnSignUp.backgroundColor = UIColor.ThemeMain
        }
        else
        {
            btnSignUp.backgroundColor = UIColor.ThemeInactive
            btnSignUp.isUserInteractionEnabled = false
        }
    }
        
    // MARK: - API CALLING - VALIDATING MOBILE NUMBER
    @IBAction func onSignInTapped(_ sender:UIButton!)
    {
        addProgress()
        self.view.endEditing(true)
        btnSignUp.isUserInteractionEnabled = false
        self.view.endEditing(true)
        var dicts = [String: Any]()
        dicts["email_id"] = String(format:"%@",txtFldEmail.text!)
        dicts["first_name"] = String(format:"%@",txtFldFirstName.text!)
        dicts["last_name"] = String(format:"%@",txtFldLastName.text!)
        dicts["password"] = String(format:"%@",txtFldPassword.text!)
        dicts["mobile_number"] = String(format:"%@",txtFldPhone.text!)
        dicts["city"] = String(format:"%@",txtFldCity.text!)
        self.callSignUpAPI(parms: dicts)
        /*
        var dicts = [String: Any]()
        dicts["mobile_number"] = String(format:"%@",txtFldPhone.text!)
        dicts["country_code"] = String(format:"%@",Constants().GETVALUE(keyname: USER_DIAL_CODE))
        
        UberAPICalls().PostRequest(dicts,methodName: METHOD_PHONENO_VALIDATION as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let genModel = response as! GeneralModel
            OperationQueue.main.addOperation {
                if genModel.status_code == "1"// Number Not exist
                {
                    self.gotoOTPPage(otpCode: genModel.otp_code)
                }
                else if genModel.otp_code.count > 0
                {
                    self.gotoOTPPage(otpCode: genModel.otp_code)
                 //   hide the toust msg on live build
//                    self.appDelegate.createToastMessage(genModel.otp_code, bgColor: UIColor.black, textColor: UIColor.white)
                }
                else if genModel.status_code == "2"   // Number exist
                {
                    if genModel.status_message == "Mobile Number Exist" {
                        
                        let msg = "Mobile Number Exist"
                        self.lblLoginError.text = NSLocalizedString(msg, comment: "")

                    }
                    self.viewLoginHolder.isHidden = false
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
                
                self.removeProgress()
                self.btnSignUp.isUserInteractionEnabled = true
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                self.removeProgress()
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })*/
    }
    
    // NAVIGATE TO LOGIN PAGE IF USER HAVING ACCOUNT
    @IBAction func gotoLoginPage(_ sender: UIButton!)
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        propertyView.strPhoneNo = String(format:"%@",txtFldPhone.text!)
        self.navigationController?.pushViewController(propertyView, animated: true)
    }

    // MARK: GOTO OTP PAGE
    /*
     if phoneno user is new
     */
    func gotoOTPPage(otpCode: String)
    {
        self.view.endEditing(true)
        var dicts = [String: Any]()
        dicts["email_id"] = String(format:"%@",txtFldEmail.text!)
        dicts["first_name"] = String(format:"%@",txtFldFirstName.text!)
        dicts["last_name"] = String(format:"%@",txtFldLastName.text!)
        dicts["password"] = String(format:"%@",txtFldPassword.text!)
        dicts["mobile_number"] = String(format:"%@",txtFldPhone.text!)
        dicts["city"] = String(format:"%@",txtFldCity.text!)
        self.callSignUpAPI(parms: dicts)
         /*let u_number = AKFPhoneNumber(countryCode: self.lblDialCode.text ?? "+01", phoneNumber: self.txtFldPhone.text ?? String())
        AccountKitHelper.instance.verifyWithView(self,
                                                 number: u_number,
                                                 success: { (account) in
            let preference = UserDefaults.standard
            if let number = account?.phoneNumber?.phoneNumber,
                number == self.txtFldPhone.text{
                preference.set(account?.phoneNumber?.countryCode ?? "01", forKey: USER_DIAL_CODE)
                self.callSignUpAPI(parms: dicts)
           
             }else{
                self.appDelegate.createToastMessage("Invalid data".localize, bgColor: .black, textColor: .white)
            }
         }, failure: {
         
         })
        

        let otpView = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerifyVC") as! OTPVerifyVC
        otpView.strPhoneNo = String(format:"%@",txtFldPhone.text!)
        otpView.strOTPCode = otpCode
        otpView.dictParms = dicts
        otpView.isFromSignUpPage = true
        self.navigationController?.pushViewController(otpView, animated: true)*/
        
    }
    // MARK: CALLING API FOR SIGNUP
    func callSignUpAPI(parms: [String: Any])
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
        UberAPICalls().PostRequest(parms,methodName: METHOD_SIGNUP as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let loginData = response as! LoginModel
            OperationQueue.main.addOperation {
                if loginData.status_code == "1"
                {
                    let flag = FlagModel(forDialCode: self.country_dial_code ?? "+01")
                    flag.store()
                    let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "ChooseVehicle") as! ChooseVehicle
                    propertyView.carDetailModel = loginData.car_details
                    self.navigationController?.pushViewController(propertyView, animated: true)
                }
                else
                {
                    self.appDelegate.createToastMessage(loginData.status_message)
//                    self.lblErrorMsg.isHidden = false
//                    self.lblErrorMsg.text = loginData.status_message
                    if loginData.status_message == "user_not_found" || loginData.status_message == "token_invalid" || loginData.status_message == "Invalid credentials" || loginData.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
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
    // DISPLAY PROGRESS
    func addProgress()
    {
        btnSignUp.isUserInteractionEnabled = false
        btnSignUp.titleLabel?.text = ""
        btnSignUp.setTitle("", for: .normal)
        btnSignUp.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
        spinnerView.beginRefreshing()
    }
    
    // REMOVE PROGRESS
    func removeProgress()
    {
        btnSignUp.isUserInteractionEnabled = true
        btnSignUp.titleLabel?.text = NEXT_ICON_NAME
        btnSignUp.setTitle(NEXT_ICON_NAME, for: .normal)
        spinnerView.endRefreshing()
        
        spinnerView.removeFromSuperview()
    }

    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)

    }
   
}

//MARK:  Hyper link Attribute text
extension RegisterVC : TTTAttributedLabelDelegate{
    func setHyperLink(){
        let full_text = NSLocalizedString("By continuing, I confirm that i have read and agree to the Terms & Conditions and Privacy Policy.", comment: "")
        let terms_text = NSLocalizedString("Terms & Conditions", comment: "")
        let privacy_text = NSLocalizedString("Privacy Policy", comment: "")
        
        self.terms_and_condition.setText(full_text, withLinks: [
            HyperLinkModel(url: URL(string: "\(iApp.baseURL.rawValue)terms_of_service")!, string: terms_text),
            HyperLinkModel(url: URL(string: "\(iApp.baseURL.rawValue)privacy_policy")!, string: privacy_text)
            ])

    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
    
}
