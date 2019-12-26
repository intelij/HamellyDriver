//
//  WebServiceHandler.swift
//   GoferDriver
//
//  Created by Vignesh Palanivel on 16/10/18.
//  Copyright © 2018 Vignesh Palanivel. All rights reserved.
//

import UIKit
import Alamofire

class WebServiceHandler: NSObject {

    static var sharedInstance = WebServiceHandler()
   let appDelegate = UIApplication.shared.delegate as! AppDelegate
    func getWebPostService(wsMethod:String, paramDict: [String:Any], viewController:UIViewController, isToShowProgress:Bool, isToStopInteraction:Bool, complete:@escaping (_ response: [String:Any]) -> Void) {
        
        if isToShowProgress {
            UberSupport().showProgress(viewCtrl: viewController, showAnimation: true)
        }
        else if isToStopInteraction {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        Alamofire.request("\(iApp.APIBaseUrl)\(wsMethod)", method: .post, parameters: paramDict)
            .validate()
            .responseJSON { response in
                if isToShowProgress {
                    UberSupport().removeProgress(viewCtrl: viewController)
                }
                else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                switch response.result {
                case .success:
                    print("Validation Successful")
                    print(response.result.value!)
                    complete(response.result.value! as! [String : Any])
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func getWebService(wsMethod:String, paramDict: [String:Any], viewController:UIViewController, isToShowProgress:Bool, isToStopInteraction:Bool, complete:@escaping (_ response: [String:Any]) -> Void) {
        
        if isToShowProgress {
            UberSupport().showProgress(viewCtrl: viewController, showAnimation: true)
        }
        else if isToStopInteraction {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
//        Alamofire.request
        Alamofire.request("\(iApp.APIBaseUrl)\(wsMethod)", method: .post, parameters: paramDict)
            .validate()
                .responseJSON { response in
                    
                    
                    print(response.request?.url)
                    if isToShowProgress {
                        UberSupport().removeProgress(viewCtrl: viewController)
                    }
                    else {
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    switch response.result {
                    case .success:
                        print("Validation Successful")
                        print(response.request?.url! as Any)
                        print(response.result.value!)
                        complete(response.result.value! as! [String : Any])
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    func postWebService(wsMethod:String, paramDict: [String:Any], viewController:UIViewController, isToShowProgress:Bool, isToStopInteraction:Bool, complete:@escaping (_ response: [String:Any]) -> Void) {
        
        if isToShowProgress {
            UberSupport().showProgress(viewCtrl: viewController, showAnimation: true)
        }
        else if isToStopInteraction {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        //        Alamofire.request
        Alamofire.request("\(iApp.APIBaseUrl)\(wsMethod)", method: .post, parameters: paramDict)
            .validate()
            .responseJSON { response in
                
                
                print(response.request?.url)
                if isToShowProgress {
                    UberSupport().removeProgress(viewCtrl: viewController)
                }
                else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                switch response.result {
                case .success:
                    print("Validation Successful")
                    print(response.request?.url! as Any)
                    print(response.result.value!)
                    complete(response.result.value! as! [String : Any])
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func uploadPost(wsMethod:String, paramDict: [String:Any], fileName:String="image", imgData:Data, viewController:UIViewController, isToShowProgress:Bool, isToStopInteraction:Bool, complete:@escaping (_ response: [String:Any]) -> Void) {
        
        if isToShowProgress {
            UberSupport().showProgress(viewCtrl: viewController, showAnimation: true)
        }
        if isToStopInteraction {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        
        
        print(imgData)
        print(fileName)
        
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            let fileName1 =  String(Date().timeIntervalSince1970 * 1000) + "\(fileName).jpg"
            multipartFormData.append(imgData, withName: fileName,fileName: fileName1, mimeType: "image/jpeg")
            
            for (key, value) in paramDict {
                multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
            } //Optional for extra parameters
        },to:"\(iApp.APIBaseUrl)\(wsMethod)") { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    
                })
                upload.responseJSON { response in
                    if isToShowProgress {
                        UberSupport().removeProgress(viewCtrl: viewController)
                    }
                    if isToStopInteraction {
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    switch response.result {
                    case .success(let data):
                        print(data)
                    case .failure(let error):
                        print(error)
                        
                    }
                    let responseDict = response.result.value as? [String : Any] ?? [String:Any]()
                    
                    guard responseDict["error"] == nil else {
                        self.appDelegate.createToastMessageForAlamofire(responseDict.string("error"), bgColor: .black, textColor: .white, forView: viewController.view)
                        return
                    }
                    
                    guard responseDict.count > 0 else {
                        self.appDelegate.createToastMessageForAlamofire("Image upload failed", bgColor: .black, textColor: .white, forView: viewController.view)
                        return
                    }
                    
                    if (responseDict["status_code"] as! String ) == "0" && ((responseDict["success_message"] as! String) == "Inactive User" || (responseDict["success_message"] as! String) == "The token has been blacklisted" ||  responseDict["success_message"] as! String == "User not found") {
                        //                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "k_LogoutUser"), object: nil)
                    }
                    else {
                        complete(response.result.value as? [String : Any] ?? [:])
                    }
                    
                    
                }
            case .failure(let encodingError):
                print(encodingError)
                if encodingError._code == 4 {
                    self.appDelegate.createToastMessageForAlamofire("We are having trouble fetching the menu. Please try again.", bgColor: .black, textColor: .white, forView: viewController.view)
                    
                }
                else {
                    self.appDelegate.createToastMessageForAlamofire(encodingError.localizedDescription, bgColor: .black, textColor: .white, forView: viewController.view)
                }
            }
        }
    }
}
