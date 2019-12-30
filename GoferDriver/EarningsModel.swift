/**
 * EarningsModel.swift
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

class EarningsModel : NSObject
{    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var last_trip : String = ""
    var recent_payout : String = ""
    var total_week_amount : String = "0"
    var arrWeeklyData : NSMutableArray = NSMutableArray()
}

class EarningsDataModel : NSObject {
    
    //MARK Properties
    var created_at : String = ""
    var daily_fare : String = ""
    var day : String = ""
    
    //Get the weekly data
    func getWeeklyData(responseDict: NSDictionary) -> Any
    {
        created_at =  UberSupport().checkParamTypes(params: responseDict, keys:"created_at")
        daily_fare = UberSupport().checkParamTypes(params: responseDict, keys:"daily_fare") 
        day = UberSupport().checkParamTypes(params: responseDict, keys:"day")
        return self
    }
}
