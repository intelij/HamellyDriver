/**
 * SearchCarsModel.swift
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

class SearchCarsModel : NSObject {
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var cars_latitude : String = ""
    var cars_longitude : String = ""
    var arrival_minutes : String = ""
    //Get the car details
    func initCarDetails(responseDict: NSDictionary) -> Any
    {
        guard let json = responseDict as? JSON else{return self}
        
        status_message = json.status_message
        status_code = json.status_code.description
        //responseDict["status_code"] as? String ?? String()
        cars_latitude = json.string("cars_latitude")
        //responseDict["cars_latitude"] as? String ?? String()
        cars_longitude = json.string("cars_longitude")
            //responseDict["cars_longitude"] as? String ?? String()
        arrival_minutes = json.string("arrival_minutes")
        //responseDict["arrival_minutes"] as? String ?? String()

        return self
    }
}
