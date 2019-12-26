/**
 * PayStatementModel.swift
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

class PayStatementModel : NSObject {
    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var pay_date : String = ""
    var pay_amount : String = ""
    var trip_id : String = ""
//Get the payable statment
    func getPayStatementData(responseDict: NSDictionary) -> Any
    {
        pay_date =  UberSupport().checkParamTypes(params: responseDict, keys:"pay_date")
        pay_amount = UberSupport().checkParamTypes(params: responseDict, keys:"pay_amount")
        trip_id = UberSupport().checkParamTypes(params: responseDict, keys:"trip_id")
        return self
    }
}
