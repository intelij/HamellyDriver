/**
* UberAPICalls.swift
*
* @package Gofer
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit

class UberAPICalls: NSObject {
    var userDefaults = UserDefaults.standard

    //MARK: Login API Calls
    
    func GetRequest(_ dict: [String: Any], methodName : NSString, forSuccessionBlock successBlock: @escaping (_ newResponse: Any) -> Void, andFailureBlock failureBlock: @escaping (_ error: Error) -> Void) {
        let sreq = UberServiceRequest()
        let params = dict
        sreq.getBlockServerResponseForparam( params: params, method: methodName, withSuccessionBlock: { (response) in
            successBlock(response)
        }) { (error) in
             failureBlock(error)
        }
        
        
//        sreq.getBlockServerResponseForparam(dict, method: methodName, withSuccessionBlock: {(_ response: Any) -> Void in
//            successBlock(response)
//        }, andFailureBlock: {(_ error: Error) -> Void in
//            failureBlock(error)
//        })
    }
    

    func showNotification() {
    }

    func PostRequest(_ dict: [String: Any], methodName : NSString, forSuccessionBlock successBlock: @escaping (_ newResponse: Any) -> Void, andFailureBlock failureBlock: @escaping (_ error: Error) -> Void) {
         

          let sreq = UberServiceRequest()
          
          
          sreq.postBlockServerResponseForparam(dict, method: methodName, withSuccessionBlock: {(_ response: Any) -> Void in
                    successBlock(response)
                }, andFailureBlock: {(_ error: Error) -> Void in
                    failureBlock(error)
                })
          }

    
    
}
