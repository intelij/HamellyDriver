//
//  HomeVC.swift
//  GoferDriver
//
//  Created by Vignesh Palanivel on 29/03/17.
//  Copyright © 2017 Vignesh Palanivel. All rights reserved.
//

import Foundation
import UIKit


class HomeVC : UIViewController {
    
    @IBOutlet var viewHolder: UIView!
    @IBOutlet fileprivate var selectedView: UIView?
    @IBOutlet var viewTitle: UIView!
    @IBOutlet var imgBg: UIImageView!
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var btnRegister: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var lookingRiderAppButtonOutler: UIButton!
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate

    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.appDelegate.registerForRemoteNotification()
        btnSignIn.layer.borderColor = UIColor.ThemeMain.cgColor
        btnSignIn.setTitleColor(.ThemeMain, for: .normal)
        btnSignIn.layer.borderWidth = 1.0
        startAnimation()
        self.setCountryInfo()
        if appDelegate.language == "ja" {
            btnSignIn.setTitle("SIGN IN".localize, for: .normal)
            btnRegister.setTitle("REGISTER".localize, for: .normal)
            lookingRiderAppButtonOutler.setTitle("LOOKING FOR THE RIDER APP?".localize, for: .normal)
        }
       

    }
    // MARK: - ViewController Methods
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.appDelegate.registerForRemoteNotification()
//        UberSupport().changeStatusBarStyle(style: .lightContent)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // Getting Country Dial Code and Flag from plist file
    func setCountryInfo()
    {
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            var arrCountryList : NSMutableArray = NSMutableArray()
            let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
            arrCountryList = NSMutableArray(contentsOfFile: path!)!
            var strCountry = ""
            for i in 0 ..< arrCountryList.count
            {
                if countryCode == ((arrCountryList[i] as AnyObject).value(forKey: "code") as? String ?? String())
                {
                    print(((arrCountryList[i] as AnyObject).value(forKey: "dial_code") as? String ?? String()))
                    strCountry = ((arrCountryList[i] as AnyObject).value(forKey: "dial_code") as? String ?? String())
                }
            }
            Constants().STOREVALUE(value: strCountry, keyname: USER_DIAL_CODE)
            Constants().STOREVALUE(value: countryCode, keyname: USER_COUNTRY_CODE)
        }
    }
    
    func startRotating(duration: Double = 10)
    {
        let kAnimationKey = "rotation"
        let animate = CABasicAnimation(keyPath: "transform.rotation")
        animate.duration = duration
        animate.repeatCount = Float.infinity
        animate.fromValue = 0.0
        animate.toValue = Float(.pi * 2.0)
        imgBg.layer.add(animate, forKey: kAnimationKey)
    }
    
    

    func startAnimation()
    {
        let animation = CircularRevealAnimation(from: CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2), to: self.view.bounds)
        self.view.layer.mask = animation.shape()
        self.view.alpha = 1
        animation.commit(duration: 0.5, expand: true, completionBlock: {
            self.view.layer.mask = nil
        })
    }

    //MARK: - OPEN RIDER APP
    @IBAction func onLookingForAppTapped(_ sender:UIButton!)
    {
        let instagramUrl = URL(string: "\(iApp.Rider().appName)://")
        if UIApplication.shared.canOpenURL(instagramUrl!)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:"\(iApp.Rider().appName)://")!)
            } else {
                UIApplication.shared.openURL((URL(string:"\(iApp.Rider().appName)://")!))
            }
        } else {
            if let url = URL(string: "https://itunes.apple.com/us/app/\(iApp.Rider().appStoreDisplayName)/\(iApp.Rider().appID)?ls=1&mt=8")
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    //MARK: - NAVIGATE TO LOGIN PAGE
    @IBAction func onSignInTapped(_ sender:UIButton!)
    {
            let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            self.navigationController?.pushViewController(propertyView, animated: true)
   
    }
    
    //MARK: - NAVIGATE TO REGISTRATION PAGE
    @IBAction func onRegisterTapped(_ sender:UIButton!)
    {
       
        let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                  for: .register)
        self.present(mobileValidationVC, animated: true, completion: nil)
//        AccountKitHelper.instance.verifyWithView(self, number: nil, success: { (account) in
//            let number = account?.phoneNumber!
//            dump(number)
//            self.verifyToAPI(number: number!.phoneNumber, dialCode: number!.countryCode)
//
//        }) {
//
//        }
//            let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
//            self.navigationController?.pushViewController(propertyView, animated: true)
    }
    func verifyToAPI(number : String,dialCode : String){
        AccountInteractor.instance.checkRegistrationStatus(forNumber: number,
                                                countryCode: dialCode,
                                                { (isExist, message) in
                                                    if !isExist{
                                                        let registerView = NewRegisterVC.initWithStory(withNumber: number, dialCode)
                                                        self.navigationController?.pushViewController(registerView, animated: true)
                                                    }else{
                                                        self.appDelegate.createToastMessage(message)
                                                    }
        })
    }
}
extension HomeVC : MobileNumberValiadationProtocol{
    func verified(number: MobileNumber) {
        let registerView = NewRegisterVC.initWithStory(withNumber: number.number,
                                                       number.flag.dial_code)
        self.navigationController?.pushViewController(registerView, animated: true)

    }
    
    
}
