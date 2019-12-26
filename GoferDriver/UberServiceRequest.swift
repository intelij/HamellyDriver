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
    func getBlockServerResponseForparam(_ params: [AnyHashable: Any], method: NSString, withSuccessionBlock successBlock: @escaping (_ response: Any) -> Void, andFailureBlock failureBlock: @escaping (_ error: Error) -> Void)
    {
        let myURL = iApp.APIBaseUrl + "\(method)"
        // NSURL(string: (UberCreateUrl().serializeURL(params: params as NSDictionary, methodName: method) as NSString) as String)!
       print(myURL)
       
        let params = Parameters()
   //     let header = Parameters()
        
            let header : [AnyHashable: Any]  = ["Content-Type":"application/x-www-form-urlencoded","Accept":"application/json","token": Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)]
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

