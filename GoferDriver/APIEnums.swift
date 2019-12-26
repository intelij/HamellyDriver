//
//  APIEnums.swift
//  GoferDriver
//
//  Created by trioangle on 05/04/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation
import Alamofire

enum APIEnums : String{
    case force_update = "check_version"
    case login = "login"
    case register = "register"
    case validateNumber = "numbervalidation"
    case checkDriverStatus = "check_status"
    
    case inCompleteTrips = "incomplete_trip_details"
    case getInvoice = "get_invoice"
    case cashCollected = "cash_collected"
    case driver_bank_details = "driver_bank_details"
   
}

extension APIEnums{//Return method for API
    var method : HTTPMethod{
        switch self {
        default:
            return .post
        }
    }
}

enum ResponseEnum{
    case RiderModel(_ rider :RiderDetailModel)
    case LoginModel(_ user : LoginModel)
    case driverStatus(_ status : DriverStatus)
    case RatingGiven
    case success
    case number(isValid : Bool,OTP : String,message : String)
    case failure(_ error : String)
    case forceUpdate(_ bool : Bool)
}
