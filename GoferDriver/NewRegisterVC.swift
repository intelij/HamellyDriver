//
//  NewRegisterVC.swift
//  GoferDriver
//
//  Created by trioangle on 15/04/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import UIKit
import Alamofire

class NewRegisterVC: UIViewController,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum) {
        self.removeProgress()
        switch response {
        case .LoginModel(let user):
            dump(user)
            self.handleRegisterResponse(forUser: user)
        default:
            print("lol")
        }
    }
    
    func onFailure(error: String) {
        self.removeProgress()
         self.appDelegate.createToastMessage(error)
    }
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    //MARK:- Outlets
    @IBOutlet weak var pageTitleLbl : UILabel!
    @IBOutlet weak var backBtn : UIButton!
    
    
    @IBOutlet weak var fieldsScrollView : UIScrollView!
    @IBOutlet weak var scrollViewMainChild : UIView!
    @IBOutlet var fieldCollection: [UITextField]!
    @IBOutlet var barCollection: [UILabel]!
    @IBOutlet weak var dialCode : UILabel!
    @IBOutlet weak var flagImg : UIImageView!
    
    @IBOutlet weak var bottomSignUpView : UIView!
    @IBOutlet weak var signUpBtn : UIButton!
    @IBOutlet weak var terms_and_condition : UILabel!
    @IBOutlet weak var bottomSignInView : UIView!
    @IBOutlet weak var alreadySingInLbl : UILabel!
    @IBOutlet weak var signInBtn : UIButton!
    
    var spinnerView = JTMaterialSpinner()
    var verified_mobile_number : String!
    var country_dial_code : String!
    let bottomViewHeight : CGFloat = 80
    //MARK:- view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.initView()
        }
        self.initGestures()
        self.initLocalization()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    //MARK:- initalizers
    func initView(){
        let bottomSignInFrame = CGRect(x: 0,
                                 y: self.view.frame.height - bottomViewHeight + 20,
                                 width: self.view.frame.width,
                                 height: bottomViewHeight - 20)
        let bottomSingUpFrame = CGRect(x: 0,
                                       y: self.view.frame.height - bottomViewHeight,
                                       width: self.view.frame.width,
                                       height: bottomViewHeight)
        self.bottomSignInView.frame = bottomSignInFrame
        self.bottomSignUpView.frame = bottomSingUpFrame
        self.view.addSubview(self.bottomSignInView)
        self.view.addSubview(self.bottomSignUpView)
        self.view.bringSubviewToFront(self.bottomSignInView)
        self.view.bringSubviewToFront(self.bottomSignUpView)
        self.bottomSignInView.transform = CGAffineTransform(scaleX: 0, y: bottomViewHeight)
        self.bottomSignUpView.transform = CGAffineTransform(scaleX: 0, y: bottomViewHeight)
        
        self.flagImg.contentMode = .scaleToFill
        self.flagImg.clipsToBounds = true
        
        self.fieldCollection.forEach({$0.delegate = self})
        self.bottomSignUpView.transform = .identity
      
        self.signUpBtn.isRoundCorner = true
        self.bottomSignUpView.elevate(6)
        
        self.resetBars()
        self.setKeyBoardTypes()
        self.listen2Keyboard(withView: self.bottomSignUpView)
        self.setHyperLink()
        self.checkNextButtonStatus()
        
    }
    func initGestures(){
        
    }
    func initLocalization(){
        self.pageTitleLbl.text = "SIGN UP".localize
        
        //setting placehodler for register fields
        for field in self.fieldCollection{
            guard let regField = RegisterFields(rawValue: field.tag) else {continue}
            field.placeholder = regField.localizedPlaceHolder
            if regField == .mobile  {
                field.text = self.verified_mobile_number
                field.isUserInteractionEnabled = false
            }
        }
        let flag = FlagModel(forDialCode: self.country_dial_code )
        self.flagImg.image = flag.flag
        self.dialCode.text = flag.dial_code
   
        self.signInBtn.setTitle("Login".localize, for: .normal)
    }
    //MARK:-init with story
    
    class func initWithStory(withNumber number: String?,_ code : String? )-> NewRegisterVC{
        let story = Stories.account.instance
        let vc = story.instantiateViewController(withIdentifier: "NewRegisterVC") as! NewRegisterVC
        vc.apiInteractor = APIInteractor(vc)
        vc.verified_mobile_number = number
        vc.country_dial_code = code
        return vc
    }
    //MARK:- UDF
    //MARK: finding weather the fields are fields are completed
    func checkNextButtonStatus()
    {
        var fieldsCompleted = true
        for field in fieldCollection{
            guard let text = field.text,let regField = RegisterFields(rawValue: field.tag) else{continue}
            fieldsCompleted = regField.isValidContent(text)
            guard fieldsCompleted else{break}
        }
        self.signUpBtn.isUserInteractionEnabled = fieldsCompleted
        self.signUpBtn.backgroundColor = fieldsCompleted ? .ThemeMain : .ThemeInactive
      
    }
    // DISPLAY PROGRESS
    func addProgress()
    {
        self.signUpBtn.isUserInteractionEnabled = false
        self.signUpBtn.titleLabel?.text = ""
        self.signUpBtn.setTitle("", for: .normal)
        self.signUpBtn.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
        spinnerView.beginRefreshing()
    }
    
    // REMOVE PROGRESS
    func removeProgress()
    {
        self.signUpBtn.isUserInteractionEnabled = true
        self.signUpBtn.titleLabel?.text = NEXT_ICON_NAME
        self.signUpBtn.setTitle(NEXT_ICON_NAME, for: .normal)
        self.spinnerView.endRefreshing()
        
        spinnerView.removeFromSuperview()
    }
    func setHyperLink(){
        let full_text = NSLocalizedString("By continuing, I confirm that i have read and agree to the Terms & Conditions and Privacy Policy.", comment: "")
        let terms_text = NSLocalizedString("Terms & Conditions", comment: "")
        let privacy_text = NSLocalizedString("Privacy Policy", comment: "")
        
        self.terms_and_condition.setText(full_text, withLinks: [
            HyperLinkModel(url: URL(string: "\(iApp.baseURL.rawValue)terms_of_service")!, string: terms_text),
            HyperLinkModel(url: URL(string: "\(iApp.baseURL.rawValue)privacy_policy")!, string: privacy_text)
            ])
        
    }
    func setKeyBoardTypes(){
        for field in fieldCollection{
            guard let regField = RegisterFields(rawValue: field.tag) else {return}
            field.keyboardType = regField.keyboardType
            if regField == .password{
                field.isSecureTextEntry = true
            }
        }
    }
    func resetBars(){
     
        for bar in self.barCollection{
            bar.backgroundColor =  UIColor.ThemeInactive.withAlphaComponent(0.75)
        }
    }
    func handleRegisterResponse(forUser user:LoginModel ){
        let flag = FlagModel(forDialCode: self.country_dial_code ?? "+01")
        flag.store()
        let mainStory = Stories.main.instance
        let chooseVehicleView = mainStory.instantiateViewController(withIdentifier: "ChooseVehicle") as! ChooseVehicle
        chooseVehicleView.carDetailModel = user.car_details
        self.navigationController?.pushViewController(chooseVehicleView, animated: true)
    }
    //MARK:- Actions
    
    @IBAction func backAction(_ sender : UIButton){
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
           self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func signInAction(_ sender : UIButton){
        
    }
    @IBAction func signUpAction(_ sender : UIButton){
        addProgress()
        self.view.endEditing(true)
        self.fieldsScrollView.setContentOffset(CGPoint(x: 0,y :0), animated: true)
        self.fieldsScrollView.contentSize = CGSize(width: fieldsScrollView.frame.size.width, height:  scrollViewMainChild.frame.size.height+50)
        self.signUpBtn.isUserInteractionEnabled = false
        var params = Parameters()
        for field in fieldCollection{
            guard let regField = RegisterFields(rawValue: field.tag),
                let text = field.text else {continue}
            params[regField.paramKey] = text
        }
        let strDeviceType = "1"
        let strDeviceToken = YSSupport.getDeviceToken()
        let strUserType = "Driver"
        params["new_user"] = "1"
        params["device_id"] = strDeviceToken ?? ""
        params["device_type"] = strDeviceType
        params["user_type"] = strUserType
        params["country_code"] = self.country_dial_code
        self.apiInteractor?.getResponse(forAPI: .register, params: params)
    }

}
extension NewRegisterVC : UITextFieldDelegate{
  
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
    {
        self.bottomSignInView.isHidden = true
        for bar in self.barCollection{
            let selected = textField.tag == bar.tag
            bar.backgroundColor = selected ? .ThemeMain : UIColor.ThemeInactive.withAlphaComponent(0.75)
        }
        switch RegisterFields(rawValue: textField.tag) ?? .first_name {
        case .first_name,.last_name:
            self.fieldsScrollView.setContentOffset(CGPoint(x: 0,y :0), animated: true)
        default:
            self.fieldsScrollView.setContentOffset(CGPoint(x: 0,y :textField.tag * 35), animated: true)
        }
        return true
    }
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        self.checkNextButtonStatus()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
       
        self.resetBars()
        fieldsScrollView.contentSize = CGSize(width: fieldsScrollView.frame.size.width, height:  scrollViewMainChild.frame.size.height+50)
        switch RegisterFields(rawValue: textField.tag) ?? .first_name {
        case .first_name,.last_name,.city:
            self.fieldsScrollView.setContentOffset(CGPoint(x: 0,y :0), animated: true)
        default:
            self.fieldsScrollView.setContentOffset(CGPoint(x: 0,y :textField.tag * 5), animated: true)
        }
        return true
    }
}
