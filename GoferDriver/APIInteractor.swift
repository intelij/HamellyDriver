//
//  APIInteractor.swift
//  GoferDriver
//
//  Created by trioangle on 05/04/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation

import Alamofire

protocol APIInteractorProtocol {
    var apiView : APIViewProtocol{get set}

    var isLoading : Bool{get set}
    var isFetchingData : Bool{get set}

    
    func getResponse(for api : APIEnums )-> APILoadersProtocol
    func getResponse(forAPI api: APIEnums, params : Parameters) -> APILoadersProtocol
    func getResponse(forAPI api: APIEnums,
                     params: Parameters,
                     responseValue : @escaping (ResponseEnum)->())
        -> APILoadersProtocol
}

protocol APIViewProtocol {
    var apiInteractor : APIInteractorProtocol?{get set}
    func onAPIComplete(_ response : ResponseEnum)
    func onFailure(error : String)
}

protocol APILoadersProtocol{
    func shouldLoad(_ shouldLoad: Bool)
}
class APIInteractor : APIInteractorProtocol,APILoadersProtocol{
    var isLoading: Bool
    
    var isFetchingData: Bool
    
    
    var apiView: APIViewProtocol
    var appDeleage = UIApplication.shared.delegate as! AppDelegate
    var preference = UserDefaults.standard
    var support = UberSupport()
    
    init(_ view : APIViewProtocol){
        self.apiView = view
        self.isLoading = false
        self.isFetchingData = false
    }
    
    func shouldLoad(_ shouldLoad: Bool) {
        self.isLoading = shouldLoad
        if shouldLoad{
            self.support.showProgressInWindow(showAnimation: false)
            self.support.removeProgressInWindow()
        }else{
            self.support.removeProgressInWindow()
        }
        
    }
    func getResponse(for api: APIEnums) -> APILoadersProtocol {
        return self.getResponse(forAPI: api, params: Parameters())
    }
    internal func getResponse(forAPI api: APIEnums, params: Parameters) -> APILoadersProtocol {
        var parameters = params
        parameters["token"] = preference.string(forKey: USER_ACCESS_TOKEN)
        parameters["user_type"] = "Driver".lowercased()
        guard NetworkManager.instance.isNetworkReachable else{
            appDeleage.createToastMessage(iApp.GoferError.connection.error.localize)
            self.shouldLoad(false)
            return self
        }
        let header : [AnyHashable: Any]  = ["Content-Type":"application/x-www-form-urlencoded","Accept":"application/json","token": Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)]
        self.isFetchingData = true
        Alamofire.request(iApp.APIBaseUrl+api.rawValue,
                          method: api.method,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: header as! HTTPHeaders)
            .responseJSON { (response) in
                self.isFetchingData = false
                self.shouldLoad(true)
                print("")
                print("Å api : ",response.request?.url ?? ("\(api.rawValue)\(params)"))
                guard response.response?.statusCode != 401 else{//Unauthorized
                    self.appDeleage.logOutDidFinish()
                    return
                }
                switch response.result{
                case .success(let value):
                    let json = value as! JSON
                    let error = json.string("error")
                    guard error.isEmpty else{
                        if error == "user_not_found"{
                            self.appDeleage.logOutDidFinish()
                        }
                        return
                    }
                    if json.isSuccess || api == .validateNumber{
                        self.apiView
                            .onAPIComplete(self.handleResponse(forAPI: api,
                                                               json: json))
                        
                    }else{
                        self.apiView.onFailure(error: json.status_message)
                        print("Å error : \(json.status_message)")
                    }
                case .failure(let error):
                    print("Å error : \(error)")
                    self.apiView.onFailure(error: error.localizedDescription)
                }
        }
        return self
    }
    func getResponse(forAPI api: APIEnums,
                     params: Parameters,
                     responseValue : @escaping (ResponseEnum)->())
        -> APILoadersProtocol{
            var parameters = params
            parameters["token"] = preference.string(forKey: USER_ACCESS_TOKEN)
            parameters["user_type"] = "Driver"
            guard NetworkManager.instance.isNetworkReachable else{
                appDeleage.createToastMessage(iApp.GoferError.connection.error.localize)
                self.shouldLoad(false)
                return self
            }
            
            self.isFetchingData = true
            Alamofire.request(iApp.APIBaseUrl+api.rawValue,
                              method: api.method,
                              parameters: parameters,
                              encoding: URLEncoding.default,
                              headers: nil)
                .responseJSON { (response) in
                    self.isFetchingData = false
                    self.shouldLoad(false)
                    
                    print("Å api : ",response.request?.url ?? ("\(api.rawValue)\(params)"))
                    guard response.response?.statusCode != 401 else {
                        self.appDeleage.logOutDidFinish()
                        return
                    }
                    switch response.result{
                    case .success(let value):
                        let json = value as! JSON
                        let error = json.string("error")
                        guard error.isEmpty else{
                            if error == "user_not_found"{
                                self.appDeleage.logOutDidFinish()
                            }
                            return
                        }
                        if json.isSuccess || api == .validateNumber{
                            let _responseValue = self.handleResponse(forAPI: api, json: json)
                            responseValue(_responseValue)
                        }else{
                            responseValue(ResponseEnum.failure(json.status_message))
                            print("Å error : \(json.status_message)")
                        }
                    case .failure(let error):
                        print("Å error : \(error)")
                        responseValue(ResponseEnum.failure(error.localizedDescription))
                    }
            }
            return self
    }
    private func handleResponse(forAPI api : APIEnums, json : JSON)-> ResponseEnum{
        switch api {
        case .validateNumber:
            let isValid = json.isSuccess
            let otp = json.string("otp")
            let message = json.status_message
            return ResponseEnum.number(isValid: isValid,
                                       OTP: otp,
                                       message: message)
        case .register:
            let user = LoginModel(json)
            return ResponseEnum.LoginModel(user)
        case .inCompleteTrips:
            Shared.instance.resumeTripHitCount += 1
            fallthrough
        case .getInvoice,
             .cashCollected:
            let rider = RiderDetailModel(withJson: json)
            return ResponseEnum.RiderModel(rider)
            
        case .checkDriverStatus:
            let status = DriverStatus.getStatus(forString : json.string("driver-check-status"))
            status.storeInPreference()
            return ResponseEnum.driverStatus(status)
            
  
//        case .force_update:
//            let shouldForceUpdate = json.bool("force_update")
//            return ResponseEnum.forceUpdate(shouldForceUpdate)
//            return
        default:
            return ResponseEnum.success
        }
    }
    
    
}
