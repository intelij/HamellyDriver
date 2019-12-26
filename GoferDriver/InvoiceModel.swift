//
//  InvoiceModel.swift
//  Gofer
//
//  Created by Trioangle on 17/10/18.
//  Copyright © 2018 Vignesh Palanivel. All rights reserved.
//

import UIKit



class InvoiceModel: NSObject {
    
    var invoiceKey : String = ""
    var invoiceValue : String = ""
    var bar = 0
    var color = String()
    
    override init(){}
    init(_ json : JSON){
        invoiceKey = json.string("key")
        invoiceValue = json.string("value")
        bar = json.int("bar")
        color = json.string("colour")
    }
    
    func initInvoiceData(responseDict: NSDictionary) -> Any
    {
        guard let json = responseDict as? JSON else {return self}
        invoiceKey = json.string("key")
        invoiceValue = json.string("value")
        bar = json.int("bar")
        color = json.string("colour")
        return self
    }

}
