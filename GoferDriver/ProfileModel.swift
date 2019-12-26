/**
* ProfileModel.swift
*
* @package UberDiver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/


import Foundation
import UIKit

class ProfileModel : NSObject {
    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""

    var address_line1 : String = ""
    var address_line2 : String = ""
    var city : String = ""
    var country_code : String = ""
    var email_id : String = ""
    var car_id : String = ""
    var first_name : String = ""
    var insurance : String = ""
    var last_name : String = ""
    var license_back : String = ""
    var license_front : String = ""
    var mobile_number : String = ""
    var permit : String = ""
    var postal_code : String = ""
    var user_thumb_image : String = ""
    var rc : String = ""
    var state : String = ""
    var user_name : String = ""
    var vehicle_no : String = ""
    var vehicle_name : String = ""
    var car_type :String = ""
    var currency_code : String = ""
    var currency_symbol : String = ""
    var customer_support : String = ""
    var car_image : String = ""
    var car_active_image : String = ""
    
    var company_id = Int()
    var company_name = String()
    var bankDetails: BankDetails = BankDetails()

}
class BankDetails {
    
    
    var id = Int()
    var user_id = Int()
    var holder_name = String()
    var account_number = String()
    var bank_name = String()
    var bank_location = String()
    var code = String()
    var created_at = String()
    var updated_at = String()
    init() {
    }
    init(json:JSON) {
        self.id = json.int("id")
        self.user_id = json.int("user_id")
        self.holder_name = json.string("holder_name")
        self.account_number = json.string("account_number")
        self.bank_name = json.string("bank_name")
        self.bank_location = json.string("bank_location")
        self.code = json.string("code")
        self.created_at = json.string("created_at")
        self.updated_at = json.string("updated_at")
        
    }
    
}
