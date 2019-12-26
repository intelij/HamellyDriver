/**
* UberSeparateParam.swift
*
* @package Gofer
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit

class UberSeparateParam: NSObject {

    func separate(params : NSDictionary , methodName : NSString) -> Any
    {
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate

        if methodName.isEqual(to: METHOD_PHONENO_VALIDATION)
        {
            return self.separateParamForPhoneNumberValidation(params: params)
        }
        else if methodName.isEqual(to: METHOD_LOGIN)
        {
            return self.separateParamForLogin(params: params)
        }
        else if methodName.isEqual(to: METHOD_SIGNUP) || methodName.isEqual(to: METHOD_SOCIAL_SIGNUP)
        {
            return self.separateParamForLogin(params: params)
        }
        else if methodName.isEqual(to: METHOD_CHECK_SOCIAL_ID)
        {
            return self.separateParamForLogin(params: params)
        }
        else if methodName.isEqual(to: METHOD_OTP)
        {
            return self.separateParamForGeneralModel(params: params)
        }
        else if methodName.isEqual(to: METHOD_LANGUAGE)
        {
            return self.separateParamForLanguageModel(params: params)
        }
        else if methodName.isEqual(to: METHOD_UPDATE_VEHICLE_INFO)
        {
            return self.separateParamForGeneralModel(params: params)
        }
        else if methodName.isEqual(to: METHOD_UPDATE_PASSWORD)
        {
            return self.separateParamForForgotPassword(params: params)
        }
        else if methodName.isEqual(to: METHOD_SEARCH_NEARESTCARS)
        {
            return self.separateParamForSearchNearestCars(params: params)
        }
        else if methodName.isEqual(to: METHOD_CHANGE_DRIVER_STATUS) || methodName.isEqual(to: METHOD_DRIVER_NOT_ACCEPT)
        {
            return self.separateParamForGettingRiderDetails(params: params, methodName : methodName)
        }
        else if methodName.isEqual(to: METHOD_GET_RIDER_PROFILE)
        {
            return self.separateParamForGettingRiderDetails(params: params, methodName : METHOD_CHANGE_DRIVER_STATUS as NSString)
        }
        else if methodName.isEqual(to: METHOD_UPDATING_DRIVER_LOCATION)
        {
            return self.separateParamForUpdateDriverLocation(params: params)
        }
        else if methodName.isEqual(to: METHOD_ARRIVE_NOW)
        {
            return self.separateParamForGeneralModel(params: params)
        }
        else if methodName.isEqual(to: METHOD_BEGIN_TRIP)
        {
            return self.separateParamForGeneralModel(params: params)
        }
        else if methodName.isEqual(to: METHOD_END_TRIP)
        {
            return self.separateParamForEndTrip(params: params)
        }
        else if methodName.isEqual(to: METHOD_CASH_COLLECT)
        {
            return self.separateParamForEndTrip(params: params)
        }
        else if methodName.isEqual(to: METHOD_CURRENCY_LIST)
        {
            return self.separateParamForCurrencyList(params: params)
        }
        else if methodName.isEqual(to: METHOD_CHANGE_CURRENCY)
        {
            return self.separateParamForGeneralModel(params: params)
        }
        else if methodName.isEqual(to: METHOD_CANCEL_TRIP)
        {
            return self.separateParamForGeneralModel(params: params)
        }
        else if methodName.isEqual(to: METHOD_GIVE_RATING)
        {
            return self.separateParamForGiveRating(params: params, isFromPayment: false)
        }
        else if methodName.isEqual(to: METHOD_PAY_STATEMENT)
        {
            return self.separateParamForPayStatement(params: params)
        }
        else if methodName.isEqual(to: METHOD_WEEKLY_EARNINGS)
        {
            return self.separateParamForWeeklyEarnings(params: params)
        }
        else if methodName.isEqual(to: METHOD_GETTING_TRIP_INFO)
        {
            return self.separateParamForGettingTripsUrl(params: params)
        }
        else if methodName.isEqual(to: METHOD_UPDATE_DEVICE_TOKEN)
        {
            return self.separateParamForGeneralModel(params: params)
        }
        else if methodName.isEqual(to: METHOD_RATING)
        {
            return self.separateParamForRating(params: params)
        }
        else if methodName.isEqual(to: METHOD_RIDER_FEEDBACK)
        {
            return self.separateParamForRiderFeedBack(params: params)
        }
        else if methodName.isEqual(to: METHOD_VIEW_PROFILE_INFO)
        {
            return self.separateParamForViewProfile(params: params)
        }
        else if methodName.isEqual(to: METHOD_UPDATE_PROFILE_INFO)
        {
            return self.separateParamForGeneralModel(params: params)
        }
        else if methodName.isEqual(to: METHOD_CHECK_DRIVER_STATUS)
        {
            return self.separateParamForCheckDriverStatus(params: params)
        }
        else if methodName.isEqual(to: METHOD_UPDATE_PAYPAL_EMAIL)
        {
            return self.separateParamForGeneralModel(params: params)
        }
        else if methodName.isEqual(to: METHOD_LOGOUT)
        {
            return self.separateParamForGeneralModel(params: params)
        }

        return ""
    }
    //MARK: LANGUAGE
    func separateParamForLanguageModel(params : NSDictionary) -> Any
    {
        let generalModel = GeneralModel()
        if params["error"] != nil
        {
            generalModel.status_message = params["error"] as? String ?? String()
            generalModel.status_code = "0"
        }
        else
        {
            generalModel.status_message = params["status_message"] as? String ?? String()
            generalModel.status_code = params["status_code"] as? String ?? String()
        }
        return generalModel
    
    }
    //MARK: GENERAL MODEL
    func separateParamForGeneralModel(params : NSDictionary) -> Any
    {
        let generalModel = GeneralModel()
        if params["error"] != nil
        {
            generalModel.status_message = params["error"] as? String ?? String()
            generalModel.status_code = "0"
        }
        else
        {
            generalModel.status_message = params["status_message"] as? String ?? String()
            generalModel.status_code = params["status_code"] as? String ?? String()
            if params["trip_id"] != nil
            {
                generalModel.trip_id = UberSupport().checkParamTypes(params: params, keys:"trip_id") as String
            }
        }
        return generalModel
    }
    
    
    //MARK: Mobile Number Validation
    func separateParamForPhoneNumberValidation(params : NSDictionary) -> Any
    {
        let generalModel = GeneralModel()
        if params["error"] != nil
        {
            generalModel.status_message = params["error"] as? String ?? String()
            generalModel.status_code = "0"
        }
        else
        {
            generalModel.status_message = params["status_message"] as? String ?? String()
            generalModel.status_code = params["status_code"] as? String ?? String()
            
            if params["otp"] != nil
            {
                generalModel.otp_code = UberSupport().checkParamTypes(params: params, keys:"otp") as String
            }
        }
        
        return generalModel
    }
    
    //MARK: METHOD_CHECK_DRIVER_STATUS
    func separateParamForCheckDriverStatus(params : NSDictionary) -> Any
    {
        let generalModel = GeneralModel()
        if params["error"] != nil
        {
            generalModel.status_message = params["error"] as? String ?? String()
            generalModel.status_code = "0"
        }
        else
        {
            generalModel.status_message = params["status_message"] as? String ?? String()
            generalModel.status_code = params["status_code"] as? String ?? String()
            
            if params["driver_status"] != nil
            {
                generalModel.driver_status = UberSupport().checkParamTypes(params: params, keys:"driver_status") as String
            }
        }
        
        return generalModel
    }
    
    func makeCurrencySymbols(encodedString : String) -> String
    {
        let encodedData = encodedString.stringByDecodingHTMLEntities
        return encodedData
    }

    
    //MARK: Login / SignUp - Separate Params
    func separateParamForLogin(params : NSDictionary) -> Any
    {
        let loginData = LoginModel()
        loginData.status_message = params["status_message"] as? String ?? String()
        loginData.status_code = params["status_code"] as? String ?? String()
        var carType = ""
        var carId = ""

        if loginData.status_code == "1"
        {
            if loginData.status_code == "1"
            {
                loginData.car_details = NSMutableArray()
                
                if params["car_detais"] != nil
                {
                    let arrData = params["car_detais"] as? NSArray ?? NSArray()
                    if arrData.count > 0
                    {

                        for i in 0 ..< arrData.count
                        {
                            loginData.car_details.addObjects(from: ([CarDetailModel().initCarDetails(responseDict: arrData[i] as! NSDictionary)]))
                        }
                    }
                }
            }

            loginData.access_token = params["access_token"] as? String ?? String()
            loginData.first_name = UberSupport().checkParamTypes(params: params, keys:"first_name") as String
            loginData.last_name = UberSupport().checkParamTypes(params: params, keys:"last_name") as String
            loginData.mobile_number = UberSupport().checkParamTypes(params: params, keys:"mobile_number") as String
            loginData.email_id = UberSupport().checkParamTypes(params: params, keys:"email_id") as String
            loginData.home_location_name = UberSupport().checkParamTypes(params: params, keys:"home_location_name") as String
            loginData.work_location_name = UberSupport().checkParamTypes(params: params, keys:"work_location_name") as String
            loginData.user_status = UberSupport().checkParamTypes(params: params, keys:"user_status") as String

            loginData.user_name = String(format:"%@ %@",loginData.first_name , loginData.last_name) as String

            loginData.user_thumb_image = UberSupport().checkParamTypes(params: params, keys:"user_thumb_image") as String
            loginData.email_id = UberSupport().checkParamTypes(params: params, keys:"email_id") as String
            loginData.user_id = UberSupport().checkParamTypes(params: params, keys:"user_id") as String
            loginData.vehicle_id = UberSupport().checkParamTypes(params: params, keys:"vehicle_id") as String

            loginData.insurance = UberSupport().checkParamTypes(params: params, keys:"insurance") as String
            loginData.license_back = UberSupport().checkParamTypes(params: params, keys:"license_back") as String
            loginData.license_front = UberSupport().checkParamTypes(params: params, keys:"license_front") as String
            loginData.permit = UberSupport().checkParamTypes(params: params, keys:"permit") as String
            loginData.rc = UberSupport().checkParamTypes(params: params, keys:"rc") as String
            loginData.vehicle_id = UberSupport().checkParamTypes(params: params, keys:"vehicle_id") as String
            loginData.vehicle_number = UberSupport().checkParamTypes(params: params, keys:"vehicle_number") as String
            loginData.vehicle_type = UberSupport().checkParamTypes(params: params, keys:"vehicle_type") as String
            loginData.paypal_email_id = UberSupport().checkParamTypes(params: params, keys:"payout_id") as String

            let currency = self.makeCurrencySymbols(encodedString: UberSupport().checkParamTypes(params: params, keys:"currency_symbol") as String)
            Constants().STOREVALUE(value: currency, keyname: USER_CURRENCY_SYMBOL_ORG)
            Constants().STOREVALUE(value: UberSupport().checkParamTypes(params: params, keys:"currency_code") as String, keyname: USER_CURRENCY_ORG)

            Constants().STOREVALUE(value: "Offline", keyname: USER_ONLINE_STATUS) // its used for driver online/offline switch
            Constants().STOREVALUE(value: "Offline", keyname: TRIP_STATUS)

            let userDefaults = UserDefaults.standard
            for i in 0 ..< loginData.car_details.count
            {
                let model = loginData.car_details[i] as! CarDetailModel
                if i == 0
                {
                    carType = model.car_name
                    carId = model.car_id
                }
                else if i == loginData.car_details.count-1
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
           
            loginData.company_id = params["company_id"] as? String ?? "0"
            loginData.company_name = params["company_name"] as! String
            if loginData.company_id != "0" && loginData.company_id != "1"{
                userDefaults.set(true, forKey: IS_COMPANY_DRIVER)
            }else {
                userDefaults.set(false, forKey: IS_COMPANY_DRIVER)
            }
            userDefaults.set(carType, forKey: USER_CAR_TYPE)
            userDefaults.set(carId, forKey: USER_CAR_IDS)

//            Constants().STOREVALUE(value: loginData.paypal_email_id, keyname: USER_PAYPAL_EMAIL_ID)
            DriverStatus.getStatus(forString: loginData.user_status).storeInPreference()
            Constants().STOREVALUE(value: loginData.user_status, keyname: USER_STATUS)
            Constants().STOREVALUE(value: loginData.access_token, keyname: USER_ACCESS_TOKEN)
            Constants().STOREVALUE(value: loginData.user_name, keyname: USER_FULL_NAME)
            Constants().STOREVALUE(value: loginData.first_name, keyname: USER_FIRST_NAME)
            Constants().STOREVALUE(value: loginData.last_name, keyname: USER_LAST_NAME)
            Constants().STOREVALUE(value: loginData.user_thumb_image, keyname: USER_IMAGE_THUMB)
            Constants().STOREVALUE(value: loginData.user_id, keyname: USER_ID)
            Constants().STOREVALUE(value: loginData.user_id, keyname: USER_EMAIL_ID)
            Constants().STOREVALUE(value: loginData.vehicle_id, keyname: USER_CAR_ID)
            
        }
        return loginData
    }
    
    //MARK: Update new Password (Forgot password)
    func separateParamForForgotPassword(params : NSDictionary) -> Any
    {
        return separateParamForLogin(params: params)
    }
    
    
    //MARK: Searching Nearest Cars
    func separateParamForSearchNearestCars(params : NSDictionary) -> Any
    {
        let generalModel = GeneralModel()
        if params["error"] != nil
        {
            generalModel.status_message = params["error"] as? String ?? String()
            generalModel.status_code = "0"
        }
        else
        {
            generalModel.status_message = params["status_message"] as? String ?? String()
            generalModel.status_code = params["status_code"] as? String ?? String()
            
            if generalModel.status_code == "1"
            {
                generalModel.arrTemp1 = NSMutableArray()
                
                if params["cardata"] != nil
                {
                    let arrData = params["cardata"] as? NSArray ?? NSArray()
                    for i in 0 ..< arrData.count
                    {
                        generalModel.arrTemp1.addObjects(from: ([SearchCarsModel().initCarDetails(responseDict: arrData[i] as! NSDictionary)]))
                    }
                }
            }
        }
        return generalModel
    }
    
    
    //MARK: Sending Request To Car
    func separateParamForSendingRequestToCar(params : NSDictionary) -> Any
    {
        return separateParamForGeneralModel(params: params)
    }

    
    //MARK: Update Driver Location
    func separateParamForUpdateDriverLocation(params : NSDictionary) -> Any
    {
        return separateParamForGeneralModel(params: params)
    }

    
    //MARK: Getting Driver Location
    func separateParamForGettingDriverLocation(params : NSDictionary) -> Any
    {
        let driveLocData = DriverLocationModel()
        driveLocData.status_message = params["status_message"] as? String ?? String()
        driveLocData.status_code = params["status_code"] as? String ?? String()

        if driveLocData.status_code == "1"
        {
            driveLocData.arrival_time = params["arrival_time"] as? String ?? String()
            driveLocData.driver_location_latitude = params["driver_location_latitude"] as? String ?? String()
            driveLocData.driver_location_longitude = params["driver_location_longitude"] as? String ?? String()
        }
        return driveLocData
    }
    
    
    //MARK: Getting Driver Details
    func separateParamForGettingRiderDetails(params : NSDictionary, methodName: NSString) -> Any
    {
        let driveDetailData = RiderDetailModel()
        if params["error"] != nil
        {
            driveDetailData.status_message = params["error"] as? String ?? String()
            driveDetailData.status_code = "0"
        }
        else
        {
            driveDetailData.status_message = params["status_message"] as? String ?? String()
            driveDetailData.status_code = params["status_code"] as? String ?? String()

            if driveDetailData.status_code == "1" && methodName.isEqual(to: METHOD_CHANGE_DRIVER_STATUS)  // while accept request
            {
                
                driveDetailData.rider_thumb_image = params["rider_thumb_image"] as? String ?? String()
                driveDetailData.rider_name = params["rider_name"] as? String ?? String()
                driveDetailData.rating_value = params["rating_value"] as? String ?? String()
                driveDetailData.car_type = params["car_type"] as? String ?? String()
                driveDetailData.pickup_location = params["pickup_location"] as? String ?? String()
                driveDetailData.drop_location = params["drop_location"] as? String ?? String()
                driveDetailData.pickup_latitude = params["pickup_latitude"] as? String ?? String()
                driveDetailData.pickup_longitude = params["pickup_longitude"] as? String ?? String()
                driveDetailData.drop_latitude = params["drop_latitude"] as? String ?? String()
                driveDetailData.drop_longitude = params["drop_longitude"] as? String ?? String()
                driveDetailData.mobile_number = params["mobile_number"] as? String ?? String()
                driveDetailData.payment_method = params["payment_method"] as? String ?? String()
                driveDetailData.car_active_image = params["car_active_image"] as? String ?? String()
                
                driveDetailData.trip_id = UberSupport().checkParamTypes(params: params, keys:"trip_id") as String
                driveDetailData.trip_status = UberSupport().checkParamTypes(params: params, keys:"trip_status") as String
                
                if params["payment_details"] != nil
                {
                    driveDetailData.payment_detail = self.separateParamForGiveRating(params: params["payment_details"] as! NSDictionary, isFromPayment: true) as! EndTripModel
                }
                if let rating = Double(driveDetailData.rating_value),!rating.isZero{
                    UserDefaults.standard.set(rating.description, forKey: TRIP_RIDER_RATING)
                }
                if let json = params as? JSON{
                    driveDetailData.rider_id = json.string("rider_id")
                }
            }
        }
        return driveDetailData
    }
    
    //MARK: End Trip , cash collect
    func separateParamForEndTrip(params : NSDictionary) -> Any
    {
        return separateParamForGeneralModel(params: params)
    }
    func separateParamForCurrencyList(params : NSDictionary) -> Any
    {
        let generalModel = GeneralModel()
        if params["error"] != nil
        {
            generalModel.status_message = params["error"] as? String ?? String()
            generalModel.status_code = "0"
        }
        else
        {
            generalModel.status_message = params["status_message"] as? String ?? String()
            generalModel.status_code = params["status_code"] as? String ?? String()
            generalModel.arrTemp1 = NSMutableArray()
            
            if generalModel.status_code == "1"
            {
                let arrData = params["currency_list"] as? NSArray ?? NSArray()
                
                for i in 0 ..< arrData.count
                {
                    generalModel.arrTemp1.addObjects(from: ([CurrencyModel().initiateCurrencyData(responseDict: arrData[i] as! NSDictionary)]))
                }
            }
        }
        return generalModel
    }
    
    //MARK: Give Rating
    func separateParamForGiveRating(params : NSDictionary, isFromPayment: Bool) -> Any
    {
        let tripData = EndTripModel()
        tripData.status_message = (params["status_message"] != nil) ? params["status_message"] as? String ?? String() : ""
        tripData.status_code = (params["status_code"] != nil) ? params["status_code"] as? String ?? String() : ""
        if tripData.status_code == "1" || isFromPayment
        {
            tripData.access_fee = UberSupport().checkParamTypes(params: params, keys:"access_fee") as String
            tripData.base_fare = UberSupport().checkParamTypes(params: params, keys:"base_fare") as String
            tripData.drop_location = UberSupport().checkParamTypes(params: params, keys:"drop_location") as String
            tripData.pickup_location = UberSupport().checkParamTypes(params: params, keys:"pickup_location") as String
            tripData.total_fare = UberSupport().checkParamTypes(params: params, keys:"total_fare") as String
            tripData.total_km = UberSupport().checkParamTypes(params: params, keys:"total_km") as String
            tripData.total_km_fare = UberSupport().checkParamTypes(params: params, keys:"total_km_fare") as String
            tripData.total_time = UberSupport().checkParamTypes(params: params, keys:"total_time") as String
            tripData.total_time_fare = UberSupport().checkParamTypes(params: params, keys:"total_time_fare") as String
            tripData.driver_payout = UberSupport().checkParamTypes(params: params, keys:"driver_payout") as String
            tripData.payment_method = UberSupport().checkParamTypes(params: params, keys: "payment_method")
            tripData.payment_status = UberSupport().checkParamTypes(params: params, keys:"payment_status") as String
            
            if params["payment_details"] != nil
            {
                let arrData = params["payment_details"] as? NSArray ?? NSArray()
                if arrData.count > 0
                {
                    tripData.arrTemp3 = NSMutableArray()
                    
                    for i in 0 ..< arrData.count
                    {
                        tripData.arrTemp3.addObjects(from: ([CashModel().getCashData(responseDict: arrData[i] as! NSDictionary)]))
                        
                    }
                }
            }
            if params["invoice"] != nil
            {
                let arrData1 = params["invoice"] as? NSArray ?? NSArray()
                if arrData1.count > 0
                {
                    tripData.arrTemp2 = NSMutableArray()
                    
                    for i in 0 ..< arrData1.count
                    {
                        tripData.arrTemp2.addObjects(from: ([CashModel().getInvoiceData(responseDict: arrData1[i] as! NSDictionary)]))
                        
                    }
                }
            }
        }
        return tripData
    }
    
    
    //MARK: Getting Weekly PayStatement
    func separateParamForPayStatement(params : NSDictionary) -> Any
    {
        let gModel = GeneralModel()
        gModel.status_message = params["status_message"] as? String ?? String()
        gModel.status_code = params["status_code"] as? String ?? String()
        
        if gModel.status_code == "1"
        {
            if params["pay_statement"] != nil
            {
                let arrData = params["pay_statement"] as? NSArray ?? NSArray()
                if arrData.count > 0
                {
                    gModel.arrTemp3 = NSMutableArray()
                  
                    for i in 0 ..< arrData.count
                    {
                        gModel.arrTemp3.addObjects(from: ([PayStatementModel().getPayStatementData(responseDict: arrData[i] as! NSDictionary)]))
                      
                    }
                }
            }
        }
        return gModel
    }
    
    //MARK: Weekly Earnings
    func separateParamForWeeklyEarnings(params : NSDictionary) -> Any
    {
        let weeklyData = EarningsModel()
        if params["error"] != nil
        {
            weeklyData.status_message = params["error"] as? String ?? String()
            weeklyData.status_code = "0"
        }
        else
        {
            weeklyData.status_message = params["status_message"] as? String ?? String()
            weeklyData.status_code = params["status_code"] as? String ?? String()
            
            if weeklyData.status_code == "1"
            {
                weeklyData.last_trip = UberSupport().checkParamTypes(params: params, keys:"last_trip")
                weeklyData.recent_payout = UberSupport().checkParamTypes(params: params, keys:"recent_payout")
                weeklyData.total_week_amount = UberSupport().checkParamTypes(params: params, keys:"total_week_amount")
                weeklyData.total_week_amount = weeklyData.total_week_amount.replacingOccurrences(of: ",", with: "")
                if params["trip_details"] != nil
                {
                    let arrData = params["trip_details"] as? NSArray ?? NSArray()
                    if arrData.count > 0
                    {
                        weeklyData.arrWeeklyData = NSMutableArray()
                        
                        for i in 0 ..< arrData.count
                        {
                            weeklyData.arrWeeklyData.addObjects(from: ([EarningsDataModel().getWeeklyData(responseDict: arrData[i] as! NSDictionary)]))
                        }
                    }
                }
            }
        }
        return weeklyData
    }
    
    
    //MARK: Trips Info
    func separateParamForGettingTripsUrl(params : NSDictionary) -> Any
    {
        let generalModel = GeneralModel()
        if params["error"] != nil
        {
            generalModel.status_message = params["error"] as? String ?? String()
            generalModel.status_code = "0"
        }
        else
        {
            generalModel.status_message = params["status_message"] as? String ?? String()
            generalModel.status_code = params["status_code"] as? String ?? String()
            
            if generalModel.status_code == "1"
            {
                if params["today_trips"] != nil
                {
                    let arrData = params["today_trips"] as? NSArray ?? NSArray()
                    generalModel.arrTemp1 = NSMutableArray()
                    
                    for i in 0 ..< arrData.count
                    {
                        generalModel.arrTemp1.addObjects(from: [TripsModel().initTripData(responseDict: arrData[i] as! NSDictionary)])
                    }
                }
                
                if params["past_trips"] != nil
                {
                    let arrData = params["past_trips"] as? NSArray ?? NSArray()
                    generalModel.arrTemp2 = NSMutableArray()
                    
                    for i in 0 ..< arrData.count
                    {
                        generalModel.arrTemp2.addObjects(from: [TripsModel().initTripData(responseDict: arrData[i] as! NSDictionary)])
                    }
                }
            }
        }
        
        return generalModel
    }
    
    
    //MARK: After Payment
    func separateParamForAfterPayment(params : NSDictionary) -> Any
    {
        return separateParamForGeneralModel(params: params)
    }
    
    
    //MARK: Rating
    func separateParamForRating(params : NSDictionary) -> Any
    {
        let rateModel = RatingModel()
        if params["error"] != nil
        {
            rateModel.status_message = params["error"] as? String ?? String()
            rateModel.status_code = "0"
        }
        else
        {
            rateModel.status_message = params["status_message"] as? String ?? String()
            rateModel.status_code = params["status_code"] as? String ?? String()
            
            if rateModel.status_code == "1"
            {
                rateModel.driver_rating = UberSupport().checkParamTypes(params: params, keys:"driver_rating")
                rateModel.total_rating = UberSupport().checkParamTypes(params: params, keys:"total_rating")
                rateModel.total_rating_count = UberSupport().checkParamTypes(params: params, keys:"total_rating_count")
                rateModel.five_rating_count = UberSupport().checkParamTypes(params: params, keys:"five_rating_count")
            }
        }
        return rateModel
    }
    
    
    //MARK: Rider Feedback
    func separateParamForRiderFeedBack(params : NSDictionary) -> Any
    {
        let gModel = GeneralModel()
        gModel.status_message = params["status_message"] as? String ?? String()
        gModel.status_code = params["status_code"] as? String ?? String()

        if gModel.status_code == "1"
        {
            if params["rider_feedback"] != nil
            {
                let arrData = params["rider_feedback"] as? NSArray ?? NSArray()
                if arrData.count > 0
                {
                    gModel.arrTemp1 = NSMutableArray()
                    
                    for i in 0 ..< arrData.count
                    {
                        gModel.arrTemp1.addObjects(from: ([RatingFeedBackModel().initiateFeedbackData(responseDict: arrData[i] as! NSDictionary)]))
                    }
                }
            }
        }
        
        return gModel
    }

    
    //MARK: Upload Profile Image
    func separateParamForUploadProfileImage(params : NSDictionary) -> Any
    {
        return separateParamForGeneralModel(params: params)
    }
    
    
    //MARK: Update Home Or Work Location
    func separateParamForUpdateHomeOrWorkLocation(params : NSDictionary) -> Any
    {
        return separateParamForGeneralModel(params: params)
    }
    
    
    //MARK: View Logged in User Profile
    func separateParamForViewProfile(params : NSDictionary) -> Any
    {
        let profileData = ProfileModel()
        if params["error"] != nil
        {
            profileData.status_message = params["error"] as? String ?? String()
            profileData.status_code = "0"
        }
        else
        {
            profileData.status_message = params["status_message"] as? String ?? String()
            profileData.status_code = params["status_code"] as? String ?? String()
            if profileData.status_code == "1"
            {
                profileData.user_name =  String(format:"%@ %@",params["first_name"] as? String ?? String(),params["last_name"] as? String ?? String()) as String
                profileData.first_name = params["first_name"] as? String ?? String()
                profileData.last_name = params["last_name"] as? String ?? String()
                profileData.user_thumb_image = params["profile_image"] as? String ?? String()
                profileData.company_id = Int(params["company_id"] as! CFNumber)
                profileData.email_id =  UberSupport().checkParamTypes(params: params, keys:"email_id")
                profileData.car_id =  UberSupport().checkParamTypes(params: params, keys:"car_id")
                profileData.currency_code =  UberSupport().checkParamTypes(params: params, keys:"currency_code")
                profileData.currency_symbol =  UberSupport().checkParamTypes(params: params, keys:"currency_symbol")
                profileData.mobile_number =  UberSupport().checkParamTypes(params: params, keys:"mobile_number")                
                profileData.address_line1 = params["address_line1"] as? String ?? String()
                profileData.address_line2 = UberSupport().checkParamTypes(params: params, keys:"address_line2")
                profileData.city = UberSupport().checkParamTypes(params: params, keys:"city")
                profileData.state = UberSupport().checkParamTypes(params: params, keys:"state")
                profileData.postal_code = UberSupport().checkParamTypes(params: params, keys:"postal_code")
                profileData.vehicle_no = UberSupport().checkParamTypes(params: params, keys:"vehicle_number")
                 profileData.car_type = UberSupport().checkParamTypes(params: params, keys:"car_type")
                profileData.vehicle_name = UberSupport().checkParamTypes(params: params, keys:"vehicle_name")
                profileData.insurance = UberSupport().checkParamTypes(params: params, keys:"insurance")
                profileData.license_back = UberSupport().checkParamTypes(params: params, keys:"license_back")
                profileData.license_front = UberSupport().checkParamTypes(params: params, keys:"license_front")
                profileData.permit = UberSupport().checkParamTypes(params: params, keys:"permit")
                profileData.car_image = UberSupport().checkParamTypes(params: params, keys:"car_image")
                profileData.car_active_image = UberSupport().checkParamTypes(params: params, keys:"car_active_image")
                profileData.rc = UberSupport().checkParamTypes(params: params, keys:"rc")
                profileData.bankDetails = BankDetails(json: params["bank_details"] as! JSON)
                if let json = params as? JSON{
                    profileData.company_name = json.string("company_name")
                    profileData.company_id = json.int("company_id")
                }
                let currency = self.makeCurrencySymbols(encodedString: UberSupport().checkParamTypes(params: params, keys:"currency_symbol") as String)
                Constants().STOREVALUE(value: currency, keyname: USER_CURRENCY_SYMBOL_ORG)
                Constants().STOREVALUE(value: UberSupport().checkParamTypes(params: params, keys:"currency_code") as String, keyname: USER_CURRENCY_ORG)
              
                
            }
        }
        return profileData
    }
}

