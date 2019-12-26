//
//  FlagModel.swift
//  GoferDriver
//
//  Created by bowshul sheik rahaman on 21/01/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation
import UIKit
public extension Bundle {
    public static func contentsOfFileArray(plistName: String, bundle: Bundle? = nil) -> [[String: Any]] {
        let fileParts = plistName.components(separatedBy: ".")
        
        guard fileParts.count == 2,
            let resourcePath = (bundle ?? Bundle.main).path(forResource: fileParts[0], ofType: fileParts[1]),
            let contents = NSArray(contentsOfFile: resourcePath)
            else { return [[String:Any]]() }
        
        return contents as! [[String : Any]]
    }
}
class FlagModel{
    var country_code : String
    var dial_code : String
    var flag : UIImage
    
    private let plist = Bundle.contentsOfFileArray(plistName: "CallingCodes.plist")
    private var is_accurate = false
    var isAccurate : Bool{
        return self.is_accurate
    }
    
    init(forCountryCode c_code : String){
        let code_matching_countries = self.plist.filter { (country) -> Bool in
            let code = country["code"] as? String ?? String()
            return code == c_code
        }
        switch code_matching_countries.count {
        case 1:
            self.country_code = code_matching_countries.first?["code"] as? String ?? String()
            self.dial_code = code_matching_countries.first?["dial_code"] as? String ?? String()
            self.is_accurate = true
        case let x where x > 1://got more possibility
            self.is_accurate = false
            self.country_code = code_matching_countries.first?["code"] as? String ?? String()
            self.dial_code = code_matching_countries.first?["dial_code"] as? String ?? String()
        default:
            self.country_code = "US"
            self.dial_code = "01"
            self.is_accurate = false
        }
        if let bundlePath = Bundle.main.path(forResource: "assets", ofType: "bundle"),        let bundle = Bundle(path: bundlePath){
            self.flag = UIImage(named: "\(self.country_code.lowercased()).png", in: bundle, compatibleWith: nil)!
        }else{
            self.flag = #imageLiteral(resourceName: "us.png")
        }
    }
    init(forDialCode d_code : String){
        let dial_matching_countries = self.plist.filter { (country) -> Bool in
            let code = country["dial_code"] as? String ?? String()
            return Int(code) == Int(d_code)
        }
        switch dial_matching_countries.count {
        case 1:
            self.country_code = dial_matching_countries.first?["code"] as? String ?? String()
            self.dial_code = dial_matching_countries.first?["dial_code"] as? String ?? String()
            self.is_accurate = true
        case let x where x > 1://got more possibility
            self.country_code = dial_matching_countries.first?["code"] as? String ?? String()
            self.dial_code = dial_matching_countries.first?["dial_code"] as? String ?? String()
            self.is_accurate = false
            
        default:
            self.country_code = "US"
            self.dial_code = "01"
            self.is_accurate = false
        }
        if let bundlePath = Bundle.main.path(forResource: "assets", ofType: "bundle"),        let bundle = Bundle(path: bundlePath){
            self.flag = UIImage(named: "\(self.country_code.lowercased()).png", in: bundle, compatibleWith: nil)!
        }else{
            self.flag = #imageLiteral(resourceName: "us.png")
        }
        
    }
    func store(){
        
        Constants().STOREVALUE(value: self.dial_code, keyname: USER_DIAL_CODE)
        Constants().STOREVALUE(value: self.country_code, keyname: USER_COUNTRY_CODE)
    }
}
