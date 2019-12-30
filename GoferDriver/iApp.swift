//
//  Constants.swift
//  GoferDriver
//
//  Created by bowshul sheik rahaman on 28/01/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation
import UIKit

class iApp{
    
    //MARK:- Package Data
    static let appName = "HamellyDriver"
    static var isSimulator : Bool{
        return TARGET_OS_SIMULATOR != 0
    }

    enum ServerTypes : String{
        case live = "http://gofer.trioangle.com/"
        case demo = "http://gofer.trioangledemo.com/"
        case enterpriseLocal = "https://api-ksa.com/demo/hamelly/public/index.php/"//"http://192.168.1.152:8000/" //"http://services-apps.net/aqarguide/"//
    }
    
    enum GoogleKeys :String{
        case map
        case client
        case fire
        var key:String {
            switch self {
            case .map:
                return "AIzaSyDq6N_AZBav7KlBiWR7l0eNmw6e3rari9A"//"AIzaSyB6lCQnISdsSUVFdcQYxaHxXXjvKDn9wcs"
            case .client:
                return "239640610908-r2elld96jeo830qpjr9i2cdtunqf9br6.apps.googleusercontent.com"
            case .fire:
                return "driver_rider_trip_chats"
            }
        }
    }
    
    enum GoferFont: String {
        case light
        case medium
        case bold
        case image
        
        var font :String {
            switch self {
            case .light:
                return "ClanPro-Book"
            case .medium:
                return "ClanPro-News"
            case .bold:
                return "ClanPro-Medium"
            case .image:
                return "uber-clone-mobile"
            }
        }
    }
    
    enum GoferError : String {
        case server
        case connection
        case upload
        var error:String {
            switch self {
            case .server:
                return "Internal server error, please try again.".localize
            case .connection:
                return "No internet connection.".localize
            case .upload:
                return "Internal server error, please try again.".localize
            }
        }
    }
        
    struct Rider: iTunesData{
        var appName = "Gofer"
        var appStoreDisplayName = "gofer-on-demand-service"
        var appID = "id1253818335"
    }
    struct Driver: iTunesData{
        var appName = "GoferDriver"
        var appStoreDisplayName = "gofer-driver-on-demand-service"
        var appID = "id1253819680"
    }
        
    
    //Resticting initalizer
    private init(){}
    
    static let baseURL : ServerTypes = .enterpriseLocal
    static let APIBaseUrl = iApp.baseURL.rawValue + "api/"
    
    static let instance = iApp()
    static var img = ImageConstants()
    
    
    //MARK:- Required delarations
    let userType = "Rider"
    let deviceType = "1"
    //MARK:- UserFull declarations
    lazy var version : String? = {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    }()
    
    var isRTL : Bool  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return  ["ar","fa"].contains(appDelegate.language)
    }

}


extension UIColor{
    static let ThemeMain = UIColor(hex: "000000")
    static let ThemeLight = UIColor(hex: "1CB1D0")
    static let ThemeInactive = UIColor(hex : "A4A4AB")
    static let ThemeBgrnd = UIColor(hex: "FFFFFF")
    static let ThemeBack = UIColor.ThemeMain
}

struct ImageConstants {
    lazy var phone : String = {"phone.png"}()
    lazy var account : String = {"account.png"}()
    lazy var mapMarker : String = {"map_marker.png"}()
    lazy var clockOutline : String = {"clock_outline.png"}()
    lazy var busIcon : String = {"bus_alert.png"}()
    lazy var taxiIcon : String = {"taxi.png"}()
    
}
