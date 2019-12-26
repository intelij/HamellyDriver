//
//  AccountKitHelper.swift
//  GoferDriver
//
//  Created by bowshul sheik rahaman on 19/01/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation
import AccountKit

typealias AK_OnSuccess = (Account?) -> ()
typealias MyClosure = ()->()

class AccountKitHelper :NSObject ,AKFViewControllerDelegate{
    
    //account kit facebook variable
    var _accountKit: AccountKit!
    private var baseViewController : UIViewController!
    
    
    var onSuccess : AK_OnSuccess!
    var onFailure : MyClosure!
    
     override init() {
        
    }
    static let instance = AccountKitHelper()
    //MARK: Facebook initializers
    func verifyWithView(_ vc : UIViewController, number : PhoneNumber?, success : @escaping AK_OnSuccess, failure : @escaping MyClosure) {
        
        self.baseViewController = vc
        self.onSuccess = success
        self.onFailure = failure
        
        if _accountKit == nil {
            _accountKit = AccountKit(responseType: .accessToken)
        }
        self.loginWithPhone(number)
    }
    
     func prepareLoginViewController(_ vc: AKFViewController) {
        vc.delegate = self
        //UI Theming - Optional
        vc.isGetACallEnabled = true
        vc.isSendToFacebookEnabled = true
        vc.uiManager = SkinManager(skinType: .classic, primaryColor: UIColor.ThemeMain)
        
    }
    
    func loginWithPhone(_ no : PhoneNumber?){
        let inputState = UUID().uuidString
        
        if let accountKitVC = (_accountKit?.viewControllerForPhoneLogin(with: no, state: inputState)) as? AKFViewController{
            accountKitVC.isSendToFacebookEnabled = true
            self.prepareLoginViewController(accountKitVC)
            self.baseViewController.present(accountKitVC as! UIViewController , animated: true, completion: nil)
        }
    }
    
    //MARK: Facebook account kit delegates
    //onSuccess
 
    func viewController(_ viewController: UIViewController & AKFViewController, didCompleteLoginWith accessToken: AccessToken, state: String) {
        print("did complete login with access token \(accessToken.tokenString) ")
        _accountKit.requestAccount { (account, error) in
            if let err = error{
                print("some thing went wrong !",err)
                self.onFailure()
            }else{
                self.onSuccess(account)
                
            }
        }
    }
    func viewControllerDidCancel(_ viewController: UIViewController & AKFViewController) {
        print("User cancelled facebook login")
        self.onFailure()
    }
    func viewController(_ viewController: UIViewController & AKFViewController, didFailWithError error: Error) {
        print("error")
        self.onFailure()
    }
   
}

