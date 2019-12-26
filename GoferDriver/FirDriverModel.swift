//
//  FirDriverModel.swift
//  GoferDriver
//
//  Created by trioangle on 04/06/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation
protocol FIRModel {
    var updateValue : [AnyHashable:Any]{get}
    
}

extension RiderDetailModel : FIRModel{
    var updateValue: [AnyHashable:Any]{
        return ["trip_id":self.getTripID]
    }
    
}

