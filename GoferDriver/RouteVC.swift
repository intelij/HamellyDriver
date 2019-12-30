/**
 * RouteVC.swift
 *
 * @package GoferDriver
 * @author Trioangle Product Team
 * @version - Stable 1.0
 * @link http://trioangle.com
 */

import UIKit
import AVFoundation
import Foundation
import GoogleMaps
//import APScheduledLocationManager
import FirebaseDatabase
import Alamofire

class RouteVC : UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,APScheduledLocationManagerDelegate,ARCarMovementDelegate,APIViewProtocol
{
    //MARK:- APIInteractor
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum) {
        switch response {
        case .RiderModel(let rider):
            self.goToMakePayment(withRider: rider)
        default:
            print()
        }
    }
    
    func onFailure(error: String) {
        print(error)
    }
    //MARK:-
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    private var manager: APScheduledLocationManager!
 
    @IBOutlet var btnViewRiderProfile: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var viewDetailHoder: UIView!
    @IBOutlet var viewAddressHoder: UIView!
    @IBOutlet var lblLocationName: UILabel!
    @IBOutlet var lblRiderName: UILabel!
    @IBOutlet var googleMap: GMSMapView!
  //  @IBOutlet var btnArriveNow: UIButton!
    @IBOutlet var btnRiderProfileHolder: UIButton!
    @IBOutlet weak var cashView: UIView!
    @IBOutlet weak var navigateLabel : UILabel!
    @IBOutlet weak var navigationView : UIView!
    @IBOutlet weak var navigationImage : UIImageView!
    
    @IBOutlet weak var tripProgressBtn : ProgressButton!
    
    let reachability = Reachability()
    var polyline = GMSPolyline()
    var path = GMSPath()
    var isCurrentLocationGot : Bool = false
    var isGoingToRiderProfile : Bool = false
    var isTripStarted : Bool = false
    var imageMap = ""
    var riderProfileModel : RiderDetailModel!
    var endTripModel : EndTripModel!
    var locationManager: CLLocationManager!
    var userDefaults = UserDefaults.standard
    var timerDriverLocation = Timer()
    var locationUpdateTimer: Timer!
    var currentLocation = CLLocation()
    var locdistance:Double = 0
    var nTotalKm = 0.0
    
    var driverMarker: GMSMarker!
    var moveMent: ARCarMovement!
    var markerAdded = true
    var oldCoordinate: CLLocationCoordinate2D!
    var ref: DatabaseReference!
    
    
    //var strTripStaus = ""
   // var strTripStatus = ""
    var currentTripStatus = TripStatus.scheduled
    
    var strLatitude = ""
    var strLongitude = ""
    var mobilelock = ""
    var strTripID = ""
    var strTotalKM = ""
    var strPickupLocation = ""
    var strOldLatitude = ""
    var strOldLongitude = ""
    var cash = ""
    var type = ""
    
    var arrLat = [String]()
    var arrLong = [String]()
    var arrLatFirst = [String]()
    var arrLongFirst = [String]()
    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    
    var isFromTripPage : Bool = false
    var isInBackground : Bool = false
    var isTimerStopped : Bool = false
    var isFromReqVC = Bool()
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
      self.apiInteractor = APIInteractor(self)
      self.initView()
        self.initGesture()
        self.initNotification()
        timerDriverLocation = Timer.scheduledTimer(timeInterval: 10.00, target: self, selector: #selector(self.updateCurrentLocationToServer), userInfo: nil, repeats: true)
        manager.stopUpdatingLocation()
        manager.startUpdatingLocation(interval: 30.0)
        self.riderProfileModel.storeRiderInfo(true)
        
    }
    deinit {
        if timerDriverLocation != nil{
            timerDriverLocation.invalidate()
        }
    }
    func initView(){
        if !self.strTripID.isEmpty {//&& riderProfileModel.booking_type != .manualBooking{
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.initChatBubble()
            }
                if !ChatInteractor.instance.isInitialized{
                    ChatInteractor.instance.initialize(withTrip: self.strTripID)}
                ChatInteractor.instance.getAllChats(ForView: nil, AndObserve: true)
            
        }
       self.tripProgressBtn.initialize(self)
        
        onChangeMapStyle()
        manager = APScheduledLocationManager(delegate: self)
        self.update()
        moveMent = ARCarMovement()
        moveMent.delegate = self
        ref = Database.database().reference()
        cash = Constants().GETVALUE(keyname: CASH_PAYMENT)
        cashView.layer.cornerRadius = 5
        if cash == "Cash & Wallet" || cash == "Cash"{
            
            cashView.isHidden = false
        }
        else{
            cashView.isHidden = true
        }
        btnBack.isHidden = false
        btnBack.isUserInteractionEnabled = true
        googleMap.addSubview(cashView)
//        if isFromTripPage
//        {
            btnBack.setTitle("A", for: .normal)
            btnBack.titleLabel?.text = "A"
//        }
        
        if self.currentTripStatus == .scheduled{
           // self.btnArriveNow.setTitle(TripStatus.scheduled.getDisplayText, for: .normal)
            self.tripProgressBtn.set2Trip(state: .scheduled)
        }else if self.currentTripStatus == .beginTrip//strTripStatus == "Begin trip"
        {
//            self.btnArriveNow.titleLabel?.text = NSLocalizedString("BEGIN TRIP", comment: "")
//            self.btnArriveNow.setTitle(NSLocalizedString("BEGIN TRIP", comment: ""), for: .normal)
            self.tripProgressBtn.set2Trip(state: .beginTrip)
            self.currentTripStatus = .beginTrip
            self.setPickUpLocation()
            
            Constants().STOREVALUE(value: "Trip", keyname: TRIP_STATUS)
            
        }
        else if self.currentTripStatus == .endTrip//strTripStatus == "End trip"
        {
            isTripStarted = true
//            self.btnArriveNow.titleLabel?.text = NSLocalizedString("END TRIP", comment: "")
//            self.btnArriveNow.setTitle(NSLocalizedString("END TRIP", comment: ""), for: .normal)
            self.tripProgressBtn.set2Trip(state: .endTrip)
            self.setPickUpLocation()
            Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
            Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
            if timerDriverLocation != nil
            {
                self.timerDriverLocation.invalidate()
                
            }
        }
        
        let frame = CGRect(x: 0, y: viewAddressHoder.frame.origin.y + viewAddressHoder.frame.size.height, width: self.view.frame.size.width, height: (self.view.frame.size.height - (googleMap.frame.origin.y + viewDetailHoder.frame.size.height)))
        googleMap.frame = frame
        updateCurrentLocation()
        let longitude = userDefaults.value(forKey: USER_LONGITUDE) as? String
//        print("log\(longitude!)")
        let latitude = userDefaults.value(forKey: USER_LATITUDE) as? String
//        print("lat \(latitude!)")
        if ((longitude == nil && longitude == "") && (latitude == nil && latitude == ""))
        {
            updateCurrentLocation()
        }
        else
        {
            self.setRiderInfo()
        }
        
        btnViewRiderProfile.layer.shadowColor = UIColor.gray.cgColor;
        btnViewRiderProfile.layer.shadowOffset = CGSize(width:0, height:1.0);
        btnViewRiderProfile.layer.shadowOpacity = 0.5;
        btnViewRiderProfile.layer.shadowRadius = 2.0;
        
        let nav_comapass = UIImage(named: "compass.png")?.withRenderingMode(.alwaysTemplate)
        self.navigationImage.image = nav_comapass
        self.navigationImage.tintColor = UIColor(hex: "1FBAD6")
        
    }
    func initNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.driverCancelledTrip), name: NSNotification.Name(rawValue: "cancel_trip_by_driver"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.riderCancelledTrip), name: NSNotification.Name(rawValue: "cancel_trip"), object: nil)
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        NotificationCenter.default.addObserver(self, selector:  #selector(applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    func initGesture(){
        self.navigationView.addAction(for: .tap) {
            var pickupCoordinate = CLLocationCoordinate2D()
            var dropCoordinate = CLLocationCoordinate2D()
            
            if self.oldCoordinate != nil{
                pickupCoordinate = self.oldCoordinate
            }else{//dint get driver cuurent location
                if let lat = Double(self.riderProfileModel.pickup_latitude),
                    let long = Double(self.riderProfileModel.pickup_longitude){
                    pickupCoordinate = CLLocationCoordinate2DMake(lat, long)
                }
            }
            
            if !self.isTripStarted{//Dint pickup rider
                if let lat = Double(self.riderProfileModel.pickup_latitude),
                    let long = Double(self.riderProfileModel.pickup_longitude){
                    dropCoordinate = CLLocationCoordinate2DMake( lat,  long)
                }
            }else{//picked up rider
                if let lat = Double(self.riderProfileModel.drop_latitude),
                    let long = Double(self.riderProfileModel.drop_longitude){
                    dropCoordinate = CLLocationCoordinate2DMake(lat,  long)
                }
            }
            
            let actionSheetController = UIAlertController(title: "Here you can change your map ", message: "By clicking below actions", preferredStyle: .actionSheet)
            actionSheetController.addColorInTitleAndMessage(titleColor: UIColor.black, messageColor: UIColor.black, titleFontSize: 15, messageFontSize: 13)
            let googleMapAction = UIAlertAction(title: "Google Map", style: .default) { (action) in
                self.showGoogleMap(withPickupAt: pickupCoordinate, dropAt: dropCoordinate)
            }
            googleMapAction.setValue(UIColor.black, forKey: "TitleTextColor")
            
            let wazeMapAction = UIAlertAction(title: "Waze Map", style: .default) { (action) in
                self.showWazeMap(withPickupAt: pickupCoordinate, dropAt: dropCoordinate)
            }
            wazeMapAction.setValue(UIColor.black, forKey: "TitleTextColor")
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
            
            actionSheetController.addAction(googleMapAction)
            actionSheetController.addAction(wazeMapAction)
            actionSheetController.addAction(cancelAction)
            self.present(actionSheetController, animated: false, completion: nil)
        }
        /*self.navigationView.addAction(for: .tap) {
            var pickupCoordinate = CLLocationCoordinate2D()
            var dropCoordinate = CLLocationCoordinate2D()
        
            if self.oldCoordinate != nil{
                pickupCoordinate = self.oldCoordinate
            }else{//dint get driver cuurent location
                if let lat = Double(self.riderProfileModel.pickup_latitude),
                    let long = Double(self.riderProfileModel.pickup_longitude){
                    pickupCoordinate = CLLocationCoordinate2DMake(lat, long)
                }
            }
            
            if !self.isTripStarted{//Dint pickup rider
                if let lat = Double(self.riderProfileModel.pickup_latitude),
                    let long = Double(self.riderProfileModel.pickup_longitude){
                    dropCoordinate = CLLocationCoordinate2DMake( lat,  long)
                }
            }else{//picked up rider
                if let lat = Double(self.riderProfileModel.drop_latitude),
                    let long = Double(self.riderProfileModel.drop_longitude){
                    dropCoordinate = CLLocationCoordinate2DMake(lat,  long)
                }
            }
            let req_str_url = "?saddr=\(pickupCoordinate.latitude),\(pickupCoordinate.longitude)&daddr=\(dropCoordinate.latitude),\(dropCoordinate.longitude)"
            
           
            if let google_url = URL(string:"comgooglemaps://"),
                UIApplication.shared.canOpenURL(google_url),
                let hit_URL = URL(string: ("comgooglemaps://"+req_str_url+"&zoom=14&views=traffic")){//Able to use googlemap app
                if #available(iOS 10.0, *){
                    UIApplication.shared.open(hit_URL, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.openURL(hit_URL)
                }
            } else {//Cant open map app so redirect to web
                print("Can't use comgooglemaps://");
                let alert = UIAlertController(title: "Do you want to access direction?".localize, message: "Please install Google maps app , then only you get the direction for this item.".localize, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localize, style: UIAlertActionStyle.default, handler: { (action) in
                    if #available(iOS 10.0, *){
                        UIApplication.shared.open(URL(string:"https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")!, options: [:], completionHandler: nil)
                    }else{
                        UIApplication.shared.openURL(URL(string:"https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")!)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel".localize, style: .cancel, handler: nil))
                self.present(alert, animated: true)
               
                //
            }
        }*/
    }
    func showGoogleMap(withPickupAt pickupCoordinate : CLLocationCoordinate2D,dropAt dropCoordinate : CLLocationCoordinate2D){
      
            let req_str_url = "?saddr=\(pickupCoordinate.latitude),\(pickupCoordinate.longitude)&daddr=\(dropCoordinate.latitude),\(dropCoordinate.longitude)"
            
            
            if let google_url = URL(string:"comgooglemaps://"),
                UIApplication.shared.canOpenURL(google_url),
                let hit_URL = URL(string: ("comgooglemaps://"+req_str_url+"&zoom=14&views=traffic")){//Able to use googlemap app
                if #available(iOS 10.0, *){
                    UIApplication.shared.open(hit_URL, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.openURL(hit_URL)
                }
            } else {//Cant open map app so redirect to web
                print("Can't use comgooglemaps://");
                let alert = UIAlertController(title: "Do you want to access direction?".localize, message: "Please install Google maps app , then only you get the direction for this item.".localize, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localize, style: .default, handler: { (action) in
                    if #available(iOS 10.0, *){
                        UIApplication.shared.open(URL(string:"https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")!, options: [:], completionHandler: nil)
                    }else{
                        UIApplication.shared.openURL(URL(string:"https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")!)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel".localize, style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
                //
            }
      
    }
    func showWazeMap(withPickupAt pickupCoordinate : CLLocationCoordinate2D,dropAt dropCoordinate : CLLocationCoordinate2D){
    
        
        let req_str_url = "?ll=\(dropCoordinate.latitude),\(dropCoordinate.longitude)&from=\(pickupCoordinate.latitude),\(pickupCoordinate.longitude)"
        
        
        if let waze_url = URL(string:"waze://"),
            UIApplication.shared.canOpenURL(waze_url),
            let hit_URL = URL(string: ("https://waze.com/ul\(req_str_url)&at=now&navigate=yes&zoom=17")){//Able to use Waze app
            if #available(iOS 10.0, *){
                UIApplication.shared.open(hit_URL, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.openURL(hit_URL)
            }
        } else {//Cant open map app so redirect to web
            print("Can't use comgooglemaps://");
            let alert = UIAlertController(title: "Do you want to access direction?".localize, message: "Please install Waze maps app , then only you get the direction for this item.".localize, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localize, style: .default, handler: { (action) in
                if #available(iOS 10.0, *){
                    UIApplication.shared.open(URL(string:"http://itunes.apple.com/us/app/id323229106")!, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.openURL(URL(string:"http://itunes.apple.com/us/app/id323229106")!)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel".localize, style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            //
        }
    }
    func updateLocation(_ sender: Any) {
        manager.startUpdatingLocation(interval: 30.0)
        
    }
    
    func update(){
        
        var alert: UIAlertView?
        //We have to make sure that the Background app Refresh is enabled for the Location updates to work in the background.
        if UIApplication.shared.backgroundRefreshStatus == .denied {
            // The user explicitly disabled the background services for this app or for the whole system.
            //alert = UIAlertView(title: "", message: "The app doesn't work without the Background app Refresh enabled. To turn it on, go to Settings > General > Background app Refresh", delegate: nil, cancelButtonTitle: "Ok")
            //alert?.show()
        }
        else if UIApplication.shared.backgroundRefreshStatus == .restricted {
            // Background services are disabled and the user cannot turn them on.
            // May occur when the device is restricted under parental control.
            //alert = UIAlertView(title: "", message: "The functions of this app are limited because the Background app Refresh is disable.", delegate: nil, cancelButtonTitle: "Ok")
        }
        else{
            
            
        }
        
    }
    
    //if off the back ground the fun is call
    @objc func applicationDidEnterBackground() {
        // self.mobilelock = "1"
        stopBackgroundTask()
        startBackgroundTask()
        
    }
    //if on background the fun is call
    @objc func applicationDidBecomeActive() {
        // mobilelock = "2"
        stopBackgroundTask()
        
    }
    // update the location in backgroud status
    private func startBackgroundTask() {
        let state = UIApplication.shared.applicationState
        
        if ((state == .background || state == .inactive) && bgTask == UIBackgroundTaskIdentifier.invalid)
        {
            self.startTimer()
            bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                //  self.checkLocationTimerEvent()
            })
        }
    }
    
    @objc private func stopBackgroundTask() {
        startTimer()
        guard bgTask != UIBackgroundTaskIdentifier.invalid else { return }
        UIApplication.shared.endBackgroundTask(bgTask)
        bgTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func startTimer()
    {
        
        if timerDriverLocation != nil
        {
            self.timerDriverLocation.invalidate()
            
        }
        timerDriverLocation = Timer.scheduledTimer(timeInterval: 30.00, target: self, selector: #selector(self.updateCurrentLocationToServer), userInfo: nil, repeats: true)
        
    }
    // driver callcel the trip
    @objc func driverCancelledTrip()
    {
        timerDriverLocation.invalidate()
        locationManager.stopUpdatingLocation()
        NotificationCenter.default.removeObserver(self, name:UIApplication.didEnterBackgroundNotification, object:nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.didBecomeActiveNotification, object:nil)
        timerDriverLocation.invalidate()
    }
    // Rider cancel the trip
    @objc func riderCancelledTrip(notification: Notification)
    {
        NotificationCenter.default.removeObserver(self, name:UIApplication.didEnterBackgroundNotification, object:nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.didBecomeActiveNotification, object:nil)
        timerDriverLocation.invalidate()
        Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
        Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
        locationManager.stopUpdatingLocation()
        self.appDelegate.onSetRootViewController(viewCtrl: self)
        
    }
    
    // show the arriew now button
    func showArriveNowButton()
    {
        UIView.animate(withDuration:  1.2, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.btnViewRiderProfile.isHidden = true
            var viewDetailRect = self.viewDetailHoder.frame
            viewDetailRect.origin.y = self.view.frame.size.height - self.viewDetailHoder.frame.size.height
            self.viewDetailHoder.frame = viewDetailRect
        }, completion: { (finished: Bool) -> Void in
        })
    }
    func initChatBubble(){
        let chat_bub = UIImage(named: "chat_bub.png")?.withRenderingMode(.alwaysTemplate)
        let s_width = self.view.frame.width
        let c_width = self.btnViewRiderProfile.frame.width
        
        let chatBubbleBtn = UIButton(frame: CGRect(x: self.btnViewRiderProfile.frame.minX ,
                                                   y: self.viewDetailHoder.frame.minY - c_width - 15,
                                                   width: c_width,
                                                   height: c_width))
        
        
        
        
        chatBubbleBtn.setTitle("", for: .normal)
        chatBubbleBtn.backgroundColor = .white
        chatBubbleBtn.isRoundCorner = true
        chatBubbleBtn.elevate(2.3)
        chatBubbleBtn.tintColor = .black
        chatBubbleBtn.isUserInteractionEnabled = true
        
        let chat_bubIV = UIImageView(image: chat_bub, highlightedImage: nil)
        chat_bubIV.frame = CGRect(x: chatBubbleBtn.frame.minX + 10,
                                  y: chatBubbleBtn.frame.minY + 10,
                                  width: chatBubbleBtn.frame.width - 20,
                                  height: chatBubbleBtn.frame.height - 20)
        chat_bubIV.tintColor = .black
        chat_bubIV.isUserInteractionEnabled = false
        
        chatBubbleBtn.addTarget(self, action: #selector(self.goToChatVC(_:)), for: .touchUpInside)
        
        self.view.addSubview(chatBubbleBtn)
        self.view.bringSubviewToFront(chatBubbleBtn)
        self.view.addSubview(chat_bubIV)
        self.view.bringSubviewToFront(chat_bubIV)
        
        
    }
    @IBAction func goToChatVC(_ sender : Any){
        //
        let chatVC = ChatVC.initWithStory(withTripId: self.strTripID)
        chatVC.ridername = self.riderProfileModel.rider_name
        chatVC.riderImage = self.btnViewRiderProfile.imageView?.image
        chatVC.rating = Double(self.riderProfileModel.rating_value) ?? 0.0
        self.present(chatVC, animated: true, completion: nil)
    }
    // set the rider data from api
    func setRiderInfo()
    {
        if riderProfileModel != nil
        {
            riderProfileModel.storeRiderInfo(true)
            lblRiderName.text = riderProfileModel.rider_name
            //btnArriveNow.titleLabel?.text == "BEGIN TRIP".localize || btnArriveNow.titleLabel?.text == "END TRIP".localize
            if [TripStatus.beginTrip,.endTrip].contains(self.currentTripStatus){
                lblLocationName.text = riderProfileModel.drop_location
            }
            else{
                lblLocationName.text = riderProfileModel.pickup_location
                
            }
            
            btnViewRiderProfile.sd_setImage(with: NSURL(string: riderProfileModel.rider_thumb_image)! as URL, for: .normal)
            //self.setPickUpLocation()
        }
    }
    // set pichup location
    func setPickUpLocation()
    {
        //btnArriveNow.titleLabel?.text == "BEGIN TRIP".localize || btnArriveNow.titleLabel?.text == "END TRIP".localize
        if [TripStatus.beginTrip,.endTrip].contains(self.currentTripStatus)
        {
            let pickuplatitude1 :CLLocationDegrees = Double((userDefaults.value(forKey: USER_LATITUDE) as? String)!)!
            let pickuplongitude1 :CLLocationDegrees = Double((userDefaults.value(forKey: USER_LONGITUDE) as? String)!)!
            let droplatitude1 :CLLocationDegrees = Double(riderProfileModel.drop_latitude)!
            let droplongitude1 :CLLocationDegrees = Double(riderProfileModel.drop_longitude)!
            self.createPolyLine(pickUpLatitude: pickuplatitude1, pickUpLongitude: pickuplongitude1, dropLatitude: droplatitude1, dropLongitude: droplongitude1, marker: true)
        }
        else
        {
            let longitude = userDefaults.value(forKey: USER_LONGITUDE) as? String
            let latitude = userDefaults.value(forKey: USER_LATITUDE) as? String
            let latitude1 :CLLocationDegrees = Double(latitude!)!
            let longitude1 :CLLocationDegrees = Double(longitude!)!
            let droplatitude1 :CLLocationDegrees = Double(riderProfileModel.pickup_latitude)!
            let droplongitude1 :CLLocationDegrees = Double(riderProfileModel.pickup_longitude)!
            self.createPolyLine(pickUpLatitude: latitude1, pickUpLongitude: longitude1, dropLatitude: droplatitude1, dropLongitude: droplongitude1, marker: true)
        }
    }
    
    //MARK: - GOOGLE API CALL
    /*
     FOR GETTING DRAW POINTS FROM GOOGLE DIRECTION API
     */
    var isFirstPoly = false
    func createPolyLine(pickUpLatitude: CLLocationDegrees, pickUpLongitude: CLLocationDegrees, dropLatitude: CLLocationDegrees, dropLongitude: CLLocationDegrees,marker:Bool)
    {
        userDefaults.set(arrLat, forKey: "StartLat" )
        userDefaults.set(arrLong, forKey: "StartLong")
        if isFirstPoly == false {
            let vancouver = CLLocationCoordinate2DMake(pickUpLatitude, pickUpLongitude)
            let calgary = CLLocationCoordinate2DMake(dropLatitude, dropLongitude)
            let bounds = GMSCoordinateBounds(coordinate: vancouver, coordinate: calgary)
            let camera1 = googleMap.camera(for: bounds, insets:UIEdgeInsets.zero)
            googleMap.camera = camera1!
            isFirstPoly = true
        }
        let service = "https://maps.googleapis.com/maps/api/directions/json"
        let urlString = "\(service)?origin=\(pickUpLatitude),\(pickUpLongitude)&destination=\(dropLatitude),\(dropLongitude)&mode=driving&units=metric&sensor=true&key=\(iApp.GoogleKeys.map.key)"
        let myURL = NSURL(string: urlString)!
        print(urlString)
        var items = NSDictionary()
        let request = NSMutableURLRequest(url:myURL as URL);
        URLSession.shared.dataTask(with: request as URLRequest){ (data, response, error) in
            if !(data != nil) {
            }
            else
            {
                do
                {
                    let jsonResult : Dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary as Dictionary
                    items = jsonResult as NSDictionary
                    if (items.count>0)
                    {
                        OperationQueue.main.addOperation {
                            self.drawRoute(routeDict: items, marker: marker)
                        }
                    }
                    else {
                    }
                }
                catch _ {
                }
            }
            }.resume()
        
    }
    
    // drow the route in map
    func drawRoute(routeDict: NSDictionary,marker:Bool)
    {
        let routesArray = routeDict ["routes"] as? NSArray ?? NSArray()
        let pickuplatitude1 :CLLocationDegrees = Double(riderProfileModel.pickup_latitude)!
        let pickuplongitude1 :CLLocationDegrees = Double(riderProfileModel.pickup_longitude)!
        let droplatitude1 :CLLocationDegrees = Double(riderProfileModel.drop_latitude)!
        let droplongitude1 :CLLocationDegrees = Double(riderProfileModel.drop_longitude)!
        
        if marker {
            onCreateMapMarker(pickUpLatitude: pickuplatitude1, pickUpLongitude: pickuplongitude1, dropLatitude: droplatitude1, dropLongitude: droplongitude1)
        }
        
        if (routesArray.count > 0)
        {
            let routeDict = routesArray[0] as! Dictionary<String, Any>
            let routeOverviewPolyline = routeDict["overview_polyline"] as! Dictionary<String, Any>
            let points = routeOverviewPolyline["points"]
            self.path = GMSPath.init(fromEncodedPath: points as? String ?? String())!
            self.polyline.path = path
            self.polyline.strokeColor = UIColor.black
            self.polyline.strokeWidth = 3.0
            self.polyline.map = googleMap
        }
    }
    //MARK: - Create Map Marker
    
    //    var markerAdded = false
    var marker1 : GMSMarker?
    var marker2 : GMSMarker?
    
    //MARK: - Create Map Marker
    func onCreateMapMarker(pickUpLatitude: CLLocationDegrees, pickUpLongitude: CLLocationDegrees, dropLatitude: CLLocationDegrees, dropLongitude: CLLocationDegrees)
    {
        if self.currentTripStatus == .endTrip {//btnArriveNow.titleLabel?.text == "END TRIP".localize
            if marker2 == nil {
                marker2 = GMSMarker()
                marker2?.icon = UIImage(named: "dropoff_icon_pin.png")//"pickup_icon.png")
                marker2?.map = googleMap
                marker2?.position = CLLocationCoordinate2D(latitude: dropLatitude, longitude: dropLongitude)
            }
        }
        if self.currentTripStatus == .beginTrip{//btnArriveNow.titleLabel?.text == "BEGIN TRIP".localize
            arrLat = [String]()
            arrLong = [String]()
            if marker2 == nil {
                marker2 = GMSMarker()
                marker2?.icon = UIImage(named: "dropoff_icon_pin.png")
                marker2?.map = googleMap
                marker2?.position = CLLocationCoordinate2D(latitude: dropLatitude, longitude: dropLongitude)
            }
            if marker1 == nil {
                marker1 = GMSMarker()
                marker1?.icon = UIImage(named: "pickup_icon.png")
                marker1?.map = googleMap
                googleMap.isMyLocationEnabled = false
                marker1?.position = CLLocationCoordinate2D(latitude: pickUpLatitude, longitude: pickUpLongitude)
            }
        }
        else{
            if marker1 == nil {
                marker1 = GMSMarker()
                marker1?.icon = UIImage(named: "pickup_icon.png")
                marker1?.map = googleMap
                googleMap.isMyLocationEnabled = false
            }
            if marker2 == nil {
                marker2 = GMSMarker()
                marker2?.icon = UIImage(named: "dropoff_icon_pin.png")//"pickup_icon.png")
                marker2?.map = googleMap
            }
            marker1?.position = CLLocationCoordinate2D(latitude: pickUpLatitude, longitude: pickUpLongitude)
            marker2?.position = CLLocationCoordinate2D(latitude: dropLatitude, longitude: dropLongitude)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .lightContent)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        if isGoingToRiderProfile
        {
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func onNavigateTapped()
    {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:
                "comgooglemaps://?center=\(riderProfileModel.pickup_latitude),\(riderProfileModel.pickup_longitude)&zoom=14&views=traffic")!)
        } else {
            print("Can't use comgooglemaps://");
        }
    }
    
    @IBAction func onBackTapped()
    {
        if isFromReqVC {
           self.navigationController?.popToRootViewController(animated: false)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRiderViewProfileTapped()
    {
        isGoingToRiderProfile = true
        let tripView = self.storyboard?.instantiateViewController(withIdentifier: "RiderProfileVC") as! RiderProfileVC
        tripView.riderProfileModel = riderProfileModel
        tripView.isTripStarted = isTripStarted
        self.navigationController?.pushViewController(tripView, animated: true)
    }
    
    //MARK: - WHEN USER PRESS ARRIVE NOW OR BEGIN TRIP OR END TRIP
    @IBAction func onArriveNowTapped()
    {
        return
        if self.currentTripStatus == .beginTrip{//btnArriveNow.titleLabel?.text == "BEGIN TRIP".localize
   
            self.setRiderInfo()
            self.callArriveNowOrBeginTripAPI(METHOD_BEGIN_TRIP as NSString)
        }
        else if self.currentTripStatus == .endTrip {//btnArriveNow.titleLabel?.text == "END TRIP".localize
            self.setRiderInfo()
            self.callStaticMap()
            if timerDriverLocation != nil
            {
                self.timerDriverLocation.invalidate()
            }
            ChatInteractor.instance.deleteChats()
            self.riderProfileModel.storeRiderInfo(false)
            locationManager.stopUpdatingLocation()
            
        }
        else
        {
            self.callArriveNowOrBeginTripAPI(METHOD_ARRIVE_NOW as NSString)
        }
    }
    private var jpeg_map_snap_shot : Data?
    func callStaticMap() {
        
        self.tripProgressBtn.isUserInteractionEnabled = false//btnArriveNow
        var coordinateArray = [String]()
        let preference = UserDefaults.standard
        if let pickup_coords = preference.value(forKey: PICKUP_COORDINATES) as? String{
            coordinateArray.append(pickup_coords)
        }
        preference.removeObject(forKey: PICKUP_COORDINATES)
        for i in 0..<arrLat.count {
            let coordinate = "\(arrLat[i]),\(arrLong[i])"
            coordinateArray.append(coordinate)
        }
        if coordinateArray.count > 100{
            let filter_range = coordinateArray.count / 100
            coordinateArray = coordinateArray.enumerated().compactMap({ (arg0) -> String? in
                let (offset, element) = arg0
                if offset % filter_range == 0{
                    return element
                }else{
                    return ""
                }
            })
        }
      
        if coordinateArray.count == 0 {
            if let lastlocation = self.lastUserLocation{
            coordinateArray.append("\(lastlocation.coordinate.latitude),\(lastlocation.coordinate.longitude)")
            }else{
                self.tripProgressBtn.isUserInteractionEnabled = true//btnArriveNow
                return
            }
        }
        let coordinateString = coordinateArray.joined(separator: "|")
        let staticImageUrl = "https://maps.googleapis.com/maps/api/staticmap?top=\(coordinateArray.first!)&bottom=\(coordinateArray.last!)&size=1500x400&markers=size:mid|icon:\(iApp.baseURL.rawValue)images/pickup.png|\(coordinateArray.first!)&markers=size:mid|icon:\(iApp.baseURL.rawValue)images/drop.png|\(coordinateArray.last!)&key=\(iApp.GoogleKeys.map.key)&path=color:0x000000|weight:5|\(coordinateString)"
        userDefaults.set(coordinateArray, forKey: "CoordinateArray")
        if let urlStr = staticImageUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)! as NSString?{
            let imageUrl = urlStr as String
            let url = URL(string:"\(imageUrl)")
            if imageUrl != "" {
               // UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
                self.view.isUserInteractionEnabled = false
                if let data = try? Data(contentsOf: url!)
                {
                    let mapimage:UIImage = UIImage(data: data)!
                    let imageData:NSData = mapimage.pngData()! as NSData as NSData
                    self.jpeg_map_snap_shot = mapimage.jpegData(compressionQuality: 1.0)//UIImageJPEGRepresentation(mapimage,1)
                    self.imageMap = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//                    UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: false)
//                    UberSupport().removeProgressInWindow(viewCtrl: self)
                    self.view.isUserInteractionEnabled = true
                    self.tripProgressBtn.isUserInteractionEnabled = false//btnArriveNow
                    self.callEndTripAPI()
                    
                }else{
//                    UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: false)
//                    UberSupport().removeProgressInWindow(viewCtrl: self)
                    self.tripProgressBtn.isUserInteractionEnabled = true//btnArriveNow
                }
            }
            else{
                self.tripProgressBtn.isUserInteractionEnabled = true//btnArriveNow
            }
            
        }
        //             self.callEndTripAPI()
        self.tripProgressBtn.isUserInteractionEnabled = true//btnArriveNow
        
    }
    //MARK: - API CALL -> ARRIVE_NOW OR BEGIN_TRIP
    func callArriveNowOrBeginTripAPI(_ methodName: NSString)
    {
//        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        self.view.isUserInteractionEnabled = false
        var dicts = [String: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["trip_id"] = riderProfileModel.trip_id
        dicts["begin_latitude"] = strLatitude
        dicts["begin_longitude"] = strLongitude
        UberAPICalls().PostRequest(dicts,methodName:methodName, forSuccessionBlock:{(_ response: Any) -> Void in
            let gModel = response as! GeneralModel
            self.view.isUserInteractionEnabled = true
            
            OperationQueue.main.addOperation {
                if gModel.status_code == "1"
                {
                    if methodName.isEqual(to: METHOD_ARRIVE_NOW)
                    {
//                        self.btnArriveNow.titleLabel?.text = NSLocalizedString("BEGIN TRIP", comment: "")
//                        self.btnArriveNow.setTitle(NSLocalizedString("BEGIN TRIP", comment: ""), for: .normal)
                        self.tripProgressBtn.set2Trip(state: .beginTrip)
                        self.setPickUpLocation()
                        Constants().STOREVALUE(value: "Trip", keyname: TRIP_STATUS)
                    }
                    else if methodName.isEqual(to: METHOD_BEGIN_TRIP)
                    {
                        self.isTripStarted = true
//                        self.btnArriveNow.titleLabel?.text = NSLocalizedString("END TRIP", comment: "")
//                        self.btnArriveNow.setTitle(NSLocalizedString("END TRIP", comment: ""), for: .normal)
                        
                        self.tripProgressBtn.set2Trip(state: .endTrip)
                        self.setPickUpLocation()
                        Constants().STOREVALUE(value: "Trip", keyname: TRIP_STATUS)
                        if self.timerDriverLocation != nil
                        {
                            self.timerDriverLocation.invalidate()
                            
                        }
                    }
                }
                else
                {
                    self.appDelegate.createToastMessage(gModel.status_message, bgColor: UIColor.black, textColor: UIColor.white)
                    self.tripProgressBtn.set2Trip(state: self.currentTripStatus)
                }
                self.view.isUserInteractionEnabled = true
                self.tripProgressBtn.isUserInteractionEnabled = true//btnArriveNow
//                UberSupport().removeProgressInWindow(viewCtrl: self)
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                self.tripProgressBtn.set2Trip(state: self.currentTripStatus)
                self.view.isUserInteractionEnabled = true
                self.appDelegate.createToastMessage(iApp.GoferError.server.error.localize, bgColor: UIColor.black, textColor: UIColor.white)
                self.tripProgressBtn.isUserInteractionEnabled = true//btnArriveNow
//                UberSupport().removeProgressInWindow(viewCtrl: self)
            }
        })
    }
    func callApiUpdate(requestParams: [String:Any]) {
        
    }

    //MARK: - API CALL -> END TRIP
    /*
     AFTER API DONE, NAVIGATING TO RATING PAGE
     */
    func callEndTripAPI()
    {
        var params = Parameters()
        params["trip_id"] = riderProfileModel.trip_id
        params["end_latitude"] = strLatitude
        params["end_longitude"] = strLongitude
        params["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = self.jpeg_map_snap_shot {
                multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
            }
            
        },  to: iApp.APIBaseUrl+"end_trip") { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded  = \(response)")
                    if let responseJson = response.result.value as? [String:Any]{
                        if responseJson["status_code"] as? String ?? String() == "1" {
                            self.userDefaults.removeObject(forKey: "CoordinateArray")
                            if self.timerDriverLocation != nil
                            {
                                self.timerDriverLocation.invalidate()
                            }
                            self.isTripStarted = false
                            Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
                            Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
                            UberSupport().removeProgressInWindow(viewCtrl: self)
                            self.gotoRateYourRidePage()

                        }
                        else {
                            UberSupport().removeProgressInWindow(viewCtrl: self)
                        self.appDelegate.createToastMessageForAlamofire(responseJson.status_message, bgColor: UIColor.black, textColor: UIColor.white, forView: self.view)

                        }
                    }
                    if let err = response.error{
                        
                        print(err)
                        return
                    }
                    
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                
            }
        }
        if self.timerDriverLocation != nil
        {
            self.timerDriverLocation.invalidate()
        }
    }
    
    func gotoRateYourRidePage()
    {
        timerDriverLocation.invalidate()
        var parameters = Parameters()
        parameters["trip_id"] = self.strTripID
        
        self.apiInteractor?.getResponse(forAPI: .getInvoice, params: parameters).shouldLoad(true)
        /*let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "RateYourRideVC") as! RateYourRideVC
        propertyView.strRiderImgUrl = riderProfileModel.rider_thumb_image
        propertyView.strTripID = riderProfileModel.trip_id
        propertyView.isFromRoutePage = true
        self.navigationController?.pushViewController(propertyView, animated: true)*/
    }
    func goToMakePayment(withRider rider : RiderDetailModel){
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "MakePaymentVC") as! MakePaymentVC
        propertyView.payment_method = rider.getPaymentMethod
        propertyView.totalAmt = rider.getPayableAmount
        propertyView.strTripID = self.strTripID
        propertyView.arrInfoKey = NSMutableArray(array: rider.invoices.compactMap({$0 as Any}))
        self.navigationController?.pushViewController(propertyView, animated: true)
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
    
    func updateCurrentLocation()
    {
        if manager.isRunning {
            
            manager.stopUpdatingLocation()
            
        }else{
            
            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                
                manager.startUpdatingLocation(interval: 10, acceptableLocationAccuracy: 100)
                
            }else{
                
                manager.requestAlwaysAuthorization()
            }
        }
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            if #available(iOS 8.0, *) {
                locationManager.requestAlwaysAuthorization()
            }
            else if #available(iOS 9.0, *)
            {
                locationManager.allowsBackgroundLocationUpdates = true
            }
                
            else{
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
            manager.startUpdatingLocation(interval: 10, acceptableLocationAccuracy: 100)
            
        }
        
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        if locationManager.location != nil {
            
            strLatitude = String(format: "%f", (locationManager.location?.coordinate.latitude)!)
            strLongitude = String(format: "%f", (locationManager.location?.coordinate.longitude)!)
            
        }
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
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didUpdateLocations locations: [CLLocation]) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let l = locations.first!
        strLatitude = String(format: "%f", l.coordinate.latitude)
        strLongitude = String(format: "%f", l.coordinate.longitude)
        Constants().STOREVALUE(value: String(format: "%f",l.coordinate.longitude) as String, keyname: USER_LONGITUDE)
        Constants().STOREVALUE(value: String(format: "%f", l.coordinate.latitude) as String, keyname: USER_LATITUDE)
        if timerDriverLocation != nil
        {
            self.timerDriverLocation.invalidate()
        }
        self.timerDriverLocation = Timer.scheduledTimer(timeInterval: 10.00, target: self, selector: #selector(self.updateCurrentLocationToServer), userInfo: nil, repeats: true)
        
    }
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didFailWithError error: Error) {
        
    }
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    //MARK: Location validator
    private var lastUserLocation : CLLocation?
    func isValidLocation(_ currentLocaiton : CLLocation) ->Bool{
        //Update every location to firebase
        strLatitude = String(format: "%f", currentLocaiton.coordinate.latitude)
        strLongitude = String(format: "%f", currentLocaiton.coordinate.longitude)
        self.sendToDataBase(lat: strLatitude, lng: strLongitude)
        let end_trip = NSLocalizedString("END TRIP", comment: "")//Add to poluline array
        
        guard let lastLocation = self.lastUserLocation else {//first time so no last user location
            self.lastUserLocation = currentLocaiton
            if self.currentTripStatus == .endTrip{//btnArriveNow.titleLabel?.text == end_trip
                arrLat.append(strLatitude)
                arrLong.append(strLongitude)
            }
            return true
        }
      
        let maxAge:TimeInterval = 10;//minimum differenace between valid locaiton
        let minDistance = 5.0 // minimum distance difference
        
        let timeStampDif:Double = -(lastLocation.timestamp.timeIntervalSince(currentLocaiton.timestamp) )
        let deferedDistance = lastLocation.distance(from: currentLocaiton)
        
        let valid_TimeDifference = (timeStampDif  > maxAge)
        let valid_SpaceDifference = (deferedDistance > minDistance)
        
        let locationIsValid:Bool =  valid_TimeDifference && valid_SpaceDifference
        
        if locationIsValid{//Valid location is considered for polyline array
            self.lastUserLocation = currentLocaiton
            moveMent.arCarMovement(driverMarker,
                                   withOldCoordinate: lastLocation.coordinate,
                                   andNewCoordinate: currentLocaiton.coordinate,
                                   inMapview: googleMap,
                                   withBearing: 0)
            if self.currentTripStatus == .endTrip{//btnArriveNow.titleLabel?.text == end_trip
                arrLat.append(strLatitude)
                arrLong.append(strLongitude)
            }
        }
        return locationIsValid
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let l1 = locations.last,//first!
            l1.isValid,
            self.isValidLocation(l1) else{return}
        let l = locations.first!
//        strLatitude = String(format: "%f", l.coordinate.latitude)
//        strLongitude = String(format: "%f", l.coordinate.longitude)
        Constants().STOREVALUE(value: String(format: "%f",l.coordinate.longitude) as String, keyname: USER_LONGITUDE)
        Constants().STOREVALUE(value: String(format: "%f", l.coordinate.latitude) as String, keyname: USER_LATITUDE)
//        let beg_trip = NSLocalizedString("BEGIN TRIP", comment: "")
//        let end_trip = NSLocalizedString("END TRIP", comment: "")
//        if btnArriveNow.titleLabel?.text ==  beg_trip ||  btnArriveNow.titleLabel?.text == end_trip{
//            arrLat.append(strLatitude)
//            arrLong.append(strLongitude)
//        }
        if driverMarker == nil {
            oldCoordinate = CLLocationCoordinate2DMake(Double(strLatitude)!, Double(strLongitude)!)
            driverMarker = GMSMarker()
            driverMarker.position = CLLocationCoordinate2D(latitude: Double(strLatitude)!, longitude: Double(strLongitude)!)
            driverMarker.icon = UIImage(named: "cartopview2_40.png")
            driverMarker.isFlat = true
            driverMarker.map = googleMap
            self.updateCurrentLocationToServer()
            self.locationChanged(newCoordinate: CLLocationCoordinate2DMake(Double(strLatitude)!, Double(strLongitude)!))
            
        }
        else if Double(round(10000*oldCoordinate.latitude)/10000) != Double(round(10000*l.coordinate.latitude)/10000) && Double(round(10000*oldCoordinate.longitude)/10000) != Double(round(10000*l.coordinate.longitude)/10000) {
            
                self.locationChanged(newCoordinate: CLLocationCoordinate2DMake(Double(strLatitude)!, Double(strLongitude)!))
            
        }
    }
    // Path is changed update a  new path
    func locationChanged(newCoordinate:CLLocationCoordinate2D) {
        let new = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
        let old = CLLocation(latitude: oldCoordinate.latitude, longitude: oldCoordinate.longitude)
        let distanceInMeters = new.distance(from: old)

        let beg_trip = NSLocalizedString("BEGIN TRIP", comment: "")
        let end_trip = NSLocalizedString("END TRIP", comment: "")
        if self.currentTripStatus == .endTrip
            ///*btnArriveNow.titleLabel?.text ==  beg_trip ||*/  btnArriveNow.titleLabel?.text == end_trip
        {
            let droplatitude1 :CLLocationDegrees = Double(self.riderProfileModel.drop_latitude)!
            let droplongitude1 :CLLocationDegrees = Double(self.riderProfileModel.drop_longitude)!
            self.createPolyLine(pickUpLatitude: newCoordinate.latitude, pickUpLongitude: newCoordinate.longitude, dropLatitude: droplatitude1, dropLongitude: droplongitude1, marker: true)
        }
        else
        {
            let droplatitude1 :CLLocationDegrees = Double(self.riderProfileModel.pickup_latitude)!
            let droplongitude1 :CLLocationDegrees = Double(self.riderProfileModel.pickup_longitude)!
            self.createPolyLine(pickUpLatitude: newCoordinate.latitude, pickUpLongitude: newCoordinate.longitude, dropLatitude: droplatitude1, dropLongitude: droplongitude1, marker: true)
        }
        oldCoordinate = newCoordinate
        
    }
    
    var isZoom = false
    func arCarMovement(_ movedMarker: GMSMarker) {
        guard let map = googleMap, let marker = driverMarker else {return}
        driverMarker = movedMarker
        driverMarker.map = map
        var updatedCamera = GMSCameraUpdate.setTarget(driverMarker.position)
        if isZoom == false {
            updatedCamera = GMSCameraUpdate.setTarget(driverMarker.position, zoom: 16.5)
            isZoom = true
        }
        googleMap.animate(with: updatedCamera)
    }
    
    
    //MARK: - Driver Location Update
    /*
     Getting driver location and update to firebase realtime database
     */
    func sendToDataBase (lat:String,lng:String) {
        guard self.strTripID != "" else {
            print("no trip found")
            return
        }
        let tracking = self.ref.child("live_tracking")
        var locationInfo = [String: Any]()
        locationInfo["lat"] = lat
        locationInfo["lng"] = lng
        tracking.child(strTripID).setValue(locationInfo)
        
    }
    // update the location to the server
    @objc func updateCurrentLocationToServer()
    {
      
        var dicts = [String: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["latitude"] = strLatitude
        dicts["longitude"] = strLongitude
        dicts["car_id"] = Constants().GETVALUE(keyname: USER_CAR_ID)
        dicts["status"] = Constants().GETVALUE(keyname: TRIP_STATUS)
        if isTripStarted
        {
            dicts["total_km"] = self.getDistanceFromPreviousLocation(latitude: strLatitude, longitude: strLongitude)
            dicts["trip_id"] = strTripID
        }
        
        UberAPICalls().PostRequest(dicts,methodName:METHOD_UPDATING_DRIVER_LOCATION as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let endModel = response as! GeneralModel
            OperationQueue.main.addOperation {
                if endModel.status_code == "1"
                 {
//                    Constants().STOREVALUE(value: "Offline", keyname: USER_ONLINE_STATUS)
//                    Constants().STOREVALUE(value: "Offline", keyname: TRIP_STATUS)
                }
                else
                {
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
                if(!self.checkNetworkStatus())
                {
                    self.appDelegate.createToastMessage("Network disconnected".localize, bgColor: UIColor.black, textColor: UIColor.white)
                    print("Network disconnected")
                }
                print(error.localizedDescription)
                self.appDelegate.createToastMessage(error.localizedDescription, bgColor: UIColor.black, textColor: UIColor.white)
                
            }
        })
    }
    
    //MARK: reachability class
    func checkNetworkStatus() -> Bool {
        let reachability: Reachability = Reachability.forInternetConnection()
        let networkStatus = reachability.currentReachabilityStatus().rawValue;
        var isAvailable  = false;
        switch networkStatus {
        case (NotReachable.rawValue):
            isAvailable = false;
            break;
        case (ReachableViaWiFi.rawValue):
            isAvailable = true;
            break;
        case (ReachableViaWWAN.rawValue):
            isAvailable = true;
            break;
        default:
            isAvailable = false;
            break;
        }
        return isAvailable;
    }
    
    // get the distance froum the driver lat long
    func getDistanceFromPreviousLocation(latitude: String, longitude: String) -> String
    {
        if strOldLatitude == "" && strOldLongitude == ""
        {
            strOldLatitude = strLatitude
            strOldLongitude = strLongitude
        }
        let userLocation = CLLocation(latitude: Double(strOldLatitude) ?? 0.0, longitude: Double(strOldLongitude) ?? 0.0)
        let priceLocation = CLLocation(latitude: Double(strLatitude) ?? 0.0, longitude: Double(strLongitude) ?? 0.0)
        
        if latitude == "" && longitude == ""
        {
            strOldLatitude = strLatitude
            strOldLongitude = strLongitude
        }
        else{
            strOldLatitude = latitude
            strOldLongitude = longitude
        }
        let distanceInKm = String(format: "%.2f", userLocation.distance(from: priceLocation)/1000)
        print("Distance is KM is:: \(distanceInKm)")
        return distanceInKm
        
    }
    
    
}


extension RouteVC : ProgressButtonDelegates{
    func didActivateProgress() {
        switch currentTripStatus {
        case .scheduled:
            self.callArriveNowOrBeginTripAPI(METHOD_ARRIVE_NOW as NSString)
            self.currentTripStatus = .beginTrip
        case .beginTrip:
            
            self.setRiderInfo()
            self.callArriveNowOrBeginTripAPI(METHOD_BEGIN_TRIP as NSString)
            self.currentTripStatus = .endTrip
        case .endTrip:
            self.setRiderInfo()
            self.callStaticMap()
            if timerDriverLocation != nil
            {
                self.timerDriverLocation.invalidate()
            }
            ChatInteractor.instance.deleteChats()
            self.riderProfileModel.storeRiderInfo(false)
            locationManager.stopUpdatingLocation()
            self.currentTripStatus = .rating
        default:
            print()
        }
      
    }
    
    
}
