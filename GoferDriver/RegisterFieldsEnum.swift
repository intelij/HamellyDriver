//
//  RegisterFieldsEnum.swift
//  GoferDriver
//
//  Created by trioangle on 16/04/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation

enum RegisterFields : Int{
    case first_name = 1
    case last_name = 2
    case email = 3
    case mobile = 4
    case password = 5
    case city = 6
    case referal = 7
    
    var keyboardType : UIKeyboardType{
        switch self {
        case .first_name,.last_name,.city:
            return .asciiCapable
        case .email:
            return .emailAddress
        case .password:
            return .asciiCapable
        default:
            return .asciiCapable
        }
    }
    
    var localizedPlaceHolder : String{
        switch self {
        case .first_name:
            return "First Name".localize
        case .last_name:
            return "Last Name".localize
        case .email:
            return "name@example.com".localize
        case .password:
            return "Password".localize
        case .city:
            return "City".localize
        case .referal:
            return "Referral (Optional)"
        default:
            return ""
        }
    }
    func isValidContent(_ text : String) -> Bool{
        switch self{
        case .email:
            return  UberSupport().isValidEmail(testStr: text )
            
        case .first_name,.last_name,.city:
            return !text.isEmpty
            
        case .password:
            return  !text.isEmpty && text.count > 4
        default:
            return true
        }
    }
    var paramKey : String{
        switch self {
        case .first_name:
            return "first_name"
        case .last_name:
            return "last_name"
        case .email:
            return "email_id"
        case .password:
            return "password"
        case .city:
            return "city"
        case .mobile:
            return "mobile_number"
        default:
            return ""
        }
      
    }
}
