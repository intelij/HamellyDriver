//
//  AccountInteractor.swift
//  GoferDriver
//
//  Created by bowshul sheik rahaman on 05/02/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation
import Alamofire


class AccountInteractor {
    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
    let uberSupport = UberSupport()
    private let preference = UserDefaults.standard
    private init(){}
    static let instance = AccountInteractor()
    
    func checkRegistrationStatus(forNumber number : String,countryCode code : String,_ result : @escaping (_ isAvaliable: Bool, _ message : String)->()){
        var params = Parameters()
        params["country_code"] = code
        params["mobile_number"] = number
        params["language"] = appDelegate.language
        params["user_type"] = "driver"
        uberSupport.showProgressInWindow(showAnimation: true)
        Alamofire.request( "\(iApp.APIBaseUrl)\(METHOD_PHONENO_VALIDATION)",
            method: .get,
            parameters: params,
            encoding: URLEncoding.default,
            headers: nil).responseJSON { (jsonResponse) in
                print(jsonResponse.request?.url ?? "")
                self.uberSupport.removeProgressInWindow()
                switch jsonResponse.result{
                case .success(let value) :
                    let json = value as! JSON
                    print(json.status_code,json)
                    if json.status_code == 1{
                        result(true,json.status_message)
                    }else{
                        result(false,json.status_message)
                    }
                case .failure(let error):
                    print(error)
                    result(false,error.localizedDescription)
                }
        }
    }
    
}
