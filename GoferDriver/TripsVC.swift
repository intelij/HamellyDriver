/**
* TripsVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import MessageUI
import Social

class TripsVC : UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    @IBOutlet var collectionTrips: UICollectionView!
    @IBOutlet var viewNavHeader: UIView!
    @IBOutlet var viewTapper: UIView!
    @IBOutlet var lblNoTrips: UILabel!
    @IBOutlet var btnTodayTrip: UIButton!
    @IBOutlet var btnPastTrip: UIButton!
    
    var selectedCell : CustomTripsCell!
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var arrTripsData : NSMutableArray = NSMutableArray()
    // For API Calls
    var nPageNumber : Int = 1
    var isDataFinishedFromServer : Bool = false
    var isApiCalling : Bool = false
//    var pastTripsDict : NSMutableArray = NSMutableArray()
//    var todayTripsDict : NSMutableArray = NSMutableArray()
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    var strTripID = ""
    var pendingTripsDict = [[String:Any]]()
    var completedTripsDict = [[String:Any]]()
    var arrTemp1 : NSMutableArray = NSMutableArray()

    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnTodayTrip.isSelected = true
//        UIApplication.shared.statusBarStyle = .lightContent
        self.viewTapper.frame = CGRect(x:  self.viewTapper.frame.origin.x, y:self.viewTapper.frame.origin.y , width: self.view.frame.size.width / 2,height: self.viewTapper.frame.size.height);
        lblNoTrips.isHidden = true
        self.getTripsInfo()
        self.collectionTrips.delegate = self
        
        self.collectionTrips.dataSource = self
        self.collectionTrips.registerNib(ScheduledCCell())
        
        self.btnTodayTrip.setTitle("Pending Trips".localize, for: .normal)
        self.btnPastTrip.setTitle("Completed Trips".localize, for: .normal)
    }
    
    // MARK: API CALL - TRIPS INFO
    /*
       Here Getting Room List Details like -> Room Name, Room Thumb Image, Room id, Price
    */

    func getTripsInfo() {
        let paramDict = ["token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN),
                         "user_type" : "driver"] as [String : Any]
        WebServiceHandler.sharedInstance.getWebService(wsMethod:"driver-trips-history", paramDict: paramDict, viewController:self, isToShowProgress:true, isToStopInteraction:true) { (response) in
            let responseJson = response
            DispatchQueue.main.async {
                if responseJson["status_code"] as? String ?? String() == "1" {
                    self.pendingTripsDict = responseJson["pending_trips"] as! [[String:Any]]
                    self.completedTripsDict = responseJson["completed_trips"] as! [[String:Any]]
//                    dump(self.todayTripsDict)
//                    dump(self.pastTripsDict)
                    self.checkStatus()
                    self.collectionTrips.reloadData()
                }
                else {
                    self.appDelegate.createToastMessageForAlamofire(responseJson.status_message, bgColor: UIColor.black, textColor: UIColor.white, forView:self.view)
                }
                
            }
        }
    }

    // check the status if user have a trips or not
    func checkStatus()
    {
        if btnTodayTrip.isSelected
        {
            collectionTrips.isHidden = (pendingTripsDict.count > 0) ? false : true
            lblNoTrips.isHidden = (pendingTripsDict.count > 0) ? true : false
            lblNoTrips.text = NSLocalizedString("You have no today trips", comment: "")
        }
        else
        {
            collectionTrips.isHidden = (completedTripsDict.count > 0) ? false : true
            lblNoTrips.isHidden = (completedTripsDict.count > 0) ? true : false
            lblNoTrips.text = NSLocalizedString("You have no past trips", comment: "")
        }
        
    }
    
    //MARK: - TODAY OR PAST TRIPS BUTTON
    /*
     TAG - 11 ==> TODAY'S TRIP
     TAG - 22 ==> PAST TRIP
     */
    @IBAction func onTripsStatusTapped(_ sender:UIButton!)
    {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.viewTapper.frame = CGRect(x:  sender.frame.origin.x, y:self.viewTapper.frame.origin.y , width: self.viewTapper.frame.size.width,height: self.viewTapper.frame.size.height);
        }, completion: { (finished: Bool) -> Void in
        })
        
        if sender.tag == 11
        {
            btnTodayTrip.isSelected = true
            btnPastTrip.isSelected = false
            collectionTrips.isHidden = (pendingTripsDict.count > 0) ? false : true
            lblNoTrips.isHidden = (pendingTripsDict.count > 0) ? true : false
            lblNoTrips.text = NSLocalizedString("You have no today trips", comment: "")
        }
        else
        {
            btnTodayTrip.isSelected = false
            btnPastTrip.isSelected = true
            collectionTrips.isHidden = (completedTripsDict.count > 0) ? false : true
            lblNoTrips.isHidden = (completedTripsDict.count > 0) ? true : false
            lblNoTrips.text = NSLocalizedString("You have no past trips", comment: "")
        }
        
        collectionTrips.reloadData()
    }
    // MARK: - ViewController Methods
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .lightContent)
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    //MARK: - COLLECTION VIEW DELEGATE & DATASOURCE
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (btnTodayTrip.isSelected) ? pendingTripsDict.count : completedTripsDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionat section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        return CGSize(width: self.view.frame.width, height: 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let trip : RiderDetailModel
        if btnTodayTrip.isSelected{//today trips
            let tripJSON = pendingTripsDict[indexPath.item]
            trip = RiderDetailModel(withJson: tripJSON)
        }else{//Past Trips
            let tripJSON = completedTripsDict[indexPath.item]
            trip = RiderDetailModel(withJson: tripJSON)
        }
        if trip.booking_type == .manualBooking && trip.tripStatus == .pending{
            let cell = self.collectionTrips.generate(ScheduledCCell(), forIndex: indexPath)
            cell.populateCell(trip)
            return cell
        }else{//
            let cell = self.collectionTrips.generate(CustomTripsCell(), forIndex: indexPath)
            cell.populateCell(withTrip: trip)
            cell.rateYourRiderButton.addAction(for: .tap) {
                self.goToRatingVC(withTrip: trip)
            }
            return cell
        }
    }
    
    // MARK: CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let tripJSON : JSON
        if btnTodayTrip.isSelected{
            tripJSON = pendingTripsDict[indexPath.item]
        }else{
            tripJSON = completedTripsDict[indexPath.item]
        }
        let tripRider = RiderDetailModel(withJson: tripJSON)
        if tripRider.tripStatus == .rating{
            AppRouter(self).route2TripDetailsInfo(forTrip: tripRider)
        }else{
            AppRouter(self).routeInCompleteTrips(tripRider)
        }

    }
  

    func goToRatingVC(withTrip tripModel : RiderDetailModel){
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "RateYourRideVC") as! RateYourRideVC
        let id = tripModel.getTripID
        propertyView.strRiderImgUrl = tripModel.rider_thumb_image
        propertyView.strTripID = String(id)
        propertyView.isFromTripPage = true
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    //MARK: ACCEPT RIDER TRIP REQUEST
    func callRequestAcceptAPI(tripID: String)
    {
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        var dicts = [String: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["status"] = "Trip"
        dicts["trip_id"] = tripID
        UberAPICalls().PostRequest(dicts,methodName: METHOD_GET_RIDER_PROFILE as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let gModel = response as! RiderDetailModel
//            dump(response)
//            dump(gModel)
            OperationQueue.main.addOperation {
                if gModel.status_code == "1"
                {
                    self.gotoToRouteView(gModel)
                    let paymentmethod = gModel.payment_method
                    Constants().STOREVALUE(value: "Trip", keyname: USER_ONLINE_STATUS)
                    Constants().STOREVALUE(value: "Trip", keyname: TRIP_STATUS)
                    Constants().STOREVALUE(value:  paymentmethod, keyname: CASH_PAYMENT)
                }
                else
                {
                    if gModel.status_message == "user_not_found" || gModel.status_message == "token_invalid" || gModel.status_message == "Invalid credentials" || gModel.status_message == "Authentication Failed"
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
            OperationQueue.main.addOperation
                {
                    UberSupport().removeProgressInWindow(viewCtrl: self)
                    self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }
    
    // CHECKING TRIP STATUS
    func gotoToRouteView(_ riderProfileModel: RiderDetailModel)
    {
//        if riderProfileModel.trip_status == "Scheduled" || riderProfileModel.trip_status == "Begin trip" || riderProfileModel.trip_status == "End trip"
//        {
            let tripView = self.storyboard?.instantiateViewController(withIdentifier: "RouteVC") as! RouteVC
            tripView.strTripID = riderProfileModel.trip_id
            tripView.riderProfileModel = riderProfileModel
            tripView.strPickupLocation = riderProfileModel.pickup_location
//            tripView.strTripStatus = riderProfileModel.trip_status
            tripView.currentTripStatus = riderProfileModel.tripStatus
            tripView.isFromTripPage = true
            self.navigationController?.pushViewController(tripView, animated: true)
//        }
    }
    

    // MARK: When User Press Back Button

    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

