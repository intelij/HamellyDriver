/**
* RiderProfileVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation
import MapKit

class RiderProfileVC : UIViewController,UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var tblRiderProfile: UITableView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblRiderAddress: UILabel!
    @IBOutlet var lblVehicleName: UILabel!
    @IBOutlet var lblRiderRating: UILabel!
    @IBOutlet var viewDot: UIView!
    @IBOutlet var viewTopHeader: UIView!
    @IBOutlet var viewDotLine: UIView!
    @IBOutlet var imgRiderThumb: UIImageView!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var lblCancel: UILabel!
    @IBOutlet var lblCancelIcon: UILabel!
    @IBOutlet var car_image : UIImageView!

    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var isTripStarted : Bool = false

    let arrMenus: [String] = ["Help", "Documents", "About"]
    var riderProfileModel : RiderDetailModel!
    
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        viewDot.layer.cornerRadius = viewDot.frame.size.width/2
        lblRiderRating.layer.cornerRadius = 4
        lblRiderRating.clipsToBounds = true        
        if isTripStarted
        {
            lblCancelIcon.textColor = UIColor.ThemeInactive
            lblCancel.textColor = UIColor.ThemeInactive
            btnCancel.isUserInteractionEnabled = false
        }
        if riderProfileModel != nil
        {
            self.setRiderInfo()
        }
    }
    
    //SETTING RIDER INFO FROM END TRIP API CALL
    func setRiderInfo()
    {
        lblUserName.text = riderProfileModel.rider_name
        let width = UberSupport().onGetStringWidth(lblUserName.frame.size.width, strContent: lblUserName.text! as NSString, font: lblUserName.font)
        
        var rectLblName = lblUserName.frame
        if width > self.view.frame.size.width - 100 - rectLblName.origin.x - 60
        {
            rectLblName.size.width = self.view.frame.size.width /*- 100*/ - rectLblName.origin.x - 60
        }
        else
        {
            rectLblName.size.width = width
        }
        lblUserName.frame = rectLblName
        self.car_image.sd_setImage(with: URL(string :riderProfileModel.car_active_image) )
//        var rectLblRating = lblRiderRating.frame
//        rectLblRating.origin.x = rectLblName.size.width + rectLblName.origin.x + 4
//        lblRiderRating.frame = rectLblRating
        
        if riderProfileModel.rating_value == "0" || riderProfileModel.rating_value == "0.0" || riderProfileModel.rating_value == "0.00" || riderProfileModel.rating_value == ""
        {
            lblRiderRating.isHidden = true
            lblRiderRating.text = ""
        }
        else
        {
            lblRiderRating.isHidden = true//false
            let strUberName = UberSupport().createAttributUserNameStar(originalText: String(format:"%@ i",riderProfileModel.rating_value) as NSString, normalText: String(format:"%@ i",riderProfileModel.rating_value) as NSString, textColor: UIColor.white, boldText: "i", fontSize: 14.0)
            lblRiderRating.attributedText = strUberName
        }
        lblRiderAddress.text = riderProfileModel.pickup_location
        lblVehicleName.text = riderProfileModel.car_type
        imgRiderThumb.sd_setImage(with: NSURL(string: riderProfileModel.rider_thumb_image)! as URL, placeholderImage:UIImage(named:""))
    }

    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UIApplication.shared.statusBarStyle = .lightContent
//        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
//        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
//            statusBar.backgroundColor = UIColor(red: 0.0 / 255.0, green: 158.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
//        }

        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - NAVIGATE TO RIDER CONTACT VC
    @IBAction func onContactTapped()
    {
        let contactView = self.storyboard?.instantiateViewController(withIdentifier: "RiderContactVC") as! RiderContactVC
        contactView.riderModel = riderProfileModel
        contactView.strContactNo = riderProfileModel.mobile_number
        contactView.strRiderName = riderProfileModel.rider_name
        contactView.trip_id = riderProfileModel.trip_id
        contactView.driverimage = self.imgRiderThumb.image ?? UIImage(named: "user_dummy.png")!
        self.navigationController?.pushViewController(contactView, animated: true)
    }

    //MARK: - NAVIGATE TO CANCEL TRIP
    @IBAction func onCancelTapped()
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "CancelRideVC") as! CancelRideVC
        propertyView.strTripId = riderProfileModel.trip_id
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: UITableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellRiderInfo = tblRiderProfile.dequeueReusableCell(withIdentifier: "CellRiderInfo") as! CellRiderInfo
        cell.viewDot.layer.cornerRadius = cell.viewDot.frame.size.width / 2
        cell.viewDot.layer.borderColor = UIColor.red.cgColor
        cell.viewDot.layer.borderWidth = 2.0
        cell.lblRiderName.text = riderProfileModel.drop_location
        return cell
    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    { 
    }
}

class CellRiderInfo: UITableViewCell
{
    @IBOutlet var lblRiderName: UILabel!
    @IBOutlet var viewDot: UIView!
}
