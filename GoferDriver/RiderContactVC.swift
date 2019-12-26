/**
* RiderContactVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation
import MapKit

class RiderContactVC : UIViewController
{
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblPhoneNo: UILabel!
    
    @IBOutlet weak var messageView : UIView?
    @IBOutlet weak var callView : UIView?
    
    var riderModel : RiderDetailModel?
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var strContactNo = ""
    var strRiderName = ""
    var strRatingValue = ""
    var driverimage  =  UIImage(named: "user_dummy.png")!
    var trip_id = "blah"
    
    // MARK: - ViewController Methods
    override func viewWillAppear(_ animated: Bool) {
        
//        UIApplication.shared.statusBarStyle = .lightContent
//        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
//        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
//            statusBar.backgroundColor = UIColor(red: 0.0 / 255.0, green: 158.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
//        }
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        lblPhoneNo.text = strContactNo
        lblUserName.text = strRiderName
        if self.riderModel?.booking_type == BookingEnum.manualBooking{
            self.messageView?.isHidden = true
        }else{
            self.messageView?.isHidden = false
        }
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: When User Press CALL button
    @IBAction func onCallTapped()
    {
        if let phoneCallURL:NSURL = NSURL(string:"tel://\(strContactNo)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL as URL)) {
                application.openURL(phoneCallURL as URL);
            }
        }
    }
    @IBAction func onMessageTapped(){
        let chatVC = ChatVC.initWithStory(withTripId: self.trip_id)
        chatVC.riderImage = self.driverimage
        chatVC.ridername = self.strRiderName
        chatVC.rating = Double(self.strRatingValue) ?? 0.0
        self.present(chatVC, animated: true, completion: nil)
    }
}
