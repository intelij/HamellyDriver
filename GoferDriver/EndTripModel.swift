/**
 * EndTripModel.swift
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

class EndTripModel : NSObject {
    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var access_fee : String = ""
    var base_fare : String = ""
    var driver_payout : String = ""
    var drop_location : String = ""
    var pickup_location : String = ""
    var payment_status : String = ""
    var total_fare : String = ""
    var total_km : String = ""
    var total_km_fare : String = ""
    var total_time : String = ""
    var total_time_fare : String = ""
    var payment_method : String = ""
    var owe_amount : String = ""
    var applied_owe_amount : String = ""
    var wallet_amount : String = ""
    var promo_amount : String = ""
    var arrTemp2 : NSMutableArray = NSMutableArray()

    var arrTemp3 : NSMutableArray = NSMutableArray()
   
}
