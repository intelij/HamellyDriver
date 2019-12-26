/**
* RatingsVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation
import MapKit

class RatingsVC : UIViewController,UITableViewDelegate, UITableViewDataSource,APIViewProtocol
{
    //MARK:- APIHandlers
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum) {
        switch response {
        case .driverStatus(let dStatus):
            self.appDelegate.createToastMessage(dStatus.getString)
            self.updateDriverStatus(dStatus: dStatus)
        default:
            print()
        }
    }
    
    func onFailure(error: String) {
        print(error)
    }
    //MARK:-
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var tblRatings: UITableView!
    @IBOutlet var lblCurrentRating: UILabel!
    @IBOutlet var lblLifeTimeTrips: UILabel!
    @IBOutlet var lblRatedTrips: UILabel!
    @IBOutlet var lblFiveStars: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet var viewTopHeader: UIView!
    @IBOutlet var lblOnlineStatus: UILabel!
    
    @IBOutlet weak var yourCurrentRatingLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel?
    var checkAvailabilityBtn = UIButton()
    
    let arrMenus: [String] = ["Trip History", "Pay Statements"]
    var status = ""
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        status = Constants().GETVALUE(keyname: TRIP_STATUS)
        switchButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        self.appDelegate.registerForRemoteNotification()        
        var rectTblView = tblRatings.frame
        rectTblView.size.height = self.view.frame.size.height-120
        tblRatings.frame = rectTblView
        self.callRatingAPI()
        self.checkAvailabilityBtn.addAction(for: .tap) {
            self.apiInteractor?.getResponse(for: .checkDriverStatus).shouldLoad(true)
        }
        self.lblCurrentRating.alpha = 0.0
        self.yourCurrentRatingLabel.transform = CGAffineTransform(translationX: 0, y: -50).concatenating(CGAffineTransform(scaleX: 1.2, y: 1.2))
        self.checkAvailabilityBtn.setTitle("Check Status".localize, for: .normal)
   }
    
    @IBAction func switchButtonAction(_ sender: Any) {
        
        if switchButton.isOn == true {
            print("On")
            Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
            Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
            lblOnlineStatus.text = NSLocalizedString("Online", comment: "")
            self.updateCurrentLocationToServer(status: "Online")
        }
        else {
            print("Off")
            Constants().STOREVALUE(value: "Offline", keyname: USER_ONLINE_STATUS)
            Constants().STOREVALUE(value: "Offline", keyname: TRIP_STATUS)
            lblOnlineStatus.text = NSLocalizedString("Offline", comment: "")
            self.updateCurrentLocationToServer(status: "Offline")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.tabBarController?.tabBar.isHidden = false
        self.updateDriverStatus()
        status = Constants().GETVALUE(keyname: TRIP_STATUS)
        self.updateCurrentLocationToServer(status: status)
//        self.lblCurrentRating.alpha = 0.0
//        self.yourCurrentRatingLabel.transform = CGAffineTransform(translationX: 0, y: -50).concatenating(CGAffineTransform(scaleX: 1.2, y: 1.2))
        self.callRatingAPI()
        if status ==  "Online"{
            lblOnlineStatus.text = "Online".localize
            switchButton.setOn(true, animated: false)
        }else if status == "Trip"{
            lblOnlineStatus.text = "Online".localize
            switchButton.setOn(true, animated: false)
        }
        else {
            lblOnlineStatus.text = "Offline".localize
            switchButton.setOn(false, animated: false)
        }
//        UberSupport().changeStatusBarStyle(style: .lightContent)
       
    }
    
    //check driver status
    
    func updateDriverStatus(dStatus : DriverStatus = .getStatusFromPreference())
    {
        let screenWidth = self.view.frame.width
        let buttonWidth : CGFloat  = 145
        let buttonHeight : CGFloat = 30
        self.checkAvailabilityBtn.frame = CGRect(x: screenWidth - buttonWidth - 5 ,
                                                 y: self.lblOnlineStatus.frame.midY + 5,
                                                 width: buttonWidth,
                                                 height: buttonHeight);
        self.checkAvailabilityBtn.titleLabel?.font = UIFont(name: iApp.GoferFont.bold.font,
                                                            size: 15)
        self.checkAvailabilityBtn.backgroundColor = UIColor.init(hex: "#CF2E11")
        self.checkAvailabilityBtn.setTitleColor(.white, for: .normal)
        self.checkAvailabilityBtn.setTitle("Check Status".localize, for: .normal)
        
        let status = Constants().GETVALUE(keyname: USER_STATUS)
        if dStatus != .active
        {
            self.view.addSubview(self.checkAvailabilityBtn)
            self.view.bringSubviewToFront(self.checkAvailabilityBtn)
            self.lblOnlineStatus.isHidden = true
            switchButton.isHidden = true
        }
        else
        {
            self.checkAvailabilityBtn.removeFromSuperview()
            self.lblOnlineStatus.isHidden = false
            switchButton.isHidden = false
        }
    }
    //MARK: - API CALL -> UPDATE DRIVER CURRENT LOCATION TO SERVER
    func updateCurrentLocationToServer(status: String)
    {
        var dicts = [AnyHashable: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["latitude"] = Constants().GETVALUE(keyname: USER_LATITUDE)
        dicts["longitude"] = Constants().GETVALUE(keyname: USER_LATITUDE)
        dicts["car_id"] = Constants().GETVALUE(keyname: USER_CAR_ID)
        dicts["status"] = status
        
        UberAPICalls().GetRequest(dicts,methodName:METHOD_UPDATING_DRIVER_LOCATION as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let endModel = response as! GeneralModel
            
            OperationQueue.main.addOperation {
                if endModel.status_code == "1"
                {
                }
                else
                {
                    if endModel.status_message.lowercased() == "please complete your current trip" && self.status != "Trip"
                    {
                        let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Message!!!", comment: ""), message:endModel.status_message, preferredStyle:UIAlertController.Style.alert)
                        settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
                        }))
                        UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
                    }
                    else if self.status != "Trip"
                    {
                        self.appDelegate.createToastMessage(endModel.status_message, bgColor: UIColor.black, textColor: UIColor.white)
                    }
                    if endModel.status_message == "user_not_found" || endModel.status_message == "token_invalid" || endModel.status_message == "Invalid credentials" || endModel.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                        
                    }
                    else{
                    }
                    
                }
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }


    //MARK: - API CALL -> GETTING OVARALL RATING INFO
    func callRatingAPI()
    {
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)        
        var dicts = [AnyHashable: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["user_type"] =  "driver"
        UberAPICalls().GetRequest(dicts,methodName:METHOD_RATING as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let rateModel = response as! RatingModel
            
            OperationQueue.main.addOperation {
                if rateModel.status_code == "1"
                {
                    self.setRatingHeaderInfo(rateModel)
                }
                else
                {
                    if rateModel.status_message == "user_not_found" || rateModel.status_message == "token_invalid" || rateModel.status_message == "Invalid credentials" || rateModel.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                    }
                    else{
                    
                    }
                }
                UberSupport().removeProgressInWindow(viewCtrl: self)
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                UberSupport().removeProgressInWindow(viewCtrl: self)
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }
    
    func setRatingHeaderInfo(_ ratingModel: RatingModel)
    {
        if ratingModel.driver_rating != "0.00" && ratingModel.driver_rating != "" {
            yourCurrentRatingLabel.isHidden = false
            starLabel?.isHidden = false
            lblCurrentRating.isHidden = false
            UIView.animateKeyframes(withDuration: 0.8,
                                    delay: 0,
                                    options: [.layoutSubviews], animations: {
                                       
                                        UIView.addKeyframe(withRelativeStartTime: 0.6,
                                                           relativeDuration: 0.4,
                                                           animations: {
                                                            
                                                            self.lblCurrentRating.alpha = 1.0

                                        })
                                        UIView.addKeyframe(withRelativeStartTime: 0,
                                                           relativeDuration: 1.0,
                                                           animations: {
                                                            self.yourCurrentRatingLabel.transform = .identity
                                        })
            }) { (finished) in
            }
//            UIView.animate(withDuration: 1, delay: 0.4, options: [.curveEaseOut,.curveEaseIn], animations: {
//                self.lblCurrentRating.isHidden = true
//                self.yourCurrentRatingLabel.transform = CGAffineTransform(translationX: 0, y: -50).concatenating(CGAffineTransform(scaleX: 1.2, y: 1.2))
//            }, completion: {(bool) in
//                self.lblCurrentRating.isHidden = false
//                self.yourCurrentRatingLabel.transform = .identity
//            })
            
            if appDelegate.language != "ar" && appDelegate.language != "fa" {
                let strUberName = UberSupport().createAttributUserName(originalText: String(format:"i %@",ratingModel.driver_rating) as NSString, normalText: String(format:"i %@",ratingModel.driver_rating) as NSString, textColor: lblCurrentRating.textColor, boldText: "i", fontSize: 54.0)
                lblCurrentRating.attributedText = strUberName
            }
            else{
                lblCurrentRating.text = "\(ratingModel.driver_rating)"
            }
            
        }else {
            lblCurrentRating.isHidden = true
            yourCurrentRatingLabel.isHidden = false
            starLabel?.isHidden = true
//            UIView.animateKeyframes(withDuration: 2,
//                                    delay: 0,
//                                    options: [.layoutSubviews], animations: {
//                                        UIView.addKeyframe(withRelativeStartTime: 0,
//                                                           relativeDuration: 0.4,
//                                                           animations: {
//                                                            self.yourCurrentRatingLabel.transform = .identity
//                                        })
//                                        UIView.addKeyframe(withRelativeStartTime: 0.4,
//                                                           relativeDuration: 0.6,
//                                                           animations: {
//                                                            self.yourCurrentRatingLabel.transform = CGAffineTransform(translationX: 0, y: -50).concatenating(CGAffineTransform(scaleX: 1.2, y: 1.2))
//                                        })
//            }) { (finished) in
//
//            }
            
            yourCurrentRatingLabel.text = "You have no rating to display".localize
        }
       
        lblLifeTimeTrips.text = ratingModel.total_rating_count
        lblRatedTrips.text = ratingModel.total_rating
        lblFiveStars.text = ratingModel.five_rating_count
    }

    // MARK: UITableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellEarnItems = tblRatings.dequeueReusableCell(withIdentifier: "CellEarnItems") as! CellEarnItems
        return cell
    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)

        let tripView = self.storyboard?.instantiateViewController(withIdentifier: "RatingDetailVC") as! RatingDetailVC
        self.navigationController?.pushViewController(tripView, animated: true)
    }
}
