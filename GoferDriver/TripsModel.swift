/**
 * EndTripModel.swift
 *
 * @package UberClone
 * @subpackage Controller
 * @category Calendar
 * @author Trioangle Product Team
 * @version - Stable 1.0
 * @link http://trioangle.com
 */

import Foundation
import UIKit

class TripsModel : NSObject {
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var id : String = ""
    var access_fee : String = ""
    var base_fare : String = ""
    var car_id : String = ""
    var created_at : String = ""
    var deleted_at : String = ""
    var distance_fare : String = ""
    var driver_id : String = ""
    var driver_thumb_image : String = ""
    var driver_name : String = ""
    var driver_payout : String = ""
    var pickup_date_time : String = ""
    var drop_latitude : String = ""
    var drop_location : String = ""
    var drop_longitude : String = ""
    var pickup_latitude : String = ""
    var pickup_location : String = ""
    var pickup_longitude : String = ""
    var request_id : String = ""
    var trip_status : String = ""
    var time_fare : String = ""
    var total_fare : String = ""
    var total_km : String = ""
    var trip_time : String = ""
    var updated_at : String = ""
    var user_id : String = ""
    var vehicle_name : String = ""
    var trip_id : String = ""
    var mapImageUrl : String = ""
    var trip_path : String = ""
    var payment_method : String = ""
    var applied_owe_amount : String = ""
    var owe_amount : String = ""
    var promo_amount : String = ""
    var wallet_amount : String = ""
    var map_image : String = ""
    var invoice : NSMutableArray = NSMutableArray()

    //Get the trips data
    func initTripData(responseDict: NSDictionary) -> Any
    {
            drop_latitude = responseDict["drop_latitude"] as? String ?? String()
            drop_longitude = responseDict["drop_longitude"] as? String ?? String()
            pickup_latitude = responseDict["pickup_latitude"] as? String ?? String()
            pickup_longitude = responseDict["pickup_longitude"] as? String ?? String()
            
            let mapmainUrl = "https://maps.googleapis.com/maps/api/staticmap?"
            let startlatlong = String(format:"%@ , %@",pickup_latitude,pickup_longitude)
            
            let mapUrl  = mapmainUrl + startlatlong
            trip_path = UberSupport().checkParamTypes(params: responseDict, keys:"trip_path") as String
            
            let size = "&size=" +  "\(Int(640))" + "x" +  "\(Int(350))"
            let enc = "&path=color:0x000000ff|weight:4|enc:" + trip_path
            let droplatlong = String(format:"%@ , %@",drop_latitude,drop_longitude)
            
            let pickupImgUrl = String(format:"%@public/images/pickup|",iApp.baseURL.rawValue)
            let dropImgUrl = String(format:"%@public/images/drop|",iApp.baseURL.rawValue)
            
            let positionOnMap = "&markers=size:mid|icon:" + pickupImgUrl + startlatlong
            let positionOnMap1 = "&markers=size:mid|icon:"  + dropImgUrl + droplatlong
            
            let staticImageUrl = mapUrl + droplatlong + size + "&zoom=14" + positionOnMap + positionOnMap1 + enc
            if let urlStr = staticImageUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)! as NSString?{
                 mapImageUrl = urlStr as String
            }
        map_image = responseDict["map_image"] as? String ?? String()
        car_id = UberSupport().checkParamTypes(params: responseDict, keys:"car_id") as String
        created_at = responseDict["created_at"] as? String ?? String()
//        distance_fare = UberSupport().checkParamTypes(params: responseDict, keys:"distance_fare") as String
        payment_method = UberSupport().checkParamTypes(params: responseDict, keys:"payment_method") as String
//        applied_owe_amount = UberSupport().checkParamTypes(params: responseDict, keys:"applied_owe_amount") as String
//        owe_amount = UberSupport().checkParamTypes(params: responseDict, keys:"owe_amount") as String
//        promo_amount = UberSupport().checkParamTypes(params: responseDict, keys:"promo_amount") as String
//        wallet_amount = UberSupport().checkParamTypes(params: responseDict, keys:"wallet_amount") as String
        
        
        driver_id = UberSupport().checkParamTypes(params: responseDict, keys:"driver_id") as String
//        driver_thumb_image = responseDict["driver_thumb_image"] as? String ?? String()
//        driver_name = responseDict["driver_name"] as? String ?? String()
        driver_payout = UberSupport().checkParamTypes(params: responseDict, keys:"driver_payout") as String
//        pickup_date_time = UberSupport().checkParamTypes(params: responseDict, keys:"pickup_date_time") as String
        drop_location = responseDict["drop_location"] as? String ?? String()
        pickup_location = responseDict["pickup_location"] as? String ?? String()
        request_id = UberSupport().checkParamTypes(params: responseDict, keys:"request_id") as String
        trip_status = responseDict["status"] as? String ?? String()
//        time_fare = UberSupport().checkParamTypes(params: responseDict, keys:"time_fare") as String
        total_fare = UberSupport().checkParamTypes(params: responseDict, keys:"total_fare") as String
        

        total_km = UberSupport().checkParamTypes(params: responseDict, keys:"total_km") as String
//        trip_time = UberSupport().checkParamTypes(params: responseDict, keys:"total_time") as String
        updated_at = UberSupport().checkParamTypes(params: responseDict, keys:"updated_at") as String
        user_id = UberSupport().checkParamTypes(params: responseDict, keys:"user_id") as String
        id = UberSupport().checkParamTypes(params: responseDict, keys:"id") as String
        
//        vehicle_name = responseDict["vehicle_name"] as? String ?? String()
        trip_id = UberSupport().checkParamTypes(params: responseDict, keys:"id") as String
        
        if responseDict["invoice"] != nil
        {
            let arrData = responseDict["invoice"] as? NSArray ?? NSArray()
            self.invoice = NSMutableArray()
            
            for i in 0 ..< arrData.count
            {
                self.invoice.addObjects(from: [InvoiceModel().initInvoiceData(responseDict: arrData[i] as! NSDictionary)])
            }
        }
        return self
    }
}
