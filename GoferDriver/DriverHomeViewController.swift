/**
 * DriverHomeViewController.swift
 *
 * @package GoferDriver
 * @author Trioangle Product Team
 * @version - Stable 1.0
 * @link http://trioangle.com
 */

import UIKit
import AVFoundation
import Foundation
import CoreLocation
import GoogleMaps

class DriverHomeViewController : UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate,ARCarMovementDelegate,APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum) {
        switch response {
        case .RiderModel(let rider):
            dump(rider)
            if rider.tripStatus == .payment{
                AppRouter(self).getInvoiceAndRoute(forTrip: rider)
            }else{
                AppRouter(self).routeInCompleteTrips(rider)
            }
        case .driverStatus(let dStatus):
            if self.showDriverStatusToast{
                self.showDriverStatusToast = false
                self.appDelegate.createToastMessage(dStatus.getString)
            }
//            self.updateDriverStatus(dStatus: dStatus)
        default:
            print()
        }
    }
    
    func onFailure(error: String) {
        print(error)
    }
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var viewTopHeader: UIView!
    @IBOutlet var lblOnlineStatus: UILabel!
    @IBOutlet var googleMap: GMSMapView!
    @IBOutlet var btnCheckStatus: UIButton!
    @IBOutlet weak var switchButton: UISwitch!

    var locationManager: CLLocationManager!
    var strLatitude = ""
    var strLongitude = ""
    var isCurrentLocationGot : Bool = false
    var strDriverLatitude = ""
    var strDriverLongitude = ""
    var strStatus = ""
    
    var timerDriverLocation = Timer()
    var isInBackground : Bool = false
    var isRequestPageCalled : Bool = false
    var isTimerStopped : Bool = false

    var driverMarker: GMSMarker!
    var moveMent: ARCarMovement!
    var oldCoordinate: CLLocationCoordinate2D!
    var status = ""
    var showDriverStatusToast = false
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        if Shared.instance.resumeTripHitCount == 0{
            self.apiInteractor?.getResponse(for: .inCompleteTrips).shouldLoad(false)
        }
        self.apiInteractor?.getResponse(for: .checkDriverStatus).shouldLoad(false)
        
        status = Constants().GETVALUE(keyname: TRIP_STATUS)
        switchButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//        self.appDelegate.registerForRemoteNotification()
        let frame = CGRect(x: 0, y: googleMap.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height - googleMap.frame.origin.y - 50)
        googleMap.frame = frame
        onChangeMapStyle()
        moveMent = ARCarMovement()
        moveMent.delegate = self
        self.updateCurrentLocation()

        NotificationCenter.default.addObserver(self, selector: #selector(self.getDriverDetails), name: NSNotification.Name(rawValue: "ResquestRide"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showThisPage), name: NSNotification.Name(rawValue: "ShowHomePage"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getPaymentSuccess), name: NSNotification.Name(rawValue: "PaymentSuccess"), object: nil)
        _ = PipeAdapter.createEvent(withName: "PaymentSuccess", dataAction: { (data) in
            if let json = data as? JSON{
                self.onPaymentSucces(json)
            }
        })
        NotificationCenter.default.addObserver(self, selector: #selector(self.riderCancelledTrip), name: NSNotification.Name(rawValue: "cancel_trip"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.driverCancelledTrip), name: NSNotification.Name(rawValue: "cancel_trip_by_driver"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.startLocationUpdate), name: NSNotification.Name(rawValue: "handle_timer"), object: nil)
    }
    
    @IBAction func switchButtonAction(_ sender: Any) {
         lblOnlineStatus.text = NSLocalizedString("Online", comment: "")
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
    func gotoRateYourRatingPage(withRiderImage imgURL : String,tripId : String)
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "RateYourRideVC") as! RateYourRideVC
        propertyView.strRiderImgUrl = imgURL
        propertyView.strTripID = tripId
        propertyView.isFromRoutePage = true
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    // If the user doesn't add the payout email id, we have to show add payment page
    func showPayoutPage()
    {
        if Constants().GETVALUE(keyname: USER_PAYPAL_EMAIL_ID).count == 0
        {
            let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "AddPaymentVC") as! AddPaymentVC
            propertyView.isFromHomePage = true
            self.navigationController?.pushViewController(propertyView, animated: false)
        }
    }
    
    /*
     WHEN USER DECLINING THE REQUEST - WE SHOULD START TIMER
     */
    @objc func startLocationUpdate()
    {
        isTimerStopped = false
        let status = Constants().GETVALUE(keyname: TRIP_STATUS)
        updateCurrentLocationToServer(status: status)
        timerDriverLocation.invalidate()
        timerDriverLocation = Timer.scheduledTimer(timeInterval: 10.00, target: self, selector: #selector(self.updateCurrentToServer), userInfo: nil, repeats: false)
    }
    
    
    //MARK: - PUSH NOTIFICATION - > CANCEL
    /*
     WHEN RIDER CANCEL THE TRIP
     */
    @objc func riderCancelledTrip(notification: Notification)
    {
        timerDriverLocation.invalidate()
        self.startLocationUpdate()        
        let settingsActionSheet: UIAlertController = UIAlertController(title: NSLocalizedString("Message!!!", comment: ""), message: NSLocalizedString("Trip cancelled by rider", comment: ""), preferredStyle:UIAlertController.Style.alert)
        
        settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
            
            Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
            Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
            self.appDelegate.onSetRootViewController(viewCtrl: self)
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
    }
    
    //MARK: - > CANCEL
    /*
     WHEN Driver CANCEL THE TRIP
     */
    @objc func driverCancelledTrip(notification: Notification)
    {
        timerDriverLocation.invalidate()
        Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
        Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancel_trip_driver"), object: self, userInfo: nil)
        self.startLocationUpdate()
    }
    
    // CHECKING TRIP STATUS
    func gotoToRouteView(_ riderProfileModel: RiderDetailModel)
    {
        
            let tripView = self.storyboard?.instantiateViewController(withIdentifier: "RouteVC") as! RouteVC
            tripView.strTripID = riderProfileModel.trip_id
            tripView.riderProfileModel = riderProfileModel
            tripView.strPickupLocation = riderProfileModel.pickup_location
            //tripView.strTripStatus = riderProfileModel.trip_status
            tripView.currentTripStatus = riderProfileModel.tripStatus
            tripView.isFromTripPage = true
            self.navigationController?.pushViewController(tripView, animated: true)
        
       
    }
    //MARK: - PUSH NOTIFICATION - > PAYMENT
    /*
     WHEN RIDER SUCCESSFULLY PAY THE PAYMENT
     */
    @objc func getPaymentSuccess(_ notificaiton : Notification)
    {
        Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
        Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
        self.startLocationUpdate()
        let userData = notificaiton.userInfo
        let riderImage = userData?["rider_thumb_image"] as? String ?? String()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PaymentSuccessInHomeAlert"), object: self, userInfo: notificaiton.userInfo)
        let settingsActionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Rider successfully paid", comment: ""), preferredStyle:UIAlertController.Style.alert)
        
        settingsActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
            self.gotoRateYourRatingPage(withRiderImage: riderImage,tripId: "")
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
    }
    
    func onPaymentSucces(_ json : JSON){
        Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
        Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
        self.startLocationUpdate()
        let riderImage = json.string("rider_thumb_image")
        let tripId = json.string("trip_id")
        let settingsActionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Rider successfully paid", comment: ""), preferredStyle: .alert)
        
            settingsActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .cancel, handler:{ action in
            self.gotoRateYourRatingPage(withRiderImage: riderImage,tripId: tripId)
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.tabBarController?.tabBar.isHidden = false
        isRequestPageCalled = false
        status = Constants().GETVALUE(keyname: TRIP_STATUS)
        self.updateCurrentLocationToServer(status: status)
        if status ==  "Online"{
            switchButton.setOn(true, animated: false)
            lblOnlineStatus.text  = "Online".localize
        }else if status == "Trip"{
            switchButton.setOn(true, animated: false)
            lblOnlineStatus.text  = "Online".localize
        }else {
            switchButton.setOn(false, animated: false)
            lblOnlineStatus.text  = "Offline".localize
        }
        self.updateDriverStatus()
//        UberSupport().changeStatusBarStyle(style: .lightContent)
       
    }
    
    @objc func showThisPage(notification: Notification)
    {
        timerDriverLocation.invalidate()
        self.appDelegate.onSetRootViewController(viewCtrl: self)
        return
//        if let viewControllers = self.navigationController?.viewControllers.filter({$0 is DriverHomeViewController}).first{
//            self.navigationController?.popToViewController(viewControllers, animated: true)
//        }else {
//          self.appDelegate.onSetRootViewController(viewCtrl: self)
//          return
//        }
//        for i in 0 ..< viewControllers.count
//        {
//            let obj = viewControllers[i]
//            if obj is DriverHomeViewController
//            {
//                self.navigationController?.popToViewController(obj, animated: true)
//            }
//        }
    }
    // Check the Driver status utton
    func updateDriverStatus(dStatus : DriverStatus = .getStatusFromPreference())
    {
    
        let status = Constants().GETVALUE(keyname: USER_STATUS)
      
        if dStatus != .active
        {
            self.btnCheckStatus.isHidden = false
            self.lblOnlineStatus.isHidden = true
            switchButton.isHidden = true
//            self.btnCheckStatus.isHidden = true
//                      self.lblOnlineStatus.isHidden = false
//                      switchButton.isHidden = false
        }
        else
        {
            self.btnCheckStatus.isHidden = true
            self.lblOnlineStatus.isHidden = false
            switchButton.isHidden = false
        }
    }
    
    //MARK: CHECK DRIVER STATUS
    /*
     AFTER SUBMITTING ALL DOCUMENTS
     WHEN GETTING STATUS IS ACTIVE - DRIVER WILL GO ONLINE
     */
    @IBAction func callCheckDriverStatus()
    {
        self.showDriverStatusToast = true
       self.apiInteractor?.getResponse(for: .checkDriverStatus).shouldLoad(false)
    }
    
    // MARK: WHEN WE WILL GET PUSH NOTIFICATION
    /*
     WHEN RIDER REQUEST TO RIDE
     */
    @objc func getDriverDetails(notification: Notification)
    {
        isTimerStopped = true
        
        timerDriverLocation.invalidate()

        if isRequestPageCalled
        {
            return
        }

        isRequestPageCalled = true
        let str2 = notification.userInfo
        let viewRequest = self.storyboard?.instantiateViewController(withIdentifier: "RequestAcceptVC") as! RequestAcceptVC
        viewRequest.strRequestID = str2?["request_id"] as? String ?? String()
        viewRequest.strPickupLocation = str2?["pickup_location"] as? String ?? String()
        viewRequest.strPickupTime = str2?["min_time"] as? String ?? String()
        viewRequest.strPickUpLatitude = str2?["pickup_latitude"] as? String ?? String()
        viewRequest.strPickUpLongitude = str2?["pickup_longitude"] as? String ?? String()
        viewRequest.justLaunced = str2?["just_launched"] as? Bool ?? false
        self.navigationController?.pushViewController(viewRequest, animated: true)
    }
    
    //MARK: - API CALL -> UPDATE DRIVER CURRENT LOCATION TO SERVER
    /*
     WHEN USER IS ONLINE
     */
    func updateCurrentLocationToServer(status: String)
    {
        if !YSSupport.isNetworkRechable()
        {
            self.appDelegate.createToastMessage(iApp.GoferError.connection.error, bgColor: UIColor.black, textColor: UIColor.white)
            return
        }
        
        if Constants().GETVALUE(keyname: TRIP_STATUS) == "Trip" || isTimerStopped
        {
            return
        }        
        if Constants().GETVALUE(keyname: USER_ACCESS_TOKEN) == "" || strLatitude == "" || Constants().GETVALUE(keyname: USER_CAR_ID) == ""
        {
            return
        }
        var dicts = [String: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["latitude"] = strLatitude
        dicts["longitude"] = strLongitude
        dicts["car_id"] = Constants().GETVALUE(keyname: USER_CAR_ID)
        dicts["status"] = status
        UberAPICalls().PostRequest(dicts,methodName:METHOD_UPDATING_DRIVER_LOCATION as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let endModel = response as! GeneralModel
            
            OperationQueue.main.addOperation {
                if endModel.status_code == "1"
                {
                     
                }
                else
                {
                    if endModel.status_message.lowercased() == "please complete your current trip" && self.status != "Trip"
                    {
                        let settingsActionSheet: UIAlertController = UIAlertController(title: NSLocalizedString("Message!!!", comment: ""), message: endModel.status_message, preferredStyle: .alert)
                        settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style: .cancel, handler:{ action in
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
    @objc func updateCurrentToServer()
    {
        if !YSSupport.isNetworkRechable()
        {
            self.appDelegate.createToastMessage(iApp.GoferError.connection.error, bgColor: UIColor.black, textColor: UIColor.white)
            return
        }
        
        if Constants().GETVALUE(keyname: TRIP_STATUS) == "Trip" || isTimerStopped
        {
            return
        }
        if Constants().GETVALUE(keyname: USER_ACCESS_TOKEN) == "" || strLatitude == "" || Constants().GETVALUE(keyname: USER_CAR_ID) == ""
        {
            return
        }
        var dicts = [String: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["latitude"] = strLatitude
        dicts["longitude"] = strLongitude
        dicts["car_id"] = Constants().GETVALUE(keyname: USER_CAR_ID)
        dicts["status"] = status
        UberAPICalls().PostRequest(dicts,methodName:METHOD_UPDATING_DRIVER_LOCATION as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let endModel = response as! GeneralModel
            
            OperationQueue.main.addOperation {
                if endModel.status_code == "1"
                {
                }
                else
                {
                    if endModel.status_message.lowercased() == "please complete your current trip" && self.status != "Trip"
                    {
                        let settingsActionSheet: UIAlertController = UIAlertController(title: NSLocalizedString("Message!!!", comment: ""), message: endModel.status_message, preferredStyle:.alert)
                        settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:.cancel, handler:{ action in
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
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    @IBAction func onSideBarTapped(_ sender: UIButton!)
    {
    }
    
    //MARK: INTERNET OFFLINE DELEGATE METHOD
    /*
     Here Calling the API again
     */
    internal func RetryTapped()
    {
    }
    deinit {
//        locationManager.stopUpdatingLocation()
        locationManager = nil
        NotificationCenter.default.removeObserver(self)
        googleMap = nil
        
    }
    
    //MARK: - **** LOCATION MANAGER DELEGATE METHODS ****
    func updateCurrentLocation()
    {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = 2.0
            if #available(iOS 8.0, *) {
                locationManager.requestAlwaysAuthorization()
            }
            else if #available(iOS 9.0, *)
            {
                locationManager.allowsBackgroundLocationUpdates = true
            }
            
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    locationManager.requestAlwaysAuthorization()
                    break
                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager.requestAlwaysAuthorization()
                }
            } else {
            }
            locationManager.delegate = self
            
        }
        
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        //If map is being used
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        Constants().STOREVALUE(value: String(format: "%f", coord.longitude) as String, keyname: USER_LONGITUDE)
        Constants().STOREVALUE(value: String(format: "%f", coord.latitude) as String, keyname: USER_LATITUDE)
        strLatitude = String(format: "%f", coord.latitude)
        strLongitude = String(format: "%f", coord.longitude)
        
        if !isCurrentLocationGot
        {
            CATransaction.begin()
            CATransaction.setValue(1.5, forKey: kCATransactionAnimationDuration)
            
            oldCoordinate = CLLocationCoordinate2DMake(Double(strLatitude)!, Double(strLongitude)!)
            
            let camera = GMSCameraPosition.camera(withLatitude: Double(strLatitude)!, longitude: Double(strLongitude)!, zoom: 13.0)
            GMSMapView.map(withFrame: googleMap.frame, camera: camera)
            googleMap.camera = camera
            googleMap.isMyLocationEnabled = true
            
            googleMap.settings.myLocationButton = true
            CATransaction.commit()
            googleMap.clear()
            driverMarker = GMSMarker()
            driverMarker.position = CLLocationCoordinate2D(latitude: Double(strLatitude)!, longitude: Double(strLongitude)!)
            driverMarker.icon = UIImage(named: "cartopview2_40.png")
            driverMarker.map = googleMap
            driverMarker.isFlat = true
            isCurrentLocationGot = true
        }
        
        self.locationChanged(newCoordinate: CLLocationCoordinate2DMake(Double(strLatitude)!, Double(strLongitude)!))
    }
    
    
    func locationChanged(newCoordinate:CLLocationCoordinate2D) {
        
        moveMent.arCarMovement(driverMarker, withOldCoordinate: oldCoordinate, andNewCoordinate: newCoordinate, inMapview: googleMap, withBearing: 0)
        
        oldCoordinate = newCoordinate
        
    }
    
    // MARK: - ARCarMovementDelegate
    func arCarMovement(_ movedMarker: GMSMarker) {
        
        driverMarker = movedMarker
        driverMarker.map = googleMap
            }
    
    
    
    //MARK: - Create Map Marker
    func onCreateMapMarker(pickUpLatitude: String, pickUpLongitude: String)
    {
        googleMap.clear()
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: Double(pickUpLatitude)!, longitude: Double(pickUpLongitude)!)
        marker2.icon = UIImage(named: "cartopview2_40.png")
        marker2.map = googleMap
        self.moveMapBearing(newLocation: marker2.position)
    }
    
    func moveMapBearing(newLocation: CLLocationCoordinate2D)
    {
        if strDriverLatitude == ""
        {
            strDriverLatitude = String(format: "%f", googleMap.camera.target.latitude)
            strDriverLongitude = String(format: "%f", googleMap.camera.target.longitude)
        }
        let oldLocation = CLLocationCoordinate2DMake(Double(strDriverLatitude)!, Double(strDriverLongitude)!)
        let newLocation = CLLocationCoordinate2DMake(newLocation.latitude, newLocation.longitude)
        
        let getAngle : Float = YSSupport.angle(from: oldLocation, to: newLocation)
        self.focusOnCoordinate(coordinate: newLocation,degrees: CLLocationDegrees(getAngle))
        
        strDriverLatitude = String(format: "%f", newLocation.latitude)
        strDriverLongitude = String(format: "%f", newLocation.longitude)
    }
    
    func focusOnCoordinate(coordinate: CLLocationCoordinate2D, degrees: CLLocationDegrees)
    {
        googleMap.animate(toLocation: coordinate)
        googleMap.animate(toBearing: degrees)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    //MARK: - Change Map Style
    /*
     Here we are changing the Map style from Json File
     */
    func onChangeMapStyle()
    {
        do {
            if let styleURL = Bundle.main.url(forResource: "ub__map_style", withExtension: "json") {
                googleMap.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
            }
        } catch {
        }
    }
    
}


