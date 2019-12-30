/**
 * RiderDetailModel.swift
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

class RiderDetailModel : NSObject {
    //MARK Properties
    var id = String()
    var status_message : String = ""
    var status_code : String = ""
    var rider_id = String()
    var rider_thumb_image : String = ""
    var rider_name : String = ""
    var request_id : String = ""
    var rating_value : String = ""
    var car_type : String = ""
    var pickup_location : String = ""
    var drop_location : String = ""
    var pickup_latitude : String = ""
    var pickup_longitude : String = ""
    var drop_latitude : String = ""
    var drop_longitude : String = ""
    var mobile_number : String = ""
    var payment_method : String = ""
    var applied_owe_amount : String = ""
    var wallet_amount : String = ""
    var owe_amount : String = ""
    var trip_id : String = ""
    var trip_status : String = ""
    var tripStatus : TripStatus = .request
    var car_active_image : String = ""
    var schedule_time = String()
    var schedule_date = String()
    var trip_path = String()
    var map_image = String()
    var total_time = String()
    var begin_trip = String()
    var end_trip = String()
    var status = String()
    var created_at = String()
    var updated_at = String()
    var driver_payout = String()
    var total_km = String()
    var total_fare = String()
    var sub_total_fare = String()
    var vehicle_name = String()
    var rating = String()
    var booking_type : BookingEnum = .auto
    var getTripID : String{
        return self.trip_id.isEmpty ? self.id.description : self.trip_id
    }
    var getPayableAmount : String {
        return (Double(self.total_fare) ?? 0.0).isZero
            ? self.payment_detail.total_fare
            : self.total_fare
    }
    var getPaymentMethod : String{
        return self.payment_method.isEmpty
            ? self.payment_detail.payment_method
            : self.payment_method
    }
    var getRating : Double{
        return Double(self.rating_value) ?? 0.0
    }
    var payment_detail = EndTripModel()
    var invoices = [InvoiceModel]()
    override init(){}
    init(withJson json : JSON){
        
        super.init()
        self.id = json.string("id")
        self.rider_thumb_image = json.string("rider_thumb_image")
        self.rider_name = json.string("rider_name")
        self.rating_value = json.string("rating_value")
        self.car_type = json.string("car_type")
        self.pickup_location = json.string("pickup_location")
        self.drop_location = json.string("drop_location")
        self.pickup_latitude = json.string("pickup_latitude")
        self.pickup_longitude = json.string("pickup_longitude")
        self.drop_latitude = json.string("drop_latitude")
        self.drop_longitude = json.string("drop_longitude")
        self.mobile_number = json.string("mobile_number")
        self.payment_method = json.string("payment_method")
        self.car_active_image = json.string("car_active_image")
        
        self.trip_id = json.string("trip_id")
        self.trip_status = json.string("trip_status")
        self.trip_path = json.string("trip_path")
        self.map_image = json.string("map_image")
        self.total_time = json.string("total_time")
        self.begin_trip = json.string("begin_trip")
        self.end_trip = json.string("end-trip")
        self.status = json.string("status")
        self.created_at = json.string("created_at")
        self.updated_at = json.string("updated_at")
        self.driver_payout = json.string("driver_payout")
        self.total_km = json.string("total_km")
        self.vehicle_name = json.string("vehicle_name")
        self.total_fare = json.string("total_fare")
        self.sub_total_fare = json.string("sub_total_fare")
        self.booking_type = BookingEnum(rawValue: json.string("booking_type")) ?? .auto
        print("∂booking_type",self.booking_type)
        if let status = TripStatus(rawValue: self.trip_status){
            self.tripStatus =  status
        }else if let status = TripStatus(rawValue: self.status){
            self.tripStatus =  status
        }else{
            self.tripStatus = .request
        }
        print("∂trip_status",self.tripStatus)
        let paymentDetails = json.json("payment_details")
       
        self.payment_detail = UberSeparateParam.init().separateParamForGiveRating(params: paymentDetails as NSDictionary, isFromPayment: true) as! EndTripModel
        let invoiceArr = json.array("invoice")
        self.invoices = invoiceArr.compactMap({InvoiceModel.init($0)})
      
        self.schedule_date = json.string("schedule_date")
        self.schedule_time = json.string("schedule_time")
        if !self.getRating.isZero{
            UserDefaults.standard.set(self.getRating.description, forKey: TRIP_RIDER_RATING)
        }
        
    }
    //MARK:- fucnitonalities
    var getGooglStaticMap : URL?{
        let startlatlong = "\(self.pickup_latitude),\(self.pickup_longitude)"
        
        let droplatlong = "\(self.drop_latitude),\(self.drop_longitude)"
        
        let tripPath = self.trip_path//pastTripsDict[indexPath.row]["trip_path"] as? String ?? String()
        let mapmainUrl = "https://maps.googleapis.com/maps/api/staticmap?"
        let mapUrl  = mapmainUrl + startlatlong
        let size = "&size=" +  "\(Int(640))" + "x" +  "\(Int(350))"
        let enc = "&path=color:0x000000ff|weight:4|enc:" + tripPath
        let key = "&key=" +  iApp.GoogleKeys.map.key
        let pickupImgUrl = String(format:"%@public/images/pickup_icon|",iApp.baseURL.rawValue)
        let dropImgUrl = String(format:"%@public/images/dropoff_icon|",iApp.baseURL.rawValue)
        let positionOnMap = "&markers=size:mid|icon:" + pickupImgUrl + startlatlong
        let positionOnMap1 = "&markers=size:mid|icon:"  + dropImgUrl + droplatlong
        let staticImageUrl = mapUrl + positionOnMap + size + "&zoom=14" + positionOnMap1 + enc + key
        let urlStr = staticImageUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)! as String
        let url = URL(string: urlStr)
        return url
    }
    func storeRiderInfo(_ val : Bool){
        let preference = UserDefaults.standard
        if val{
            preference.set(self.rider_thumb_image, forKey: TRIP_RIDER_THUMB_URL)
            preference.set(self.rider_name, forKey: TRIP_RIDER_NAME)
            preference.set(self.rating_value, forKey: TRIP_RIDER_RATING)
        }else{
            preference.removeObject(forKey: TRIP_RIDER_THUMB_URL)
            preference.removeObject(forKey: TRIP_RIDER_NAME)
            preference.removeObject(forKey: TRIP_RIDER_RATING)
        }
    }
}
