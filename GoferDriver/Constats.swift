/**
* Constants.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import MessageUI
import Social


class Shared{
    static let instance = Shared()
    private init(){}
    
    var resumeTripHitCount = 0
}

class Constants : NSObject
{
    //MARK: When store user dates
    func STOREVALUE(value : String , keyname : String)
    {
        UserDefaults.standard.setValue(value , forKey: keyname as String)
        UserDefaults.standard.synchronize()
    }
    //MARK: Get user dates
    func GETVALUE(keyname : String) -> String
    {
        let value = UserDefaults.standard.value(forKey: keyname)
        if value == nil
        {
            return ""
        }
        return value as? String ?? String()
    }
    static let userDefaults = UserDefaults.standard
    
}
enum PipeLineKey : String{
    case check_splash
    case app_entered_foreground
}
enum Stories {
    
    case main
    case payment
    case account
    case trip
    
    var instance : UIStoryboard{
        switch self {
        case .main:
            return UIStoryboard(name: STORY_MAIN, bundle: nil)
        case .payment:
            return UIStoryboard(name: STORY_PAYMENT, bundle: nil)
        case .trip:
            return UIStoryboard(name: STORY_TRIP, bundle: nil)
        case .account:
            return UIStoryboard(name: STORY_ACCOUNT, bundle: nil)
        default:
            return UIStoryboard(name: STORY_MAIN, bundle: nil)
        }
    }
}


