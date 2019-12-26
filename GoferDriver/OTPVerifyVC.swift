/**
* OTPVerifyVC.swift
*
* @package UberDiver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/



import UIKit
import Foundation

class OTPVerifyVC : UIViewController
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var sendCodeTitleLabel: UILabel!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var viewObjectHolder: UIView!
    @IBOutlet var lblErrorMsg: UILabel!
    @IBOutlet var viewNextHolder: UIView!
    @IBOutlet var viewSeparatorHolder: UIView!
    @IBOutlet weak var passcodeField: UXPasscodeField!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet var btnResend: UIButton!

    var spinnerView = JTMaterialSpinner()

    var nSeconds:Int = 30
    weak var timer: Timer?
    var strPhoneNo = ""
    var strOTPCode = ""
    var strDialNo = ""

    var dictParms = [AnyHashable: Any]()
    var isFromSignUpPage : Bool = false
    var isFromProfile : Bool = false
    var isFromForgotPassword : Bool = false
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if appDelegate.language == "ja" {
            sendCodeTitleLabel.text = "Enter the 4-digit code sent to you at".localize
            btnResend.setTitle("Resend Code".localize, for: .normal)
        }
        if #available(iOS 10.0, *) {
            passcodeField.keyboardType = .asciiCapableNumberPad
        } else {
            // Fallback on earlier versions
            passcodeField.keyboardType = .numberPad
        }
        self.appDelegate.registerForRemoteNotification()
        self.runResendCodeTimer()
        // shows on  only in appstore build otherwise hide it.
        // set a otp on the text field
        self.passcodeField.passcode = self.strOTPCode
        lblPhoneNumber.text = strPhoneNo
        btnNext.isUserInteractionEnabled = false
        btnNext.layer.cornerRadius = btnNext.frame.size.height/2
        self.addView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addView()
    {
        passcodeField.isSecureTextEntry = false
        passcodeField.addTarget(self, action: #selector(OTPVerifyVC.passcodeFieldDidChangeValue), for: .valueChanged)
    }
    
    @IBAction func passcodeFieldDidChangeValue() {
        print(passcodeField.passcode)
        self.onFillColor(passcodeField.passcode.count)
        self.checkNextButtonStatus()
    }
    
    func onFillColor(_ count : Int)
    {
        if count == 0
        {
            var i = 0
            for view in viewSeparatorHolder.subviews {
                if i == 0
                {
                    view.backgroundColor = UIColor.black
                }
                else
                {
                    view.backgroundColor = UIColor.lightGray
                }
                
                i = i + 1;
            }
        }
        else
        {
            var i = 0
            for view in viewSeparatorHolder.subviews {
                if i < count
                {
                    view.backgroundColor = UIColor.black
                }
                else
                {
                    view.backgroundColor = UIColor.lightGray
                }
                
                i = i + 1;
            }
        }
    }
    //Hide the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: keyboardFrame.size.height, btnView: viewNextHolder)
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: 0, btnView: viewNextHolder)
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .default)
        self.navigationController?.isNavigationBarHidden = true
        self.checkNextButtonStatus()

    }

    
    // MARK: Checking Next Button status
    /*
        otp filled or not
        and making user interaction enable/disable
     */
    func checkNextButtonStatus()
    {
        if !lblErrorMsg.isHidden
        {
            lblErrorMsg.isHidden = true
        }
        btnNext.isUserInteractionEnabled = (passcodeField.passcode.count > 3) ? true : false
        btnNext.backgroundColor = (passcodeField.passcode.count > 3) ? UIColor.ThemeMain : UIColor.ThemeInactive
        
        if (passcodeField.passcode.count > 3)
        {
            self.onNextTapped(nil)
        }
    }
    
    // MARK: Navigating to First & Last Name View
    @IBAction func onNextTapped(_ sender:UIButton!)
    {
        passcodeField.resignFirstResponder()
        
        if strOTPCode == passcodeField.passcode
        {
            if isFromProfile
            {
                let info: [AnyHashable: Any] = [
                    "phone_no" : strPhoneNo,
                    "dial_no" : strDialNo,
                    ]
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "phonenochanged"), object: self, userInfo: info)
            }
            else if isFromSignUpPage
            {
                callSignUpAPI(parms: dictParms)
            }
            else
            {
                self.gotoResetPasswordPage()
            }
        }
        else
        {
            lblErrorMsg.isHidden = false
            lblErrorMsg.text = NSLocalizedString("Your OTP Code doesn't match", comment: "")
        }
    }
    
    // MARK: CALLING API FOR SIGNUP
    func callSignUpAPI(parms: [AnyHashable: Any])
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
        UberAPICalls().GetRequest(parms,methodName: METHOD_SIGNUP as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let loginData = response as! LoginModel
            OperationQueue.main.addOperation {
                if loginData.status_code == "1"
                {
                    let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "ChooseVehicle") as! ChooseVehicle
                    propertyView.carDetailModel = loginData.car_details
                    self.navigationController?.pushViewController(propertyView, animated: true)
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
    
    func addProgress()
    {
        btnNext.isUserInteractionEnabled = false
        btnNext.titleLabel?.text = ""
        btnNext.setTitle("", for: .normal)
        btnNext.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
        spinnerView.beginRefreshing()
    }
    
    func removeProgress()
    {
        btnNext.isUserInteractionEnabled = true
        btnNext.titleLabel?.text = NEXT_ICON_NAME
        btnNext.setTitle(NEXT_ICON_NAME, for: .normal)
        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()
    }
    
    // Reduce 30 sec when user click resend otp code button
    @objc func reduceTime()
    {
        nSeconds = nSeconds-1
        lblTimer.text = (nSeconds < 10) ? String(format:"\(NSLocalizedString("Resend Code", comment: "")) 00:0%d",nSeconds) : String(format:"\(NSLocalizedString("Resend Code", comment: "")) 00:%d",nSeconds)
        
        if nSeconds == 0
        {
            lblTimer.isHidden = true
            btnResend.isHidden = false
            timer?.invalidate()
            nSeconds = 30
        }
    }
    
    // MARK: When user press Resend Code Tapped
    @IBAction func onResendCodeTapped(_ sender:UIButton!)
    {
        self.runResendCodeTimer()
        self.callMobileNoValidationAPI()  //  if user doesn't receiver any otp from server
    }
    
    func runResendCodeTimer()
    {
        lblTimer.isHidden = false
        btnResend.isHidden = true
        lblTimer.text = String(format:"\(NSLocalizedString("Resend Code", comment: "")) 00:0%d",nSeconds)

//        lblTimer.text = String(format:"Resend Code 00:%d",nSeconds)
        timer = Timer.scheduledTimer(timeInterval:1.0, target: self, selector: #selector(self.reduceTime), userInfo: nil, repeats: true)
    }
    
    // validating mobile number
    func callMobileNoValidationAPI()
    {
        passcodeField.passcode = ""
        passcodeField.resignFirstResponder()
        self.checkNextButtonStatus()
        
        var dicts = [AnyHashable: Any]()
        dicts["mobile_number"] = strPhoneNo
        if isFromForgotPassword
        {
            dicts["forgotpassword"] = "1"
        }
        UberAPICalls().GetRequest(dicts,methodName: METHOD_PHONENO_VALIDATION as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let genData = response as! GeneralModel
            OperationQueue.main.addOperation {
                if genData.status_code == "1"
                {
                    self.strOTPCode = genData.otp_code
                }
                else if genData.otp_code.count > 0
                {
                    self.strOTPCode = genData.otp_code
//                    set a otp on the text field
                    self.passcodeField.passcode = self.strOTPCode
//                     Tost message shows
//                    self.appDelegate.createToastMessage(genData.otp_code, bgColor: UIColor.black, textColor: UIColor.white)
                }
               
                else
                {
                    self.lblErrorMsg.isHidden = false
                    self.lblErrorMsg.text = genData.status_message as String
                    if genData.status_message == "user_not_found" || genData.status_message == "token_invalid" || genData.status_message == "Invalid credentials" || genData.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                    }
                    else{
                   
                    }
                }
                self.checkNextButtonStatus()
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                self.checkNextButtonStatus()
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }
    
    // MARK: NAVIGATE TO RESET PASSWORD PAGE
    /*
     OTP ENTER CORRECTLY
     */
    func gotoResetPasswordPage()
    {
        let otpView = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
        otpView.strMobileNo = strPhoneNo
        self.navigationController?.pushViewController(otpView, animated: true)
    }

    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
}
