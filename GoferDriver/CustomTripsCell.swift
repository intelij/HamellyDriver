/**
* CustomTripsCell.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/


import UIKit

class CustomTripsCell: UICollectionViewCell,ProjectCell {
    var identifier: String{return "Cell"}
    
   typealias myCell = CustomTripsCell
   
    @IBOutlet weak var  bgView : UIView?
    @IBOutlet var imgMapView: UIImageView?
    @IBOutlet var lblTripTime: UILabel?
    @IBOutlet var lblCost: UILabel?
    @IBOutlet var lblCarType: UILabel?
    @IBOutlet var lblTripStatus: UILabel?    
    
    var rateYourRiderButton = UIButton()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.rateYourRiderButton.removeFromSuperview()
    }
    
    
    func mapImage(ImgString:String){
        
    }
    func attachRatingButton(_ attach : Bool){
        self.rateYourRiderButton.removeFromSuperview()
        if attach{
            let additionalWidth : CGFloat = 27
            let reductionHeight : CGFloat = 5
            self.rateYourRiderButton.setTitle("Rate Your Ride".localize, for: .normal)
            self.rateYourRiderButton.titleLabel?.font = self.lblTripStatus?.font
            self.rateYourRiderButton.backgroundColor = .ThemeMain
            self.rateYourRiderButton.layer.cornerRadius = reductionHeight
            self.rateYourRiderButton.clipsToBounds = true
            self.rateYourRiderButton.elevate(1.5)
            
            guard let referenceFrame = self.lblTripStatus?.frame else{return}
            self.rateYourRiderButton.frame = CGRect(x: referenceFrame.minX - additionalWidth,
                                                        y: referenceFrame.minY + reductionHeight,
                                                        width: referenceFrame.width + additionalWidth,
                                                        height: referenceFrame.height)
            
            self.addSubview(self.rateYourRiderButton)
            self.bringSubviewToFront(self.rateYourRiderButton)
        }
        
    }
    func populateCell(withTrip trip : RiderDetailModel ){
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.attachRatingButton(trip.tripStatus == .rating)
        }
        let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
      
        self.lblTripStatus?.text = NSLocalizedString(trip.status, comment: "")
        let msg1 = NSLocalizedString("Trip ID:", comment: "")
        self.lblTripTime?.text = "\(msg1)\(trip.id)"
        if Constants.userDefaults.bool(forKey: IS_COMPANY_DRIVER) {
            self.lblCost?.text = String(format:"%@", trip.sub_total_fare)
        }else {
            self.lblCost?.text = String(format:"%@ %@", strCurrency, trip.driver_payout)
        }
        
        self.lblCarType?.text = NSLocalizedString(trip.vehicle_name, comment: "")
        if !trip.map_image.isEmpty{
            self.imgMapView?
                .sd_setImage(with: URL(string: trip.map_image),    placeholderImage:UIImage(named:""))
        }
        else{
            
            self.imgMapView?
                .sd_setImage(with: trip.getGooglStaticMap,
                             placeholderImage:UIImage(named:""))
        }
        
    }
}
