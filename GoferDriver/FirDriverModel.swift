//
//  FirDriverModel.swift
//  GoferDriver
//
//  Created by trioangle on 04/06/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation
protocol FIRModel {
    var updateValue : [String:Any]{get}
    
}

extension RiderDetailModel : FIRModel{
    var updateValue: [String:Any]{
        return ["trip_id":self.getTripID]
    }
    
}

