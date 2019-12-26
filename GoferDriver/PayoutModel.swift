//
//  PayoutModel.swift
//  GoferDriver
//
//  Created by bowshul sheik rahaman on 24/01/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation
import Alamofire

enum PayoutEditOption : String{
    case setAsDefault = "default"
    case delete = "delete"
}
class PaymentInteractor{
    private init(){}
    static let instance = PaymentInteractor()
    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
    let uberSupport = UberSupport()
    
    func getPayoutList(response : @escaping ([PayoutDetail])->()){
        var params = Parameters()
        params["token"]   = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        uberSupport.showProgressInWindow(showAnimation: true)
        Alamofire.request("\(iApp.APIBaseUrl)\(METHOD_GET_PAYOUT_LIST)",
            method: .get,
            parameters: params,
            encoding: URLEncoding.default,
            headers: nil).responseJSON { (jsonResponse) in
                self.uberSupport.removeProgressInWindow()
                print(jsonResponse.request?.url)
                if jsonResponse.result.isSuccess,
                    let data = jsonResponse.data{
                    do{
                        let payoutlistResponse = try JSONDecoder().decode(PayoutListResponse.self,from: data)
                        let json = jsonResponse.result.value as! JSON
                        print(json)
                        if payoutlistResponse.statusCode == "1"{
                            response(payoutlistResponse.payoutDetails )
                        }else{
                            response(payoutlistResponse.payoutDetails )
                            self.appDelegate.createToastMessage(payoutlistResponse.successMessage , bgColor: .black, textColor: .white)
                            if ["token_invalid","user_not_found","Authentication Failed"].contains(payoutlistResponse.successMessage){
                                self.appDelegate.logOutDidFinish()
                            }
                        }
                    }catch {
                        print(error)
                        
                    }
                    
                }else{
                    self.appDelegate.createToastMessage(jsonResponse.result.error?.localizedDescription ?? "Server issue, Please try again.".localize, bgColor: .black, textColor: .white)
                    response([PayoutDetail]())
                }
        }
        
    }
    func getCountry(response : @escaping ([CountryList])->()){
        var params = Parameters()
        params["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        uberSupport.showProgressInWindow(showAnimation: true)
        Alamofire.request("\(iApp.APIBaseUrl)country_list",
            method: .get,
            parameters: params,
            encoding: URLEncoding.default,
            headers: nil).responseJSON { (jsonResponse) in
                self.uberSupport.removeProgressInWindow()
                print(jsonResponse.request?.url)
                if jsonResponse.result.isSuccess,
                    let data = jsonResponse.data,
                    let countryResponse = try? JSONDecoder().decode(CountryResponse.self,
                                                                    from: data){
                    let json = jsonResponse.result.value as! JSON
                    print(json.status_message,json.status_code,json.status_message)
                    if countryResponse.statusCode == "1"{
                        response(countryResponse.countryList)
                    }else{
                        response(countryResponse.countryList)
                        self.appDelegate.createToastMessage(countryResponse.successMessage, bgColor: .black, textColor: .white)
                        if ["token_invalid","user_not_found","Authentication Failed"].contains(countryResponse.successMessage){
                            self.appDelegate.logOutDidFinish()
                        }
                    }
                }else{
                    self.appDelegate.createToastMessage(jsonResponse.result.error?.localizedDescription ?? "Server issue, Please try again.".localize, bgColor: .black, textColor: .white)
                    response([CountryList]())
                }
        }
    }
    
    func getStripeCountry(response : @escaping ([CountryList])->()){
        var params = Parameters()
        params["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        uberSupport.showProgressInWindow(showAnimation: true)
        Alamofire.request("\(iApp.APIBaseUrl)\(METHOD_GET_STRIPE_COUNTRIES)",
            method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (jsonResponse) in
            self.uberSupport.removeProgressInWindow()
            print(jsonResponse.request?.url)
            if jsonResponse.result.isSuccess,
                let data = jsonResponse.data,
                let countryResponse = try? JSONDecoder().decode(CountryResponse.self,
                                                                from: data){
                let json = jsonResponse.result.value as! JSON
                print(json.status_message,json.status_code,json.status_message)
                if countryResponse.statusCode == "1"{
                    response(countryResponse.countryList)
                }else{
                    response(countryResponse.countryList)
                    self.appDelegate.createToastMessage(countryResponse.successMessage, bgColor: .black, textColor: .white)
                    if ["token_invalid","user_not_found","Authentication Failed"].contains(countryResponse.successMessage){
                        self.appDelegate.logOutDidFinish()
                    }
                }
            }else{
                self.appDelegate.createToastMessage(jsonResponse.result.error?.localizedDescription ?? "Server issue, Please try again.".localize, bgColor: .black, textColor: .white)
                response([CountryList]())
            }
        }
    }
    
    func addPayout(withDetails params: Parameters ,imageName : String = String(),data : Data = Data(),result : @escaping (Bool)->()){
        
        //uberSupport.showProgressInWindow(showAnimation: true)
        print(params)
    
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if data != Data(){
                multipartFormData.append(data, withName: "document", fileName: imageName, mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(),
           to: "\(iApp.APIBaseUrl)\(METHOD_ADD_STRIPE_PAYOUT)",
        method: .post,
        headers: nil) { (results) in
            switch results{
                
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    print(response.request?.url)
                    if let err = response.error{
                        result(false)
                        self.appDelegate.createToastMessage(err.localizedDescription, bgColor: .black, textColor: .white)
                        return
                    }
                    if response.result.isSuccess{
                        let json = response.result.value as! JSON
                        if json.status_code == 1{
                            result(true)
                        }else{
                            self.appDelegate.createToastMessage(json.status_message,
                                                                bgColor: .black,
                                                                textColor: .white)
                            result(false)
                        }
                    }else{
                        result(false)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                self.appDelegate.createToastMessage(error.localizedDescription, bgColor: .black, textColor: .white)
            }
           // self.uberSupport.removeProgressInWindow()
        }
    }
    
    func editPayout(withId id : Int,option : PayoutEditOption,response : @escaping (Bool)->()){
        var params = Parameters()
        params["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        params["type"] = option.rawValue
        params["payout_id"] = id
        if option == .delete{
            params["type"] = "delete"
        }else {
            params["type"] = "default"
        }
        params["payout_id"] = id
        Alamofire.request("\(iApp.APIBaseUrl)\(METHOD_PAYOUT_CHANGE)",
            method: .get,
            parameters: params,
            encoding: URLEncoding.default,
            headers: nil).responseJSON { (responseJSON) in
                let json = responseJSON.result.value as! JSON
                if responseJSON.result.isSuccess{
                    if json.status_code == 1{
                        response(true)
//                        self.appDelegate.createToastMessage(json.success_message, bgColor: .black, textColor: .white)
                    }else{
                        response(false)
                        self.appDelegate.createToastMessage(json.status_message, bgColor: .black, textColor: .white)
                    }
                }else{
                    response(false)
                }
        }
    }
}

//MARK: models/////////////


class PayoutPerferenceModel: NSObject {
    var success_message : NSString = ""
    var status_code : NSString = ""
    var country_id : NSString = ""
    var country_name : NSString = ""
    var country_code : NSString = ""
    var currency_code : NSArray?
    
    func initiateListingData(responseDict: NSDictionary) -> Any
    {
        country_id =  self.checkParamTypes(params: responseDict, keys:"country_id")
        country_name = self.checkParamTypes(params: responseDict, keys:"country_name")
        country_code = self.checkParamTypes(params: responseDict, keys:"country_code")
        
        if let latestValue = responseDict["currency_code"] as? NSArray
        {
            currency_code = latestValue
        }
        
        return self
    }
    //MARK: Check Param Type
    func checkParamTypes(params:NSDictionary, keys:NSString) -> NSString
    {
        
        print("params is: \(params)")
        
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
// MARK: Countrylist model
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

fileprivate class CountryResponse: Codable {
    var (successMessage, statusCode) =  (String(),String())
    var countryList = [CountryList]()
    
    enum CodingKeys: String, CodingKey {
        case successMessage = "success_message"
        case statusCode = "status_code"
        case countryList = "country_list"
    }
    init(){}
    init(successMessage: String, statusCode: String, countryList: [CountryList]) {
        self.successMessage = successMessage
        self.statusCode = statusCode
        self.countryList = countryList
    }
}

class CountryList: Codable {
    var countryID = Int()
    var (countryName, countryCode) = (String(),String())
    var currencyCode : [String]? = [String]()
    
    enum CodingKeys: String, CodingKey {
        case countryID = "country_id"
        case countryName = "country_name"
        case countryCode = "country_code"
        case currencyCode = "currency_code"
    }
    
    init(countryID: Int, countryName: String, countryCode: String, currencyCode: [String]?) {
        self.countryID = countryID
        self.countryName = countryName
        self.countryCode = countryCode
        self.currencyCode = currencyCode
    }
}
//MARK: Payout list model
fileprivate class PayoutListResponse: Codable {
    var (successMessage, statusCode) = (String(),String())
    var payoutDetails = [PayoutDetail]()
    
    enum CodingKeys: String, CodingKey {
        case successMessage = "status_message"
        case statusCode = "status_code"
        case payoutDetails = "payout_details"
    }
    
    init(successMessage: String, statusCode: String, payoutDetails: [PayoutDetail]) {
        self.successMessage = successMessage
        self.statusCode = statusCode
        self.payoutDetails = payoutDetails
    }
}

class PayoutDetail: Codable {
    var payoutID = Int()
    var userID = Int()
    var payoutMethod = String()
    var paypalEmail = String()
    var setDefault = String()
    
    enum CodingKeys: String, CodingKey {
        case payoutID = "payout_id"
        case userID = "user_id"
        case payoutMethod = "payout_method"
        case paypalEmail = "paypal_email"
        case setDefault = "set_default"
    }
    
    init(payoutID: Int, userID: Int, payoutMethod: String, paypalEmail: String, setDefault: String) {
        self.payoutID = payoutID
        self.userID = userID
        self.payoutMethod = payoutMethod
        self.paypalEmail = paypalEmail
        self.setDefault = setDefault
    }
}
