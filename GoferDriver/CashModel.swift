//
//  CashModel.swift
//  GoferDriver
//
//  Created by Trioangle on 27/11/17.
//  Copyright © 2017 Vignesh Palanivel. All rights reserved.
//

import UIKit

class CashModel: NSObject {
    
    var status_message : String = ""
    var status_code : String = ""
    var pay_date : String = ""
    var pay_amount : String = ""
    var payment_method : String = ""
    var invoiceKey : String = ""
    var invoiceValue : String = ""
    
    func getCashData(responseDict: NSDictionary) -> Any
    {
        payment_method =  UberSupport().checkParamTypes(params: responseDict, keys:"payment_method")
       
        return self
    }
    func getInvoiceData(responseDict: NSDictionary) -> Any
    {
        invoiceKey =  UberSupport().checkParamTypes(params: responseDict, keys:"key")
        invoiceValue =  UberSupport().checkParamTypes(params: responseDict, keys:"value")

        return self
    }

}
