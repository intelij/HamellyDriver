/**
* GeneralModel.swift
*
* @package Makent
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/


import Foundation
import UIKit

class GeneralModel : NSObject {
    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    
    
    var otp_code : String = ""
    var trip_id : String = ""
    var driver_status : String = ""

    
    // This is for room booking
    var availability_msg : String = ""
    var pernight_price : String = ""

    // Inbox
    var unread_message_count : String = ""
    
    var min_price : String = ""
    var max_price : String = ""

    var room_id : String = ""
    var room_location : String = ""

    var message : String = ""
    var message_time : String = ""
    var payment_method : String = ""
    var payment_details : String = ""

    
    var dictTemp : NSMutableDictionary = NSMutableDictionary()

    var arrTemp1 : NSMutableArray = NSMutableArray()
    var arrTemp2 : NSMutableArray = NSMutableArray()
    var arrTemp3 : NSMutableArray = NSMutableArray()
}
