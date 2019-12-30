/**
* UberCreateUrl.swift
*
* @package Gofer
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit

class UberCreateUrl: NSObject
{
    let strDeviceType = "1"
    let strDeviceToken = YSSupport.getDeviceToken()
    let strUserType = "Driver"
    
    func serializeURL(params : NSDictionary , methodName : NSString) -> NSString
    {
        if methodName.isEqual(to: METHOD_PHONENO_VALIDATION)
        {
            return self.createValidateMobileNoUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_LOGIN)
        {
            return self.createLoginUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_SIGNUP) || methodName.isEqual(to: METHOD_SOCIAL_SIGNUP)
        {
            return self.createSignUpUrl(params: params, methodName: methodName)
        }
        else if methodName.isEqual(to: METHOD_UPDATE_PASSWORD)
        {
            return self.createUpdatePasswordUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_OTP)
        {
            return self.createOtpUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_LANGUAGE)
        {
            return self.createLanguageUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_UPDATE_VEHICLE_INFO)
        {
            return self.createUpdateVehicleInfoUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_WEEKLY_EARNINGS)
        {
            return self.createWeeklyEarningUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_CHANGE_DRIVER_STATUS)
        {
            return self.createChangeDriverStatusUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_GET_RIDER_PROFILE)
        {
            return self.createGetRiderProfileUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_DRIVER_NOT_ACCEPT)
        {
            return self.createDriverNotAcceptTripUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_UPDATING_DRIVER_LOCATION)
        {
            return self.createUpdateDriverLocationUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_ARRIVE_NOW)
        {
            return self.createArriveNowUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_BEGIN_TRIP)
        {
            return self.createBeginTripUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_END_TRIP)
        {
            return self.createEndTripUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_CASH_COLLECT)
        {
            return self.createCashCollectUrl(params: params)
        }
            
        else if methodName.isEqual(to: METHOD_CURRENCY_LIST)
        {
            return self.createCurrencyListUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_CHANGE_CURRENCY)
        {
            return self.createUpdateCurrencyListUrl(params: params)
        }   
        else if methodName.isEqual(to: METHOD_CANCEL_TRIP)
        {
            return self.createCancelTripUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_WEEKLY_EARNINGS)
        {
            return self.createWeeklyEarningsUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_GETTING_TRIP_INFO)
        {
            return self.createGettingTripsInfoUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_RATING)
        {
            return self.createRatingUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_RIDER_FEEDBACK)
        {
            return self.createRiderFeedBackUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_GIVE_RATING)
        {
            return self.createGiveRatingUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_PAY_STATEMENT)
        {
            return self.createPayStatementUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_VIEW_PROFILE_INFO)
        {
            return self.createViewProfileInfoUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_UPDATE_PROFILE_INFO)
        {
            return self.createUpdateProfileInfoUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_CHECK_DRIVER_STATUS)
        {
            return self.createCheckStatusUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_UPDATE_DEVICE_TOKEN)
        {
            return self.createUpdateDeviceTokenToServerUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_UPDATE_PAYPAL_EMAIL)
        {
            return self.createUpdatePayPalEmailUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_LOGOUT)
        {
            return self.createLogoutUrl(params: params)
        }
        return ""
    }
    
    // Getting Phone Dial Code
    func getDialCode() -> String
    {
        let strDialCode = String(format:"%@",Constants().GETVALUE(keyname: USER_DIAL_CODE))
        return strDialCode.replacingOccurrences(of: "+", with: "")
    }
    
    //MARK: VALIDATE MOBILE NUMBER
    func createValidateMobileNoUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        if let countryCode = params["country_code"] as? String{
            pairs.add(String(format:"country_code=%@",countryCode))
        }else{
            pairs.add(String(format:"country_code=%@",getDialCode()))
        }
        pairs.add(String(format:"mobile_number=%@",params["mobile_number"]  as! NSString))
        if params["forgotpassword"] != nil
        {
            pairs.add(String(format:"forgotpassword=%@","1"))
        }
        
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"language=%@",appDelegate.language))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_PHONENO_VALIDATION,query) as NSString)
    }

    //MARK: LOGIN
    func createLoginUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        if let countryCode = params["country_code"] as? String{
            pairs.add(String(format:"country_code=%@",countryCode))
        }else{
            pairs.add(String(format:"country_code=%@",getDialCode()))
        }
        pairs.add(String(format:"mobile_number=%@",params["mobile_number"]  as! NSString))
        pairs.add(String(format:"password=%@",YSSupport.escapedValue((params["password"]  as! NSString) as String)))
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"device_id=%@",strDeviceToken!))
        pairs.add(String(format:"device_type=%@",strDeviceType))
        pairs.add(String(format: "language=%@", appDelegate.language))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_LOGIN,query) as NSString)
    }
    
    //MARK: UPDATE NEW PASSWORD
    func createUpdatePasswordUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        if let countryCode = params["country_code"] as? String{
            pairs.add(String(format:"country_code=%@",countryCode))
        }else{
            pairs.add(String(format:"country_code=%@",getDialCode()))
        }
        pairs.add(String(format:"mobile_number=%@",params["mobile_number"]  as! NSString))
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"password=%@",YSSupport.escapedValue((params["password"]  as! NSString) as String)))
        pairs.add(String(format:"device_id=%@",strDeviceToken!))
        pairs.add(String(format:"device_type=%@",strDeviceType))
        pairs.add(String(format:"language=%@",appDelegate.language))
        let query = pairs.componentsJoined(by: "&")
        return ((String(format:"%@%@?%@",iApp.APIBaseUrl,API_UPDATE_PASSWORD,query) as NSString).replacingOccurrences(of: " ", with: "%20") as NSString)
    }
    
    //MARK: SIGNUP PAGE - NORMAL
    func createSignUpUrl(params : NSDictionary, methodName: NSString) -> NSString
    {
        let pairs : NSMutableArray =  []
        if let countryCode = params["country_code"] as? String{
            pairs.add(String(format:"country_code=%@",countryCode))
        }else{
            pairs.add(String(format:"country_code=%@",getDialCode()))
        }
        pairs.add(String(format:"mobile_number=%@",params["mobile_number"]  as! NSString))
        pairs.add(String(format:"first_name=%@",YSSupport.escapedValue((params["first_name"]  as! NSString) as String)))
        
        pairs.add(String(format:"last_name=%@",YSSupport.escapedValue((params["last_name"]  as! NSString) as String)))
        pairs.add(String(format:"user_type=%@",strUserType))
        
        pairs.add(String(format:"password=%@",YSSupport.escapedValue((params["password"]  as! NSString) as String)))
        
        pairs.add(String(format:"city=%@",YSSupport.escapedValue((params["city"]  as! NSString) as String)))
        pairs.add(String(format:"device_id=%@",strDeviceToken!))
        pairs.add(String(format:"device_type=%@",strDeviceType))

        if params["email_id"] != nil
        {
            pairs.add(String(format:"email_id=%@",params["email_id"]  as! NSString))
        }

        if params["google_id"] != nil
        {
//            pairs.add(String(format:"google_id=%@",params["google_id"]  as! NSString))
//            pairs.add("fb_id=")
            
        }
        else if params["fb_id"] != nil
        {
//            pairs.add(String(format:"fb_id=%@",params["fb_id"]  as! NSString))
//            pairs.add("google_id=")
        }
        
        if params["user_image"] != nil
        {
            let strProfileUrl = YSSupport.escapedValue((params["user_image"]  as! NSString) as String)
            pairs.add(String(format:"user_image=%@",strProfileUrl!))
        }
        else
        {
        }
        
        if methodName.isEqual(to: METHOD_SOCIAL_SIGNUP)
        {
            pairs.add("new_user=1")
        }
        
        let query = pairs.componentsJoined(by: "&")
        return ((String(format:"%@%@?%@",iApp.APIBaseUrl,API_SIGNUP,query) as NSString).replacingOccurrences(of: " ", with: "%20") as NSString)
    }
    //MARK: LANGUAGE
    func createLanguageUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"language=%@",params["language"]  as! NSString))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_LANGUAGE,query) as NSString)
    }
    
    //MARK: OTP
    func createOtpUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        if let countryCode = params["country_code"] as? String{
            pairs.add(String(format:"country_code=%@",countryCode))
        }else{
            pairs.add(String(format:"country_code=%@",getDialCode()))
        }
        pairs.add(String(format:"mobile_number=%@",params["mobile_number"]  as! NSString))
        pairs.add(String(format:"otp=%@",params["otp"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_OTP,query) as NSString)
    }
    
    //MARK: UPDATE_VEHICLE_INFO
    func createUpdateVehicleInfoUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"vehicle_id=%@",params["vehicle_id"]  as! NSString))
        pairs.add(String(format:"vehicle_name=%@",YSSupport.escapedValue((params["vehicle_name"]  as! NSString) as String)))
        pairs.add(String(format:"vehicle_type=%@",YSSupport.escapedValue((params["vehicle_type"]  as! NSString) as String)))
     pairs.add(String(format:"vehicle_number=%@",YSSupport.escapedValue((params["vehicle_number"]  as! NSString) as String)))
         pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_UPDATE_VEHICLE_INFO,query) as NSString)
    }

    //MARK: API_WEEKLY_EARNINGS
    func createWeeklyEarningUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        
        pairs.add(String(format:"start_date=%@",params["start_date"]  as! NSString))
        pairs.add(String(format:"end_date=%@",params["end_date"]  as! NSString))
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_WEEKLY_EARNINGS,query) as NSString)
    }
    
    //MARK: METHOD_CHANGE_DRIVER_STATUS
    func createChangeDriverStatusUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"status=%@",params["status"]  as! NSString))
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"request_id=%@",params["request_id"]  as! NSString))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_CHANGE_DRIVER_STATUS,query) as NSString)
    }
    
    //MARK: METHOD_GET_RIDER_PROFILE
    func createGetRiderProfileUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        
        pairs.add(String(format:"status=%@",params["status"]  as! NSString))
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"trip_id=%@",params["trip_id"]  as! NSString))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_GET_RIDER_PROFILE,query) as NSString)
    }
    
    //MARK: METHOD_DRIVER_NOT_ACCEPT
    func createDriverNotAcceptTripUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"status=%@",params["status"]  as! NSString))
        pairs.add(String(format:"request_id=%@",params["request_id"]  as! NSString))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_DRIVER_NOT_ACCEPT,query) as NSString)
    }
    
    //MARK: FREQUENT CALL DRIVER LOCATION DETAILS
    func createUpdateDriverLocationUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"latitude=%@",params["latitude"]  as! NSString))
        pairs.add(String(format:"longitude=%@",params["longitude"]  as! NSString))
        pairs.add(String(format:"car_id=%@",params["car_id"]  as! NSString))
        if params["trip_id"] != nil
        {
            pairs.add(String(format:"trip_id=%@",params["trip_id"]  as! NSString))
        }
        if params["total_km"] != nil
        {
            pairs.add(String(format:"total_km=%@",params["total_km"]  as! NSString))
        }
        pairs.add(String(format:"status=%@",params["status"]  as! NSString))
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_UPDATING_DRIVER_LOCATION,query) as NSString)
    }
    
    //MARK: ARRIVE NOW
    func createArriveNowUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"trip_id=%@",params["trip_id"]  as! NSString))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_ARRIVE_NOW,query) as NSString)
    }

    //MARK: BEGIN TRIP
    func createBeginTripUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"trip_id=%@",params["trip_id"]  as! NSString))
        pairs.add(String(format:"begin_latitude=%@",params["begin_latitude"]  as! NSString))
        pairs.add(String(format:"begin_longitude=%@",params["begin_longitude"]  as! NSString))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_BEGIN_TRIP,query) as NSString)
    }
    
    //MARK: CASH COLLECT
    func createCashCollectUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"trip_id=%@",params["trip_id"]  as! NSString))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_CASH_COLLECT,query) as NSString)
    }
    //MARK: CURRENCY LIST
    func createCurrencyListUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_CURRENCY_LIST,query) as NSString)
    }
    //MARK: UPDATE CURRENCY LIST
    func createUpdateCurrencyListUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"currency_code=%@",params["currency_code"]  as! NSString))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_CHANGE_CURRENCY,query) as NSString)
    }
    //MARK: END TRIP
    func createEndTripUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"trip_id=%@",params["trip_id"]  as! NSString))
        pairs.add(String(format:"end_latitude=%@",params["end_latitude"]  as! NSString))
        pairs.add(String(format:"end_longitude=%@",params["end_longitude"]  as! NSString))
        pairs.add(String(format:"image=%@",params["image"]  as! NSString))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_END_TRIP,query) as NSString)
    }

    //MARK: CANCEL TRIP
    func createCancelTripUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"trip_id=%@",params["trip_id"]  as! NSString))
    
    pairs.add(String(format:"cancel_reason=%@",YSSupport.escapedValue((params["cancel_reason"]  as! NSString) as String)))
    pairs.add(String(format:"cancel_comments=%@",YSSupport.escapedValue((params["cancel_comments"]  as! NSString) as String)))
        
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_CANCEL_TRIP,query) as NSString)
    }

    //MARK: WEEKLY_EARNINGS
    func createWeeklyEarningsUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"start_date=%@",params["start_date"]  as! NSString))
        pairs.add(String(format:"end_date=%@",params["end_date"]  as! NSString))
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_WEEKLY_EARNINGS,query) as NSString)
    }
    
    //MARK: RATING
    func createRatingUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        pairs.add(String(format:"user_type=%@",params["user_type"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_RATING,query) as NSString)
    }

    //MARK: RIDER_FEEDBACK
    func createRiderFeedBackUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_RIDER_FEEDBACK,query) as NSString)
    }
    
    //MARK: GIVE RATING
    func createGiveRatingUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"trip_id=%@",params["trip_id"]  as! NSString))
        pairs.add(String(format:"rating=%@",params["rating"]  as! NSString))
        pairs.add(String(format:"user_type=%@",params["user_type"]  as! NSString))
    pairs.add(String(format:"rating_comments=%@",YSSupport.escapedValue((params["rating_comments"]  as! NSString) as String)))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_GIVE_RATING,query) as NSString)
    }
    
    //MARK: METHOD_PAY_STATEMENT
    func createPayStatementUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_PAY_STATEMENT,query) as NSString)
    }
    
    //MARK: EDIT PROFILE PAGE
    func createViewProfileInfoUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_VIEW_PROFILE_INFO,query) as NSString)
    }

    
    //MARK: EDIT PROFILE PAGE
    func createUpdateProfileInfoUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"first_name=%@",YSSupport.escapedValue((params["first_name"]  as! NSString) as String)))
        pairs.add(String(format:"last_name=%@",YSSupport.escapedValue((params["last_name"]  as! NSString) as String)))
        pairs.add(String(format:"email_id=%@",YSSupport.escapedValue((params["email_id"]  as! NSString) as String)))
        pairs.add(String(format:"mobile_number=%@",YSSupport.escapedValue((params["mobile_number"]  as! NSString) as String)))
        pairs.add(String(format:"address_line1=%@",YSSupport.escapedValue((params["address_line1"]  as! NSString) as String)))
        pairs.add(String(format:"address_line2=%@",YSSupport.escapedValue((params["address_line2"]  as! NSString) as String)))
        
    
        pairs.add(String(format:"city=%@",YSSupport.escapedValue((params["city"]  as! NSString) as String)))
        pairs.add(String(format:"postal_code=%@",YSSupport.escapedValue((params["postal_code"]  as! NSString) as String)))
        
        pairs.add(String(format:"state=%@",YSSupport.escapedValue((params["state"]  as! NSString) as String)))
        if let countryCode = params["country_code"] as? String{
            pairs.add(String(format:"country_code=%@",countryCode))
        }else{
            pairs.add(String(format:"country_code=%@",getDialCode()))
        }
        if params["profile_image"] != nil
        {
            pairs.add(String(format:"profile_image=%@",params["profile_image"]  as! NSString))
        }
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_UPDATE_PROFILE_INFO,query) as NSString)
    }
    
    //MARK: METHOD_CHECK_DRIVER_STATUS
    func createCheckStatusUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_CHECK_DRIVER_STATUS,query) as NSString)
    }
    
    //MARK: GETTING TRIP INFO
    func createGettingTripsInfoUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_GETTING_TRIP_INFO,query) as NSString)
    }
    
    //MARK: METHOD_UPDATE_DEVICE_TOKEN TO SERVER
    func createUpdateDeviceTokenToServerUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"device_id=%@",params["device_id"]  as! NSString))
        pairs.add(String(format:"device_type=%@",strDeviceType))
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_UPDATE_DEVICE_TOKEN,query) as NSString)
    }
    
    //MARK: METHOD_UPDATE_PAYPAL_EMAIL
    func createUpdatePayPalEmailUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"email_id=%@",params["email_id"]  as! NSString))
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_UPDATE_PAYPAL_EMAIL,query) as NSString)
    }

    //MARK: LOGOUT
    func createLogoutUrl(params : NSDictionary) -> NSString
    {
        let pairs : NSMutableArray =  []
        pairs.add(String(format:"user_type=%@",strUserType))
        pairs.add(String(format:"token=%@",params["token"]  as! NSString))
        let query = pairs.componentsJoined(by: "&")
        return (String(format:"%@%@?%@",iApp.APIBaseUrl,API_LOGOUT,query) as NSString)
    }
    
}
