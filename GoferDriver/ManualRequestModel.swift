//
//  ManualRequestModel.swift
//  GoferDriver
//
//  Created by trioangle on 05/04/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation

class ManualRequestModel{
    var tripStatus : TripStatus = .manuallyBooked
    var date = String()
    var time = String()
    lazy var displayTime : String = {self.date + " - " + self.time}()
    var riderCountryCode = String()
    var riderPhoneNo = String()
    lazy var displayNumber : String = {
        if self.tripStatus == .manualBookiingCancelled{
            return "XX XXXXXXXXXX"
        }else{
            return self.riderCountryCode + " - " + self.riderPhoneNo
        }
    }()
    var pickup_lat = String()
    var pickup_lon = String()
    lazy var pickUpLocation : CLLocation = {
        if let lat = Double(self.pickup_lat),
            let lon = Double(self.pickup_lon){
            return CLLocation(latitude: lat, longitude: lon)
        }else{
            return CLLocation()
        }
    }()
    var pickUpAddress = String()
    var riderFname = String()
    var riderLname = String()
    lazy var riderFullName : String = {
        var fullName = String()
        if !self.riderFname.isEmpty{
            fullName.append(self.riderFname+" ")
        }
        if !self.riderLname.isEmpty{
            fullName.append(self.riderLname)
        }
        return fullName
    }()
    init(_ json : JSON){
        self.date = json.string("date")
        self.time = json.string("time")
        self.riderCountryCode = json.string("rider_country_code")
        self.riderPhoneNo = json.string("rider_mobile_number")
        self.pickup_lat = json.string("pickup_latitude")
        self.pickup_lon = json.string("pickup_longitude")
        self.pickUpAddress = json.string("pickup_location")
        self.riderFname = json.string("rider_first_name")
        self.riderLname = json.string("rider_last_name")
    }
}
