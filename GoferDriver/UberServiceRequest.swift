/**
* UberServiceRequest.swift
*
* @package Gofer
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Alamofire

class UberServiceRequest: NSObject {
    //MARK: API REQUEST - GET METHOD
    private lazy var appDelegate : AppDelegate? = {
        return UIApplication.shared.delegate as? AppDelegate
    }()
    func getBlockServerResponseForparam(params: [String: Any], method: NSString, withSuccessionBlock successBlock: @escaping (_ response: Any) -> Void, andFailureBlock failureBlock: @escaping (_ error: Error) -> Void)
    {
        let myURL = iApp.APIBaseUrl + "\(method)"
        // NSURL(string: (UberCreateUrl().serializeURL(params: params as NSDictionary, methodName: method) as NSString) as String)!
       print(myURL)
       
        let params = Parameters()
   //     let header = Parameters()
        
            let header : [String: Any]  = ["Content-Type":"application/x-www-form-urlencoded","Accept":"application/json","token": Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)]
        Alamofire.request(myURL.description,
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: (header as! HTTPHeaders))
            .responseJSON { (response) in
                print("Å API: ",response.request?.url ?? "\(iApp.APIBaseUrl+method.description) : \(params)")
                guard response.response?.statusCode != 401 else{//Unauthorized
                    self.appDelegate?.logOutDidFinish()
                    return
                }
                switch response.result{
                case .success(let value):
                    if let json = value as? JSON{
                        successBlock(UberSeparateParam()
                            .separate(params:  json as NSDictionary,
                                      methodName: method))
                    }else{
                        failureBlock(APIErrors.JSON_InCompatable)
                    }
                case .failure(let error):
                    failureBlock(error)
                }
        }
    }
    
    
    
    
}


extension UberServiceRequest {
    
    
    // add post method
    
    func postBlockServerResponseForparam(_ params: [String: Any], method: NSString, withSuccessionBlock successBlock: @escaping (_ response: Any) -> Void, andFailureBlock failureBlock: @escaping (_ error: Error) -> Void)
    {
        
        let header : [AnyHashable: Any]  = ["Content-Type":"application/x-www-form-urlencoded","Accept":"application/json","token": Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)]
        
        let myURL =  iApp.APIBaseUrl + "\(method)"//URL(string: UberCreateUrl().serializeURL(params: header as NSDictionary, methodName: method) as String)
        
        
        var paramters = Parameters()
        print(myURL)
        if method == "device-update" {
            return
        }
        
        
        
       let strDeviceToken = YSSupport.getDeviceToken()
       let strUserType = "Rider"
        
        params.forEach { (key,value) in
            paramters[key] = value
        }
        paramters["device_type"] = 1
        paramters["device_id"] = strDeviceToken //"no device token yet"//
        paramters["user_type"] = strUserType
        paramters["language"] = "en"
        paramters["city"] = "56"
        paramters["work"] = "asd"
        Alamofire.request(myURL,
                          method: .post,
                          parameters: paramters,
                          encoding: URLEncoding.default,
                          headers: (header as! HTTPHeaders))
            .responseJSON { (response) in
                print("Å API: ",response.request?.url ?? "\(iApp.APIBaseUrl+method.description) : \(params)")
                guard response.response?.statusCode != 401 else{//Unauthorized
//                    Shared.instance.resetUserData()
//                    self.appDelegate?.option = ""
//                    self.appDelegate?.amount = ""
                    self.appDelegate?.showLoginView()
                    return
                }
                switch response.result{
                case .success(let value):
                    if let json = value as? JSON{
                        successBlock(UberSeparateParam()
                            .separate(params:  json as NSDictionary,
                                      methodName: method))
                    }else{
                        failureBlock(APIErrors.JSON_InCompatable)
                    }
                case .failure(let error):
                    failureBlock(error)
                }
        }
    }
}
