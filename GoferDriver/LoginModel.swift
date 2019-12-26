/**
 * LoginModel.swift
 *
 * @package UberDiver
 * @subpackage Controller
 * @category Calendar
 * @author Trioangle Product Team
 * @version - Stable 1.0
 * @link http://trioangle.com
 */



import Foundation
import UIKit

class LoginModel : NSObject {
    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var access_token : String = ""
    var first_name : String = ""
    var last_name : String = ""
    var mobile_number : String = ""
    var Payment_method : String = ""
    var email_id : String = ""
    var home_location_name : String = ""
    var work_location_name : String = ""
    var user_status : String = ""
    var user_thumb_image : String = ""
    var user_id : String = ""
    var user_name : String = ""
    
    var insurance : String = ""
    var license_back : String = ""
    var license_front : String = ""
    var permit : String = ""
    var rc : String = ""
    var vehicle_id : String = ""
    var vehicle_number : String = ""
    var vehicle_type : String = ""
    var paypal_email_id : String = ""

    var car_details : NSMutableArray = NSMutableArray()
    var company_name = String()
    var company_id = String()
    override init(){
        super.init()
    }
    init(_ json : JSON){
        super.init()
        self.status_message = json.status_message
        self.status_code = json["status_code"] as? String ?? String()
        var carType = ""
        var carId = ""
        
       
        
                self.car_details = NSMutableArray()
                
                if json["car_detais"] != nil
                {
                    let arrData = json["car_detais"] as? NSArray ?? NSArray()
                    if arrData.count > 0
                    {
                        
                        for i in 0 ..< arrData.count
                        {
                            self.car_details.addObjects(from: ([CarDetailModel().initCarDetails(responseDict: arrData[i] as! NSDictionary)]))
                        }
                    }
                }
            
            
            self.access_token = json["access_token"] as? String ?? String()
            self.first_name = json.string("first_name")
            self.last_name = json.string("last_name")
            self.mobile_number = json.string("mobile_number")
            self.email_id = json.string("email_id")
            self.home_location_name = json.string("home_location_name")
            self.work_location_name = json.string("work_location_name")
            self.user_status = json.string("user_status")
            DriverStatus.getStatus(forString: self.user_status).storeInPreference()
            self.user_name = String(format:"%@ %@",self.first_name , self.last_name)
            
            self.user_thumb_image = json.string("user_thumb_image")
            self.email_id = json.string("email_id")
            self.user_id = json.string("user_id")
            self.vehicle_id = json.string("vehicle_id")
            
            self.insurance = json.string("insurance")
            self.license_back = json.string("license_back")
            self.license_front = json.string("license_front")
            self.permit = json.string("permit")
            self.rc = json.string("rc")
            self.vehicle_id = json.string("vehicle_id")
            self.vehicle_number = json.string("vehicle_number")
            self.vehicle_type = json.string("vehicle_type")
            self.paypal_email_id = json.string("payout_id")
            self.company_id = json.string("company_id")
            self.company_name = json.string("company_name")
        
            
            let currency = self.makeCurrencySymbols(encodedString: json.string("currency_symbol") )
            Constants().STOREVALUE(value: currency, keyname: USER_CURRENCY_SYMBOL_ORG)
            Constants().STOREVALUE(value: json.string("currency_code") , keyname: USER_CURRENCY_ORG)
        
            Constants().STOREVALUE(value: "Offline", keyname: USER_ONLINE_STATUS) // its used for driver online/offline switch
            Constants().STOREVALUE(value: "Offline", keyname: TRIP_STATUS)
            
            let userDefaults = UserDefaults.standard
            for i in 0 ..< self.car_details.count
            {
                let model = self.car_details[i] as! CarDetailModel
                if i == 0
                {
                    carType = model.car_name
                    carId = model.car_id
                }
                else if i == self.car_details.count-1
                {
                    carType = String(format: "%@,%@",carType ,model.car_name)
                    carId = String(format: "%@,%@",carId ,model.car_id)
                }
                else
                {
                    carType = String(format: "%@,%@",carType, model.car_name)
                    carId = String(format: "%@,%@",carId, model.car_id)
                }
            }
            
            userDefaults.set(carType, forKey: USER_CAR_TYPE)
            userDefaults.set(carId, forKey: USER_CAR_IDS)
            
            //            Constants().STOREVALUE(value: self.paypal_email_id, keyname: USER_PAYPAL_EMAIL_ID)
            Constants().STOREVALUE(value: self.user_status, keyname: USER_STATUS)
            Constants().STOREVALUE(value: self.access_token, keyname: USER_ACCESS_TOKEN)
            Constants().STOREVALUE(value: self.user_name, keyname: USER_FULL_NAME)
            Constants().STOREVALUE(value: self.first_name, keyname: USER_FIRST_NAME)
            Constants().STOREVALUE(value: self.last_name, keyname: USER_LAST_NAME)
            Constants().STOREVALUE(value: self.user_thumb_image, keyname: USER_IMAGE_THUMB)
            Constants().STOREVALUE(value: self.user_id, keyname: USER_ID)
            Constants().STOREVALUE(value: self.user_id, keyname: USER_EMAIL_ID)
            Constants().STOREVALUE(value: self.vehicle_id, keyname: USER_CAR_ID)
            if company_id != "0" && company_id != "1" || company_id == ""{
                userDefaults.set(false, forKey: IS_COMPANY_DRIVER)
            }else {
                userDefaults.set(true, forKey: IS_COMPANY_DRIVER)
            }
        
//            Constants().STOREVALUE(value: "1", keyname: IS_COMPANY_DRIVER)
    

    }
    func makeCurrencySymbols(encodedString : String) -> String
    {
        let encodedData = encodedString.stringByDecodingHTMLEntities
        return encodedData
    }
}

class CarDetailModel : NSObject
{
    //MARK Properties
    var base_fare : String = ""
    var capacity : String = ""
    var car_name : String = ""
    var car_description : String = ""
    var car_id : String = ""
    var min_fare : String = ""
    var per_km : String = ""
    var per_min : String = ""
    var status : String = ""

    //MARK: Inits
    func initCarDetails(responseDict: NSDictionary) -> Any
    {
        let json = responseDict as! JSON
    
        base_fare = json.string("base_fare")
        capacity = json.string("capacity")
        car_name = json.string("car_name")
        car_description = json.string("description")
        car_id = json.string("id")
        min_fare = json.string("min_fare")
        per_km = json.string("per_km")
        per_min = json.string("per_min")
        status = json.string("status")
        return self
    }

}
