//
//  AppRouter.swift
//  GoferDriver
//
//  Created by trioangle on 28/05/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation
import Alamofire


class AppRouter : APIViewProtocol{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum) {
        switch response {
        case .RiderModel(let driver):
            dump(driver)
            self.routeInCompleteTrips(driver)
        default:
            print()
        }
    }
    
    func onFailure(error: String) {
        print(error)
    }
    
    //MARK:- local variables
    fileprivate let currentViewController : UIViewController
    //MARK:- initalizers
    init(_ currentVC : UIViewController){
        self.currentViewController = currentVC
        self.apiInteractor = APIInteractor(self)
    }
    
    
}
extension AppRouter{
    //MARK:- UDF APIHandling
    func getInvoiceAndRoute(forTrip trip : RiderDetailModel){
        var params = Parameters()
        params["trip_id"] = trip.getTripID
        self.apiInteractor?.getResponse(forAPI: APIEnums.getInvoice, params: params).shouldLoad(true)
    }
}


extension AppRouter{
    //MARK:- UDF ROUTERS
    
    func getPaymentInvoiceAndRoute(_ trip : RiderDetailModel){
        var params = Parameters()
        params["trip_id"] = trip.getTripID
        self.apiInteractor?.getResponse(forAPI: .getInvoice, params: params).shouldLoad(true)
    }
    
    //MARK: Redierect to incomplet trips
    func routeInCompleteTrips(_ trip : RiderDetailModel){
        switch trip.tripStatus {
        case .rating:
            self.route2Rating(forTrip: trip)
        case .cancelled,.completed:
            self.route2TripDetailsInfo(forTrip: trip)
        case .payment:
          self.route2Payment(forTrip: trip)
        case .scheduled,.beginTrip,.endTrip:
            self.route2TripScreen(forTrip: trip)
        default:
            print("")
        }
        
    }
    func route2TripScreen(forTrip trip: RiderDetailModel)
    {
        
        if !trip.pickup_latitude.isEmpty,
            !trip.pickup_longitude.isEmpty{
            let preference = UserDefaults.standard
            preference.set("\(trip.pickup_latitude),\(trip.pickup_longitude)", forKey: PICKUP_COORDINATES)
            //preference.set(rider.pickup_latitude)
        }
        let tripView = Stories.main.instance.instantiateViewController(withIdentifier: "RouteVC") as! RouteVC
        tripView.strTripID = trip.trip_id
        tripView.riderProfileModel = trip
        tripView.strPickupLocation = trip.pickup_location
        //            tripView.strTripStatus = riderProfileModel.trip_status
        tripView.currentTripStatus = trip.tripStatus
        tripView.isFromTripPage = true
        self.currentViewController.navigationController?.pushViewController(tripView, animated: true)
        
    }
    
    
    func route2Payment(forTrip trip : RiderDetailModel){
        let tripView = Stories.main.instance.instantiateViewController(withIdentifier: "MakePaymentVC") as! MakePaymentVC
        tripView.arrInfoKey = NSMutableArray(array: trip.invoices.compactMap({$0 as Any}))
        tripView.payment_method = trip.getPaymentMethod
        tripView.totalAmt = trip.getPayableAmount
        tripView.strTripID = trip.getTripID
        tripView.isFromTripPage = true
        self.currentViewController.navigationController?.pushViewController(tripView, animated: true)
    }
    func route2Rating(forTrip trip : RiderDetailModel){
        let propertyView = Stories.main.instance.instantiateViewController(withIdentifier: "RateYourRideVC") as! RateYourRideVC
        let id = trip.getTripID
        propertyView.strRiderImgUrl = trip.rider_thumb_image
        propertyView.strTripID = String(id)
        propertyView.isFromTripPage = true
        self.currentViewController.navigationController?.pushViewController(propertyView, animated: true)
    }
    func route2TripDetailsInfo(forTrip trip : RiderDetailModel){
        let propertyView = Stories.main.instance.instantiateViewController(withIdentifier: "NewTripsDetailsVC") as! NewTripsDetailsVC
        //propertyView.tripsDict = pendingTripsDict
        propertyView.riderModel = trip
        propertyView.arrInfoKey = NSMutableArray(array: trip.invoices.compactMap({$0 as Any}))
        self.currentViewController.navigationController?.pushViewController(propertyView, animated: true)
        
    }
}

extension UIViewController {
    
}
