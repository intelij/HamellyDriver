/**
* CurrencyModel.swift
 //  Gofer
 //
 //  Created by Trioangle on 16/05/18.
 //  Copyright © 2018 Vignesh Palanivel. All rights reserved.
 //
* @link http://trioangle.com
*/


import Foundation
import UIKit

class CurrencyModel : NSObject {
    
    //MARK Properties
    var success_message : NSString = ""
    var status_code : NSString = ""
    var currency_code : NSString = ""
    var currency_symbol : NSString = ""

   // MARK: Inits
    func initiateCurrencyData(responseDict: NSDictionary) -> Any
    {
        currency_code = self.checkParamTypes(params: responseDict, keys:"code")
        currency_symbol = self.checkParamTypes(params: responseDict, keys:"symbol")
        return self
    }
    
    
    //MARK: Check Param Type
    func checkParamTypes(params:NSDictionary, keys:NSString) -> NSString
    {
        if let latestValue = params[keys] as? NSString {
            return latestValue as NSString
        }
        else if let latestValue = params[keys] as? String {
            return latestValue as NSString
        }
        else if let latestValue = params[keys] as? Int {
            return String(format:"%d",latestValue) as NSString
        }
        else if (params[keys] as? NSNull) != nil {
            return ""
        }
        else
        {
            return ""
        }
    }

}
