/**
 * RatingModel.swift
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

class RatingModel : NSObject
{
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var total_rating : String = ""
    var total_rating_count : String = ""
    var five_rating_count : String = ""
    var driver_rating : String = ""
}

class RatingFeedBackModel : NSObject
{
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var date : String = ""
    var rider_rating : String = ""
    var rating_comments : String = ""
    var user_id : String = ""
    
    // MARK: Inits
    func initiateFeedbackData(responseDict: NSDictionary) -> Any
    {
        date = UberSupport().checkParamTypes(params: responseDict, keys:"date")
        rider_rating = UberSupport().checkParamTypes(params: responseDict, keys:"rider_rating")
        rating_comments = UberSupport().checkParamTypes(params: responseDict, keys:"rider_comments")
        user_id = UberSupport().checkParamTypes(params: responseDict, keys:"trip_id")
        return self
    }
}
