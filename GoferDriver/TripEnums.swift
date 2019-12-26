//
//  TripEnums.swift
//  GoferDriver
//
//  Created by trioangle on 08/04/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation

enum TripStatus : String{
    case pending = "Pending"
    case cancelled = "Cancelled"
    case completed = "Completed"
    case rating = "Rating"
    case payment = "Payment"
    case request = "Request"
    case beginTrip = "Begin trip"
    case endTrip =  "End trip"
    case scheduled = "Scheduled"
    
    case manuallyBooked = "manual_booking_trip_assigned"
    case manuallyBookedReminder = "manual_booking_trip_reminder"
    case manualBookiingCancelled = "manual_booking_trip_canceled_info"
    case manualBookingInfo = "manual_booking_trip_booked_info"
}
enum BookingEnum : String{
    case schedule = "Schedule Booking"
    case auto = ""
    case manualBooking = "Manual Booking"
}

extension TripStatus{
    var getDisplayText : String{
        switch self {
        case .beginTrip:
            return "BEGIN TRIP".localize
        case .endTrip:
            return "END TRIP".localize
        case .scheduled:
            return "CONFIRM YOU'VE ARRIVED".localize
        default:
            return ""
        }
    }
}
