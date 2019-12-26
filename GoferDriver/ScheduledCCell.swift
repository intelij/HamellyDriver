//
//  ScheduledCCell.swift
//  GoferDriver
//
//  Created by trioangle on 11/05/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import UIKit

class ScheduledCCell: UICollectionViewCell,ProjectCell {
    typealias myCell = ScheduledCCell
    var identifier: String  {return String(describing: ScheduledCCell.self)}
    
    @IBOutlet weak var holderView : UIView!
    
    @IBOutlet weak var statusLbl : UILabel!
    @IBOutlet weak var scheduledTimeLbl : UILabel!
    @IBOutlet weak var descriptionDetailLbl : UILabel!
    
    @IBOutlet weak var fromPinView : UIView!
    @IBOutlet weak var toPinView : UIView!
    @IBOutlet weak  var pointingView : UIView!
    
    @IBOutlet weak var fromLocationLbl : UILabel!
    @IBOutlet weak var toLoactionLbl : UILabel!
    
    @IBOutlet weak var tripIDLbl : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func populateCell(_ trip : RiderDetailModel){
        self.statusLbl.text = trip.booking_type.rawValue
        self.scheduledTimeLbl.text = trip.schedule_date + " " + trip.schedule_time
        self.descriptionDetailLbl.text = trip.status.localize
        
        self.fromLocationLbl.text = trip.pickup_location
        self.toLoactionLbl.text = trip.drop_location
        
        self.tripIDLbl.text = "Trip ID : "+trip.getTripID
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.connectFromToView()
            self.holderView.elevate(0.25)
        }
    }
    private func connectFromToView(){
        self.fromPinView.backgroundColor = .ThemeMain
        self.toPinView.backgroundColor = .ThemeMain
        
        self.pointingView.backgroundColor = .ThemeInactive
        
        self.fromPinView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.toPinView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
}
