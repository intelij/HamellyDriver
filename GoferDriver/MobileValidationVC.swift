//
//  MobileValidationVC.swift
//  GoferDriver
//
//  Created by trioangle on 13/09/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import UIKit
import Alamofire

protocol MobileNumberValiadationProtocol {
    func verified(number : MobileNumber)
}
/**
 Mobile number validation using OTP
 
 - Warning: Caller must implement MobileNumberValiadationProtocol
 - Author: Abishek Robin
 */
class MobileValidationVC: UIViewController,APIViewProtocol,CheckStatusProtocol {
    //MARK:- API
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum) {
        self.removeProgress()
        switch response {
        case .number(isValid: let valid,
                     OTP: let otp,
                     message: let message):
            if valid{
                if self.currentScreenState  != .OTP{//if already not in otp screen
                    self.aniamateView(for: .OTP)
                }
                self.otpFromAPI = otp
            }else{
                self.otpFromAPI = nil
                self.showError(message)
            }
        default:
            break
        }
    }
    
    func onFailure(error: String) {
        self.showError(error)
        self.removeProgress()
    }
    
    /**
     MobileNumberValidation Screen States
        - States:
            - mobileNumber
            - OTP
     */
    enum ScreenState{
        case mobileNumber
        case OTP
    }
    enum NumberValidationPurpose{
        case forgotPassword
        case register
        case changeNumber
    }
    //MARK:- outlets
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var contentHolderView : UIView!
    @IBOutlet weak var titleIV : UIImageView!
    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var descLbl : UILabel!
    @IBOutlet weak var inputFieldHolderView : UIView!
    @IBOutlet weak var nextBtn : UIButton!
    @IBOutlet weak var bottomDescLbl : UILabel!
    @IBOutlet weak var bottomBtn :UIButton!
    
    //MARK:- variables
    var purpose : NumberValidationPurpose!
    
    var otpFromAPI : String?{//Otp from API
        didSet{
            guard self.otpFromAPI != nil else{return}
            self.startOTPTimer()

        }
    }
    var flag : FlagModel?{//Country flag
        didSet{
            self.mobileNumberView.flag = self.flag
        }
    }
    var currentScreenState : ScreenState{
        return otpFromAPI == nil ? .mobileNumber : .OTP
    }
    lazy var mobileNumberView : MobileNumberView = {
        let mnView = MobileNumberView.getView(with: self.inputFieldHolderView.bounds)
        mnView.countryHolderView.addAction(for: .tap, Action: {
            self.presentToCountryVC()
        })
        return mnView
    }()
    lazy var otpView : OTPView = {
        let _otpView = OTPView.getView(with: self,
                                       using: self.inputFieldHolderView.bounds)
        if iApp.instance.isRTL{
            _otpView.rotate()
        }
        return _otpView
    }()
    lazy var toolBar : UIToolbar = {
        let tool = UIToolbar(frame: CGRect(origin: CGPoint.zero,
                                           size: CGSize(width: self.view.frame.width,
                                                        height: 30)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done,
                                   target: self,
                                   action: #selector(self.doneAction))
        let clear = UIBarButtonItem(barButtonSystemItem: .refresh,
                                    target: self,
                                    action: #selector(self.clearAction))
        tool.setItems([clear,space,done], animated: true)
        tool.sizeToFit()
        return tool
    }()
    var spinnerView = JTMaterialSpinner()
    var remainingOTPTime = 0
    var validationDelegate : MobileNumberValiadationProtocol?
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        // Do any additional setup after loading the view.
    }
    //MARK:- initializers
    
    
    func initView(){
        self.setContentData(for: self.currentScreenState)
        if let code = UserDefaults.standard.string(forKey: USER_DIAL_CODE){
            self.flag = FlagModel(forDialCode: code)
            
        }else{
            self.flag = FlagModel(forCountryCode: "US")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.initLayers()
        }
        self.bottomBtn.alpha =  0
        self.bottomDescLbl.alpha =  0
        
        
        if iApp.instance.isRTL{
            self.nextBtn.setTitle("e", for: .normal)
            self.backBtn.setTitle("p", for: .normal)
        }else{
            self.nextBtn.setTitle("I", for: .normal)
            self.backBtn.setTitle("f", for: .normal)
        }
        if UIScreen.main.bounds.height <= 570{ //5s or less
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardShows), name: UIResponder.keyboardWillShowNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardHiddens), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    func initLayers(){
        self.nextBtn.isRoundCorner = true
        self.nextBtn.elevate(4)
        //to change next button color
        self.checkStatus()
    }
    @objc func KeyboardShows(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.15) {
            self.contentHolderView.transform = CGAffineTransform(translationX: 0,
                                                                 y: -keyboardFrame.height * 0.3)
        }
        
    }
    //hide the keyboard
    @objc func KeyboardHiddens(notification: NSNotification)
    {
        
        
        UIView.animate(withDuration: 0.15) {
            self.contentHolderView.transform = .identity
        }
    }
    /**
     Static function to initialize MobileValidationVC
     - Author: Abishek Robin
     - Parameters:
        - delegate: MobileNumberValiadationProtocol to be parsed
        - purpose: forgotPassword,register,changeNumber
     - Returns: MobileValidationVC object
     - Warning: Purpose must be parsed properly
     */
    class func initWithStory(usign delegate : MobileNumberValiadationProtocol,
                             for purpose : NumberValidationPurpose)-> MobileValidationVC{
        let story = Stories.account.instance
        let view = story
            .instantiateViewController(withIdentifier: "MobileValidationVCID")
            as! MobileValidationVC
        view.apiInteractor = APIInteractor(view)
        view.purpose = purpose
        view.validationDelegate = delegate
        return view
    }
    
    //MARK:- Actions
    @IBAction func backAction(_ sender : UIButton){
        if self.currentScreenState == .mobileNumber{
            if self.isPresented(){
                self.dismiss(animated: true, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            self.otpFromAPI = nil
            self.otpView.clear()
            self.aniamateView(for: .mobileNumber)
        }
    }
    
    @IBAction func nextAction(_ sender : UIButton){
        if self.currentScreenState == .mobileNumber{
            self.wsToVerifyNumber()
        }else{
            if let typedOTP = self.otpView.otp,
                let originalOTP = self.otpFromAPI,
                typedOTP == originalOTP{//Validation completed
                self.onSuccess()
            }else{//Invalid otp
                self.otpView.invalidOTP()
            }
        }
    }
    @IBAction func bottomBtnAction(_ sender : UIButton){
        if self.currentScreenState == .OTP{//Resend OTP
            self.otpView.clear()
            self.view.endEditing(true)
            self.wsToVerifyNumber()
        }else{
            switch self.purpose{//Currenty not using these cases
            case NumberValidationPurpose.register?:
                self.backAction(self.backBtn)
            case NumberValidationPurpose.changeNumber?:
                self.backAction(self.backBtn)
            case NumberValidationPurpose.forgotPassword?:
                break
                
            default:
                break
            }
        }
    }
    @objc func doneAction(){
        self.view.endEditing(true)
        self.checkStatus()
    }
    @objc func clearAction(){
        if self.currentScreenState == .mobileNumber{
            self.mobileNumberView.clear()
            
        }else{
            
            self.otpView.clear()
        }
    }
    //MARK:- Animations
    /**
     Set Data for screen content based on states
     - Author: Abishek Robin
     - Parameters:
        - state: ScreenState(mobile/otp)
     */
    func setContentData(for state : ScreenState){
        self.inputFieldHolderView.subviews.forEach({$0.removeFromSuperview()})
        let titleImage : UIImage?
        if state == .mobileNumber{
            titleImage = UIImage(named: "mobileverify")?.withRenderingMode(.alwaysTemplate)
            self.titleLbl.text = "Mobile Verification".localize
            self.descLbl.text = "Please enter your mobile number".localize
            self.bottomDescLbl.text = ""
            self.bottomBtn.setTitle("LOGIN".localize, for: .normal)
            self.inputFieldHolderView.addSubview(self.mobileNumberView)
            self.inputFieldHolderView.bringSubviewToFront(self.mobileNumberView)
            self.mobileNumberView.numberTF.inputAccessoryView = self.toolBar
        }else{//.otp
            titleImage = UIImage(named: "mobileotp")?.withRenderingMode(.alwaysTemplate)
            self.titleLbl.text = "Enter OTP".localize
            self.descLbl.text = "We have sent you access code via SMS for mobile number verification".localize
            self.bottomDescLbl.text = "Din't Receive the OTP?".localize
            self.bottomBtn.setTitle("Resend OTP".localize, for: .normal)
            self.inputFieldHolderView.insertSubview(self.otpView, at: 0)//(self.otpView)
            self.inputFieldHolderView.bringSubviewToFront(self.otpView)
            self.otpView.setToolBar(self.toolBar)
            
        }
        self.titleIV.image = titleImage
        self.titleIV.tintColor = .ThemeLight
    }
    func aniamateView(for state : ScreenState){
        let transformation : CGAffineTransform
        let change : CGFloat = iApp.instance.isRTL ? -1 : 1
        if state == .OTP  {
            transformation = CGAffineTransform(translationX: -self.view.frame.width * change,
                                               y: 0)
        }else{
            transformation = CGAffineTransform(translationX:    self.view.frame.width * change,
                                               y: 0)
        }
        UIView.animateKeyframes(withDuration: 0.8,
                                delay: 0.0,
                                options: [.calculationModeCubic,.calculationModeCubicPaced],
                                animations: {
                                    self.animate(with: transformation)
        }) { (completed) in
            if completed{
                //Change data for new state when view is outside the frame
                self.setContentData(for: state)
                //Continue animating
                UIView.animateKeyframes(withDuration: 0.8,
                                        delay: 0.1,
                                        options: [.calculationModeCubic,.calculationModeCubicPaced],
                                        animations: {
                                            UIView.addKeyframe(withRelativeStartTime: 0,
                                                               relativeDuration: 0,
                                                               animations: {
                                                                self.prepareScreen(forIntermediateAniamtion: state)
                                            })
                                            UIView.addKeyframe(withRelativeStartTime: 0.25,
                                                               relativeDuration: 0.75,
                                                               animations: {
                                                                self.bottomBtn.alpha = state == .OTP ? 1 : 0
                                                                self.bottomDescLbl.alpha = state == .OTP ? 1 : 0
                                            })
                                            self.animate(with: .identity)
                }) { (completed) in
                }
            }
        }
    }
    
    func prepareScreen(forIntermediateAniamtion state : ScreenState){
        let transformation : CGAffineTransform
        let change : CGFloat = iApp.instance.isRTL ? -1 : 1
        if state == .OTP{
            transformation = CGAffineTransform(translationX: self.view.frame.width * change,
                                               y: 0)
        }else{
            transformation = CGAffineTransform(translationX: -self.view.frame.width * change,
                                               y: 0)
        }
        self.titleIV.transform = transformation
        self.titleLbl.transform = transformation
        self.descLbl.transform = transformation
        self.inputFieldHolderView.transform = transformation
        self.checkStatus()
    }
    func animate(with transformation : CGAffineTransform){
        let relativeDuration = 0.25
        UIView.addKeyframe(withRelativeStartTime: relativeDuration * 0,
                           relativeDuration: relativeDuration,
                           animations: {
                            self.titleIV.transform = transformation
        })
        UIView.addKeyframe(withRelativeStartTime: relativeDuration * 1,
                           relativeDuration: relativeDuration,
                           animations: {
                            self.titleLbl.transform = transformation
        })
        UIView.addKeyframe(withRelativeStartTime: relativeDuration * 2,
                           relativeDuration: relativeDuration,
                           animations: {
                            self.descLbl.transform = transformation
        })
        
        UIView.addKeyframe(withRelativeStartTime: relativeDuration * 3,
                           relativeDuration: relativeDuration,
                           animations: {
                            self.inputFieldHolderView.transform = transformation
        })
    }
    //MARK:- OTP timers
    /**
     restrict next otp request for 120 seconds
     */
    func startOTPTimer(){
        self.remainingOTPTime = 120
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                if self.currentScreenState != .OTP{//if in mobile number state
                    timer.invalidate() // Stop
                    return // and return
                }
                self.handleRemainingOTPtime()
                self.remainingOTPTime -= 1
                if self.remainingOTPTime <= 0 {//time reached
                    timer.invalidate()
                    self.canSendOTP()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    func handleRemainingOTPtime(){
        self.bottomDescLbl.text = "You can send OTP again in".localize + " \(self.remainingOTPTime)"
        self.bottomBtn.setTitleColor(.gray, for: .normal)
        self.bottomBtn.isUserInteractionEnabled = false
    }
    func canSendOTP(){
        self.bottomDescLbl.text = "Din't Receive the OTP?".localize
        self.bottomBtn.setTitleColor(.ThemeLight, for: .normal)
        self.bottomBtn.isUserInteractionEnabled = true
    }
    //MARK:- UDF
    func checkStatus(){
        
        let isActive : Bool
        if self.currentScreenState == .mobileNumber{
            isActive = self.mobileNumberView.number?.count ?? 0 > 5 && flag != nil
            self.bottomDescLbl.text = ""
        }else{
            if let _otp = self.otpView.otp{
                isActive = _otp.count == 4//_otp == self.otpView.otp
            }else{
                isActive = false
            }
            
        }
        self.bottomDescLbl.textColor = .black
        self.nextBtn.backgroundColor = isActive ? .ThemeLight : .ThemeInactive
        self.nextBtn.isUserInteractionEnabled = isActive
        
    }
    //On validation success
    func onSuccess(){
        
        guard let number = self.mobileNumberView.number,
            let flag = self.flag else {return}
        self.validationDelegate?
            .verified(number: MobileNumber(number: number,
                                           flag: flag))
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    //Present country VC
    func presentToCountryVC(){
        let mainStory = Stories.main.instance
        let propertyView = mainStory.instantiateViewController(withIdentifier: "CountryListVC") as! CountryListVC
        propertyView.delegate = self
        self.present(propertyView, animated: true, completion: nil)
    }
    /**
     Show error on bottom desc label with shake animation
     - Author: Abishek Robin
     - Parameters:
        - error: Error message
     - Note: error message will change to default state on interaction
     */
    func showError(_ error : String){
        self.bottomDescLbl.text = error
        self.bottomDescLbl.alpha = 1
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeLinear], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                self.bottomDescLbl.textColor = .red
                self.bottomDescLbl.transform =  CGAffineTransform(translationX: 0, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: {
                self.bottomDescLbl.transform = CGAffineTransform(translationX: -5, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6, animations: {
                self.bottomDescLbl.transform = CGAffineTransform(translationX: 5, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.8, animations: {
                self.bottomDescLbl.transform = CGAffineTransform(translationX: -5, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.9, animations: {
                self.bottomDescLbl.transform = CGAffineTransform(translationX: 5, y: 0)
            })
        }) { (_) in
            self.bottomDescLbl.transform =  .identity
        }
        
    }
    //MARK:- Webservices
    func wsToVerifyNumber(){
        guard let number = self.mobileNumberView.number,
            let country = self.flag else{ return }
        var params = Parameters()
        params["mobile_number"] = number
        params["country_code"] = country.dial_code.replacingOccurrences(of: "+", with: "")
        params["forgotpassword"] = self.purpose == NumberValidationPurpose.forgotPassword ? 1 : 0
        
        params["language"] = appDelegate.language
        self.apiInteractor?.getResponse(forAPI: .validateNumber, params: params).shouldLoad(false)
        self.addProgress()
    }
    // Add progress when api call done
    func addProgress()
    {
        nextBtn.titleLabel?.text = ""
        nextBtn.setTitle("", for: .normal)
        spinnerView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        nextBtn.addSubview(spinnerView)
        nextBtn.bringSubviewToFront(spinnerView)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
        spinnerView.beginRefreshing()
    }
    // Remove progress when api call done
    func removeProgress()
    {
        if iApp.instance.isRTL{
            self.nextBtn.setTitle("e", for: .normal)
        }else{
            self.nextBtn.setTitle("I", for: .normal)
        }
        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()
    }
}
extension MobileValidationVC : CountryListDelegate{
    func countryCodeChanged(countryCode: String, dialCode: String, flagImg: UIImage) {
        let flag = FlagModel(forCountryCode: countryCode)
        if !flag.isAccurate{
            flag.country_code = countryCode
            flag.dial_code = dialCode
            flag.flag = flagImg
        }
        self.flag = flag
        self.checkStatus()
    }
    
    
}
