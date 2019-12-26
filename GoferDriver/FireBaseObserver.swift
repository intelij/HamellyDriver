//
//  FireBaseObserver.swift
//  GoferDriver
//
//  Created by trioangle on 04/06/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

enum FireBaseNode : String{
    case rider = "Rider"
    case driver = "Driver"
    case trip = "Trip"
    
    func ref(forID : String) -> DatabaseReference{
        return Database.database()
            .reference()
            .child(self.rawValue)
            .child(forID)
    }
}

class FIRObserver{
    
    private init(){}
    static let instance = FIRObserver()
    
    private var driverRefernce : DatabaseReference?
    private var tripReference : DatabaseReference?
    
    func initialize(_ node : FireBaseNode,forID id : String){
        if node == .rider{
            self.driverRefernce = node.ref(forID: id)
        }else{
            self.tripReference = node.ref(forID: id)
        }
    }
    func startObservingRider(_ node: FireBaseNode){
        let reference : DatabaseReference?
        reference = node == .rider ? self.driverRefernce : self.tripReference
        guard reference != nil else{return}
        reference!.observe(DataEventType.childChanged,
                           with : { (snapShot) in
                            guard let snapShotJSON = snapShot as? JSON else{return}
                            self.handleValueChange(forNode: node, snapShotJSON: snapShotJSON)
        })
    }
    func stopObservingRider(_ node : FireBaseNode){
        switch node {
        case .rider:
            driverRefernce?.removeAllObservers()
        case .driver:
            break
        case .trip:
            tripReference?.removeAllObservers()
            
        }
        
    }
    func update(_ node : FireBaseNode,with model : FIRModel){
        switch node {
        case .rider:
            driverRefernce?.updateChildValues(model.updateValue)
        case .driver:
            break
        case .trip:
            break
            
        }
    }
    
    func handleValueChange(forNode node : FireBaseNode,snapShotJSON : JSON){
        let firRider = RiderDetailModel(withJson: snapShotJSON)// FIRDriverModel(withJson: snapShotJSON)
        switch node {
        case .rider:
//            if !firRider.getTripID.isEmpty && !AppRouter.isVCForStatusExists(TripStatus.beginTrip){
//                Shared.instance.resumeTripHitCount = 0
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.onSetRootViewController(viewCtrl: nil)
//            }
            break
        case .trip:
            break
        case .driver:
            break
        }
    }
}


///////
////////////
/////////////////
/////////////////////
////////////////////////////
//////////////////////////////////
