/**
 * AppDelegate.swift
 *
 * @package GoferDriver
 * @author Trioangle Product Team
 * @version - Stable 1.0
 * @link http://trioangle.com
 */

import UIKit
import HockeySDK
import UserNotifications
import GoogleMaps
//import APScheduledLocationManager
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import AVFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate
{
    var window: UIWindow?
    var navigationController: UINavigationController!
    var isFirstTime : Bool = false
    var isDriverOnline : Bool = false
    var strDriverStatus = ""
    var timerDriverLocation = Timer()
    var isTripStarted : Bool = false
    var strLatitude = ""
    var strLongitude = ""
    var strOldLatitude = ""
    var strOldLongitude = ""
    var strTripID = ""
    var present_data = ""
    var language = ""
    var nSelectedIndex : Int = 0

    let userDefaults = UserDefaults.standard
    let uberTabBarCtrler = UITabBarController()
    var lastLocation:CLLocation?
    var locationManager = CLLocationManager()
    
    
    //MARK:- App life cycle
    // Launch the app
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.registerForRemoteNotifications(matching: ([.alert, .badge, .sound]))
        let pre = Locale.preferredLanguages[0]
        let lag = pre.components(separatedBy: "-")
        language = lag[0]
        // Override point for customization after application launch.
        // add a firebase notification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)            
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            
            Messaging.messaging().delegate = self
        }
        else {
            
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
        FirebaseApp.configure()
        
        
        
        self.window = UIWindow(frame:UIScreen.main.bounds)
        UIApplication.shared.applicationIconBadgeNumber = 0;
        GMSServices.provideAPIKey(iApp.GoogleKeys.map.key)
        
        // Registering For Push Notification
        registerForRemoteNotification()
        self.initModules()
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        self.makeSplashView(isFirstTime: true)
        return true
    }
    // update the location if app isin will enter the foreground mode
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if let trip_id = userDefaults.value(forKey: CURRENT_TRIP_ID) as? String{
            if !PipeLine.fireEvent(withName: "CHAT_OBSERVER"){ 
                
                if !ChatInteractor.instance.isInitialized{ChatInteractor.instance.initialize(withTrip: trip_id)}
                ChatInteractor.instance.getAllChats(ForView: nil, AndObserve: true)
            }
        }
        if self.timerDriverLocation != nil
        {
            self.timerDriverLocation.invalidate()
        }
        timerDriverLocation = Timer.scheduledTimer(timeInterval: 100.00, target: self, selector: #selector(self.updateCurrentLocationToServer), userInfo: nil, repeats: true)
        _ = PipeLine.fireEvent(withKey : PipeLineKey.app_entered_foreground)
    }
    
    // update the location if app isin background mode
    func applicationDidEnterBackground(_ application: UIApplication) {
        UIApplication.shared.isIdleTimerDisabled = false
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startMonitoringSignificantLocationChanges()
        
        let userTripStatus = userDefaults.value(forKey: TRIP_STATUS) as? String
        if let trip_id = userDefaults.value(forKey: CURRENT_TRIP_ID) as? String{
            if !ChatInteractor.instance.isInitialized{ChatInteractor.instance.initialize(withTrip: trip_id)}
            ChatInteractor.instance.getAllChats(ForView: nil, AndObserve: true)
        }
        print("backgroundprocess \(userTripStatus)")
        if(userTripStatus == "Offline"){
            //Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
            if self.timerDriverLocation != nil
            {
                self.timerDriverLocation.invalidate()
            }
            timerDriverLocation = Timer.scheduledTimer(timeInterval: 100.00, target: self, selector: #selector(self.updateCurrentLocationToServer), userInfo: nil, repeats: true)
        }
        else{
            
            if self.timerDriverLocation != nil
            {
                self.timerDriverLocation.invalidate()
            }
            updateCurrentLocationToServer()
            
        }
        
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.isIdleTimerDisabled = true
        let pre = Locale.preferredLanguages[0]
        let lag = pre.components(separatedBy: "-")
        language = lag[0]
        Constants().STOREVALUE(value: language, keyname: DEVICE_LANGUAGE)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
//        self.updateLanguage()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let userTripStatus = userDefaults.value(forKey: TRIP_STATUS) as? String
        if (userTripStatus != "Trip")
        {
            
            updateCurrentLocationToServer()
            
        }
        else{
            
            if self.timerDriverLocation != nil
            {
                self.timerDriverLocation.invalidate()
            }
            DispatchQueue.main.async {
                
                self.timerDriverLocation = Timer.scheduledTimer(timeInterval: 100.00, target: self, selector: #selector(self.updateCurrentLocationToServer), userInfo: nil, repeats: true)
                self.timerDriverLocation.fire()
            }
            
        }
    }
    //MARK:- 

    func initModules(){
        NetworkManager.instance.observeReachability(true)
//        Constants().STOREVALUE(value: "Offline", keyname: TRIP_STATUS)
        let userTripStatus = userDefaults.value(forKey: TRIP_STATUS) as? String
        if (userTripStatus == nil || userTripStatus == "")
        {
            userDefaults.set("", forKey: TRIP_STATUS)
        }
        else if (userTripStatus == "Trip")
        {
            Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
        }
        else if (userTripStatus == "Online" || userTripStatus == "Offline")
        {
            let sts = (userTripStatus == "Offline") ? "Offline": "Online"
            Constants().STOREVALUE(value: sts, keyname: TRIP_STATUS)
        }
        
        let userStatus = userDefaults.value(forKey: USER_STATUS) as? String
        if (userStatus == nil || userStatus == "")
        {
            userDefaults.set("", forKey: USER_STATUS)
        }
        
        let userCurrency = userDefaults.value(forKey: USER_CURRENCY_SYMBOL_ORG) as? String
        if (userCurrency == nil || userCurrency == "")
        {
            userDefaults.set("", forKey: USER_CURRENCY_SYMBOL_ORG)
        }
        
        let userdialcode = userDefaults.value(forKey: USER_DIAL_CODE) as? String
        if (userdialcode == nil || userdialcode == "")
        {
            userDefaults.set("", forKey: USER_DIAL_CODE)
        }
        
        let userOnlineStatus = userDefaults.value(forKey: USER_ONLINE_STATUS) as? String
        if (userOnlineStatus == nil || userOnlineStatus == "")
        {
            userDefaults.set("", forKey: USER_ONLINE_STATUS)
        }
        
        let userCountryCode = userDefaults.value(forKey: USER_COUNTRY_CODE) as? String
        if (userCountryCode == nil || userCountryCode == "")
        {
            userDefaults.set("", forKey: USER_COUNTRY_CODE)
        }
        
        let userDeviceToken = userDefaults.value(forKey: USER_DEVICE_TOKEN) as? String
        if (userDeviceToken == nil || userDeviceToken == "")
        {
            userDefaults.set("", forKey: USER_DEVICE_TOKEN)
        }
        userDefaults.synchronize()
        if let trip_id = UserDefaults.standard.value(forKey: CURRENT_TRIP_ID) as? String{
            if !ChatInteractor.instance.isInitialized{ChatInteractor.instance.initialize(withTrip: trip_id)}
            ChatInteractor.instance.getAllChats(ForView: nil, AndObserve: true)
        }
        
    }
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    
    @objc(applicationReceivedRemoteMessage:) func application(received remoteMessage: MessagingRemoteMessage) {
        print("dfg")
        print(remoteMessage.appData)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String){
        
        print("didRefreshRegistrationToken")
        registerForRemoteNotification()
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage){
        
        print("recive msg")
    }
    // MARK: Getting Main Storyboard Name
    func makeSplashView(isFirstTime:Bool)
    {
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        var getStoryBoardName : String = ""
        switch (deviceIdiom)
        {
        case .pad:
            getStoryBoardName = "Main_iPad"
        case .phone:
            getStoryBoardName = "Main"
        default:
            break
        }
        
        let storyBoardMenu : UIStoryboard = UIStoryboard(name: getStoryBoardName, bundle: nil)
        
        let splashView = storyBoardMenu.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        splashView.isFirstTimeLaunch = isFirstTime
        window!.rootViewController = splashView
        window!.makeKeyAndVisible()
    }
    
    // MARK: Getting Main Storyboard Name
    func getMainStoryboardName() -> String
    {
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        var getStoryBoardName : String = ""
        switch (deviceIdiom)
        {
        case .pad:
            getStoryBoardName = "Main_iPad"
        case .phone:
            getStoryBoardName = "Main"
        default:
            break
        }
        
        return getStoryBoardName
    }
    // MARK: Set the Root View Controller
    func onSetRootViewController(viewCtrl:UIViewController)
    {
        viewCtrl.view.removeFromSuperview()
        self.updateCurrentLocationToServer()
        
        let getMainPage =  userDefaults.object(forKey: "getmainpage")  as? NSString
        if getMainPage == "driver"
        {
            window?.rootViewController = self.generateUberDriverTabbarController()
             
        }
        else
        {
            let userStatus = userDefaults.value(forKey: USER_STATUS) as? String
            if userStatus == "Car_details"
            {
                self.gotoVehicleDetailPage()
            }
            else if userStatus == "Document_details"
            {
                self.gotoDocumentPage()
            }
            else
            {
                self.showLoginView()
            }
        }
    }
    // Goto Document Paeg
    func gotoDocumentPage()
    {
        let storyBoardMenu : UIStoryboard = UIStoryboard(name: self.getMainStoryboardName(), bundle: nil)
        let vcMenuVC  = storyBoardMenu.instantiateViewController(withIdentifier: "DocumentMainVC") as! DocumentMainVC
        vcMenuVC.isHideBackBtn = true
        navigationController = UINavigationController(rootViewController: vcMenuVC)
        navigationController?.isNavigationBarHidden = true
        self.window?.rootViewController = navigationController;
        window?.makeKeyAndVisible()
        
        self.enableHockeyAppSdk()
    }
    // Goto Vwhicle page
    func gotoVehicleDetailPage()
    {
        let storyBoardMenu : UIStoryboard = UIStoryboard(name: self.getMainStoryboardName(), bundle: nil)
        let vcMenuVC  = storyBoardMenu.instantiateViewController(withIdentifier: "ChooseVehicle") as! ChooseVehicle
        vcMenuVC.isHideBackBtn = true
        vcMenuVC.isFromOtherPage = true
        navigationController = UINavigationController(rootViewController: vcMenuVC)
        navigationController?.isNavigationBarHidden = true
        self.window?.rootViewController = navigationController;
        window?.makeKeyAndVisible()
        
        self.enableHockeyAppSdk()
    }
    // hockey app enable
    func enableHockeyAppSdk()
    {
//                BITHockeyManager.shared().configure(withIdentifier: "b4fbb64741bb4abb8a5e53e7af7eccac")
//                BITHockeyManager.shared().isStoreUpdateManagerEnabled = true
//                BITHockeyManager.shared().start()
//                BITHockeyManager.shared().authenticator.authenticateInstallation()
    }
    
    // MARK: Set App Root View controller
    func showLoginView()
    {
        let storyBoardMenu : UIStoryboard = UIStoryboard(name: self.getMainStoryboardName(), bundle: nil)
        let vcMenuVC  = storyBoardMenu.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        navigationController = UINavigationController(rootViewController: vcMenuVC)
        navigationController?.isNavigationBarHidden = true
        self.window?.rootViewController = navigationController;
        window?.makeKeyAndVisible()
        
        self.enableHockeyAppSdk()
    }
    // Set the Tab bar
    func generateUberDriverTabbarController() -> UITabBarController
    {
        var getStoryBoardName : String = ""
        
        if UberSupport().isPad()
        {
            getStoryBoardName = "Main_iPad"
        }
        else{
            getStoryBoardName = "Main"
        }
        let storyBoard : UIStoryboard = UIStoryboard(name: getStoryBoardName, bundle: nil)
        
        UITabBar.appearance().tintColor =  .ThemeLight
        UITabBar.appearance().barTintColor = .ThemeMain
        
        let myVC1 = storyBoard.instantiateViewController(withIdentifier: "DriverHomeViewController") as! DriverHomeViewController
        let icon1 = UITabBarItem(title: NSLocalizedString("HOME", comment: ""), image: UIImage(named: "home.png"), selectedImage: UIImage(named: "home.png"))
        myVC1.tabBarItem = icon1
        let nvc1 = UINavigationController(rootViewController: myVC1)
        
        let myVC2 = storyBoard.instantiateViewController(withIdentifier: "EarningsVC") as! EarningsVC
        var barItem = UITabBarItem()
        if userDefaults.bool(forKey: IS_COMPANY_DRIVER) {
             barItem = UITabBarItem(title: NSLocalizedString("TRIPS", comment: ""), image: UIImage(named: "tripsicon"), selectedImage: UIImage(named: "tripsicon"))
        }else {
            barItem = UITabBarItem(title: NSLocalizedString("EARNINGS", comment: ""), image: UIImage(named: "earning.png"), selectedImage: UIImage(named: "earning.png"))
        }
       
        myVC2.tabBarItem = barItem
        let nvc2 = UINavigationController(rootViewController: myVC2)
        
        let myVC3 = storyBoard.instantiateViewController(withIdentifier: "RatingsVC") as! RatingsVC
        let icon3 = UITabBarItem(title: NSLocalizedString("RATINGS", comment: ""), image: UIImage(named: "rating.png"), selectedImage: UIImage(named: "rating.png"))
        myVC3.tabBarItem = icon3
        let nvc3 = UINavigationController(rootViewController: myVC3)
        
        let myVC4 = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        let icon4 = UITabBarItem(title: NSLocalizedString("ACCOUNT", comment: ""), image: UIImage(named: "profile.png"), selectedImage: UIImage(named: "profile.png"))
        myVC4.tabBarItem = icon4
        let nvc4 = UINavigationController(rootViewController: myVC4)
        nvc1.isNavigationBarHidden = true
        nvc2.isNavigationBarHidden = true
        nvc3.isNavigationBarHidden = true
        nvc4.isNavigationBarHidden = true
        nvc4.navigationBar.barStyle = .default
        nvc1.navigationBar.barStyle = .default
        let controllers = [nvc1,nvc2,nvc3,nvc4]
        uberTabBarCtrler.delegate=self
        uberTabBarCtrler.viewControllers = controllers
        
        window?.rootViewController = uberTabBarCtrler
        uberTabBarCtrler.selectedIndex=0
        
        self.window?.makeKeyAndVisible()
        self.enableHockeyAppSdk()
        return uberTabBarCtrler
    }
   // logout the app
    func logOutDidFinish()
    {
        let controllersArray = self.uberTabBarCtrler.viewControllers
//        for tempVC: UIViewController in controllersArray!
//        {
//            tempVC.removeFromParentViewController()
//        }
        controllersArray?.forEach({$0.removeFromParent()})
        Constants().STOREVALUE(value: "", keyname: USER_ACCESS_TOKEN)
        Constants().STOREVALUE(value: "", keyname: LICENSE_BACK)
        Constants().STOREVALUE(value: "", keyname: LICENSE_FRONT)
        Constants().STOREVALUE(value: "", keyname: LICENSE_INSURANCE)
        Constants().STOREVALUE(value: "", keyname: LICENSE_RC)
        Constants().STOREVALUE(value: "", keyname: LICENSE_PERMIT)
        Constants().STOREVALUE(value: "", keyname: USER_PAYPAL_EMAIL_ID)        
        Constants().STOREVALUE(value: "Offline", keyname: USER_ONLINE_STATUS)
        Constants().STOREVALUE(value: "Offline", keyname: TRIP_STATUS)
        userDefaults.set(false, forKey: IS_COMPANY_DRIVER)
        userDefaults.set("", forKey:"getmainpage")
        userDefaults.set("", forKey:USER_STATUS)
        DriverStatus.removerFromPreference()
        userDefaults.synchronize()
        guard self.window?.rootViewController is UITabBarController else {
            return
        }

        self.showLoginView()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
    }
    
    // MARK: Application Life cycle delegate methods
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }
    
    
    func updateLanguage () {
        var dicts = [String: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["language"] = language
        UberAPICalls().PostRequest(dicts,methodName:METHOD_LANGUAGE as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let endModel = response as! GeneralModel
            
            OperationQueue.main.addOperation {
                if endModel.status_code == "1"
                {
                    
                }
                else
                {
                   
                }
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
            }
        })
    }
//MARK: - API CALL -> UPDATE DRIVER CURRENT LOCATION TO SERVER
     @objc func updateCurrentLocationToServer()
    {
//        var dicts = [String: Any]()
//        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
//        dicts["latitude"] = Constants().GETVALUE(keyname: USER_LATITUDE)
//        dicts["longitude"] = Constants().GETVALUE(keyname: USER_LONGITUDE)
//        dicts["car_id"] = Constants().GETVALUE(keyname: USER_CAR_ID)
//        dicts["status"] = Constants().GETVALUE(keyname: TRIP_STATUS)
//        if isTripStarted
//        {
//            dicts["total_km"] = self.getDistanceFromPreviousLocation(latitude: strLatitude, longitude: strLongitude)
//            dicts["trip_id"] = strTripID
//
//        }
//
//        UberAPICalls().PostRequest(dicts,methodName:METHOD_UPDATING_DRIVER_LOCATION as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
//            let endModel = response as! GeneralModel
//
//            OperationQueue.main.addOperation {
//                if endModel.status_code == "1"
//                {
////                    Constants().STOREVALUE(value: "Offline", keyname: USER_ONLINE_STATUS)
////                    Constants().STOREVALUE(value: "Offline", keyname: TRIP_STATUS)
//                }
//                else
//                {
//                    if endModel.status_message.lowercased() == "please complete your current trip"
//                    {
//
//                    }
//                    else
//                    {
//                    }
//                }
//            }
//        }, andFailureBlock: {(_ error: Error) -> Void in
//            OperationQueue.main.addOperation {
//            }
//        })
    }
    
    func createRegion(location:CLLocation?) {
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let coordinate = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
            let regionRadius = 50.0
            
            let region = CLCircularRegion(center: CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude),
                                          radius: regionRadius,
                                          identifier: "aabb")
            
            region.notifyOnExit = true
            region.notifyOnEntry = true
            self.locationManager.stopUpdatingLocation()
            self.locationManager.startMonitoring(for: region)
        }
        else {
            print("System can't track regions")
        }
    }
    
    // update the location
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered Region")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited Region")
        
        locationManager.stopMonitoring(for: region)
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if UIApplication.shared.applicationState == .active {
        } else {
            //App is in BG/ Killed or suspended state
            //send location to server
            // create a New Region with current fetched location
            let location = locations.last
            lastLocation = location
            updateCurrentLocationToServer()
            //Make region and again the same cycle continues.
            self.createRegion(location: lastLocation)
        }
    }
    func getDistanceFromPreviousLocation(latitude: String, longitude: String) -> String
    {
        
        if strOldLatitude == "" && strOldLongitude == ""
        {
            strOldLatitude = strLatitude
            strOldLongitude = strLongitude
        }
        let userLocation = CLLocation(latitude: Double(strOldLatitude)!, longitude: Double(strOldLongitude)!)
        let priceLocation = CLLocation(latitude: Double(strLatitude)!, longitude: Double(strLongitude)!)
        
        
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
        // MARK: - Remote Notification Methods // <= iOS 9.x
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        //InstanceID.instanceID().token()
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("______Error fetching remote instange ID: \(error)")
            } else if let result = result {
                let refreshedToken = result.token
                print("====Remote instance ID token: \(refreshedToken)")
                print("====InstanceID token: \(String(describing: refreshedToken))")
                Constants().STOREVALUE(value: refreshedToken, keyname: USER_DEVICE_TOKEN)
                let userStatus = self.userDefaults.value(forKey: USER_ACCESS_TOKEN) as? String
                if (userStatus != nil && userStatus != "")
                {
                    self.sendDeviceTokenToServer(strToken: refreshedToken)   // UPDATING DEVICE TOKEN FOR LOGGED IN USER
                    print("\(refreshedToken)")
                }
                else{
                    self.tokenRefreshNotification()
                }
            }
        }
    }
    // MARK: Get Token Refersh
    

    func tokenRefreshNotification() {
       InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                 let refreshedToken = result.token
                print("Remote instance ID token: \(refreshedToken)")
                print("InstanceID token: \(String(describing: refreshedToken))")
                Constants().STOREVALUE(value: refreshedToken, keyname: USER_DEVICE_TOKEN)
                self.connectToFcm()
            }
        }
        
        
    }
    
    // get refersh the token
//    func tokenRefreshNotification() {
//       InstanceID.instanceID().instanceID { (result, error) in
//            if let error = error {
//                print("Error fetching remote instange ID: \(error)")
//            } else if let result = result {
//                 let refreshedToken = result.token
//                print("Remote instance ID token: \(refreshedToken)")
//                print("InstanceID token: \(String(describing: refreshedToken))")
//                Constants().STOREVALUE(value: refreshedToken, keyname: USER_DEVICE_TOKEN)
//                self.connectToFcm()
//            }
//        }
//        
//        
//    }
    // Cannect the FCM
    func connectToFcm() {
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
                return
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        
//        guard InstanceID.instanceID().token() != nil else {
//            // Won't connect since there is no token
//            return
//        }
        // Disconnect previous FCM connection if it exists.
        if Messaging.messaging().isDirectChannelEstablished{
            print("Connected to FCM.")
        } else {
            print("Disconnected from FCM.")
        }
//        Messaging.messaging().connect { (error) in
//            if (error != nil) {
//                print("Unable to connect with FCM. \(String(describing: error))")
//            } else {
//                print("Connected to FCM.")
//            }
//        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [String : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("recieved")
    }
    
    // }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Error = ",error.localizedDescription)
    }
    
    
    // MARK: UNUserNotificationCenter Delegate // >= iOS 10
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let dict = notification.request.content.userInfo as NSDictionary
        if let uniqId = dict.value(forKey: "UUID") as? String,uniqId == CURRENT_TRIP_ID{
            
            completionHandler([.alert,.sound])
            return
        }
        let custom = dict["custom"] as Any
        let data = convertStringToDictionary(text: custom as? String ?? String())
        if (["ride_request","manual_booking_trip_booked_info"]).contains(Array(data!.keys)[0]) {
            completionHandler([])//
        }

        else if (["custom_message"]).contains(Array(data!.keys)[0]) //Admin custom_message
        {
            

            completionHandler([.alert,.sound])
            return
        }
        else if Array(data!.keys)[0] == "reference_completed"{
            
            completionHandler([.sound])
        }else{
             completionHandler([.sound])
        }
        
        self.handlePushNotificaiton(userInfo: (data as NSDictionary?)!)
        //completionHandler([.sound,.alert])
       
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let dict = response.notification.request.content.userInfo as NSDictionary
        if let uniqId = dict.value(forKey: "UUID") as? String,uniqId == CURRENT_TRIP_ID{
            //Click action handling
            let tripId = userDefaults.string(forKey: CURRENT_TRIP_ID) ?? "blah"
            let chatVC = ChatVC.initWithStory(withTripId: tripId)
            self.forcePresent(theController: chatVC)
            return
        }
        let custom = dict["custom"] as! Any
        let data = convertStringToDictionary(text: custom as? String ?? String())
        self.handlePushNotificaiton(userInfo: data as! NSDictionary)
        completionHandler()
    }
    
    
    // Convert the string to Dictinory formate
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    //MARK: HANDLE PUSH NOTIFICATION
    func handlePushNotificaiton(userInfo: NSDictionary)
    {
        let preference = UserDefaults.standard
        let getMainPage =  userDefaults.object(forKey: "getmainpage")  as? NSString
        
        if getMainPage == "driver"
        {
            if userInfo["ride_request"] != nil
            {
                if present_data == "1"{
                    uberTabBarCtrler.selectedIndex = 0
                    let dictTemp = userInfo["ride_request"] as! NSDictionary
                   
                    self.showRequestPage(dict: dictTemp)
                    
                    
                }
                else{
                    uberTabBarCtrler.selectedIndex = 0
                    let dictTemp = userInfo["ride_request"] as! NSDictionary
                    
                    self.showRequestPage(dict: dictTemp)
                   
                }
                
                
            }
            else if userInfo["cancel_trip"] != nil
            {
                preference.removeObject(forKey: TRIP_RIDER_RATING)
                preference.removeObject(forKey: TRIP_RIDER_NAME)
                preference.removeObject(forKey: TRIP_RIDER_THUMB_URL)
                Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
                Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancel_trip"), object: self, userInfo: nil)
            }
            else if userInfo["trip_payment"] != nil
            {
                Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
                Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
                let dictTemp = userInfo["trip_payment"] as! NSDictionary
                let info: [String: Any] = [
                    "rider_thumb_image" : UberSupport().checkParamTypes(params:dictTemp, keys:"rider_thumb_image"),
                    "trip_id" : UberSupport().checkParamTypes(params:dictTemp, keys:"trip_id"),
                    ]
                if let json = userInfo["trip_payment"] as? JSON{
                   _ = PipeAdapter.fireEvent("PaymentSuccess", data: json)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PaymentSuccess"), object: self, userInfo: info)
                }
              
            }else if let manualReq = userInfo["manual_booking_trip_assigned"]{
                let json = manualReq as! JSON
                print(json)
                dump(json)
                let riderModel = RiderDetailModel(withJson: json)
                riderModel.tripStatus = .manuallyBooked
                riderModel.booking_type = .manualBooking
                sleep(2)
                self.gotoToRouteView(riderModel)
                
            }else if let manualReq = userInfo["manual_booking_trip_reminder"]{
                let json = manualReq as! JSON
                print(json)
                dump(json)
                let requestModel = ManualRequestModel(json)
                requestModel.tripStatus = .manuallyBookedReminder
                let manualRequestVC = ManualRequestVC.initWithStory(forRequest: requestModel)
                self.forcePresent(theController: manualRequestVC)
                
            }else if let manualReq = userInfo["manual_booking_trip_canceled_info"]{
                let json = manualReq as! JSON
                print(json)
                dump(json)
                let requestModel = ManualRequestModel(json)
                requestModel.tripStatus = .manualBookiingCancelled
                let manualRequestVC = ManualRequestVC.initWithStory(forRequest: requestModel)
                self.forcePresent(theController: manualRequestVC)
                
            }else if let manualReq = userInfo["manual_booking_trip_booked_info"]{
                let json = manualReq as! JSON
                print(json)
                dump(json)
                let requestModel = ManualRequestModel(json)
                requestModel.tripStatus = .manualBookingInfo
                let manualRequestVC = ManualRequestVC.initWithStory(forRequest: requestModel)
                self.forcePresent(theController: manualRequestVC)
                
            }else if userInfo["custom_message"] != nil
            {
//                self.`
            }
            
        }
    }
    
    func forcePresent(theController vc : UIViewController){
        if let nav = self.window?.rootViewController as? UINavigationController{
            nav.present(vc, animated: true, completion: nil)
        }else if let root = self.window?.rootViewController{
            root.present(vc, animated: true, completion: nil)
        }

    }
    func forcePush(theController vc : UIViewController){
        if let nav = self.window?.rootViewController as? UINavigationController{
            nav.pushViewController(vc, animated: true)
        }
//        else if let root = self.window?.rootViewController as? UITabBarController{
//            nav.pushViewController(vc, animated: true)
//        }
    }
    // CHECKING TRIP STATUS
    func gotoToRouteView(_ riderProfileModel: RiderDetailModel)
    {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let tripView = story.instantiateViewController(withIdentifier: "RouteVC") as! RouteVC
        tripView.strTripID = riderProfileModel.trip_id
        tripView.riderProfileModel = riderProfileModel
        tripView.strPickupLocation = riderProfileModel.pickup_location
       // tripView.strTripStatus = riderProfileModel.trip_status
        tripView.currentTripStatus = riderProfileModel.tripStatus
        tripView.isFromTripPage = true
        self.loopAndPlay()
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            self.continuePlaying = false
            self.player?.stop()
            self.player = nil
        }
        
        window?.rootViewController = self.generateUberDriverTabbarController()
        return
        
        
        
        
    }
    func handleInCompleteTrip(withRider rider : RiderDetailModel){
        let mainStory = Stories.main.instance
        
        switch rider.tripStatus {
        case .cancelled,.completed:
            print("ignoring these scenarios")
        case .rating:
            let propertyView = mainStory.instantiateViewController(withIdentifier: "RateYourRideVC") as! RateYourRideVC
            let id = rider.getTripID
            propertyView.strRiderImgUrl = rider.rider_thumb_image
            propertyView.strTripID = String(id)
            propertyView.isFromTripPage = true
            
            self.navigationController?.pushViewController(propertyView, animated: true)
        case .payment:
            let tripView = mainStory.instantiateViewController(withIdentifier: "MakePaymentVC") as! MakePaymentVC
            tripView.arrInfoKey = NSMutableArray(array: rider.invoices.compactMap({$0 as Any}))
            tripView.payment_method = rider.getPaymentMethod
            tripView.totalAmt = rider.getPayableAmount
            tripView.strTripID = rider.getTripID
            tripView.isFromTripPage = true
            self.navigationController?.pushViewController(tripView, animated: true)
        case .scheduled,.beginTrip,.endTrip:
            if !rider.pickup_latitude.isEmpty,
                !rider.pickup_longitude.isEmpty{
                let preference = UserDefaults.standard
                preference.set("\(rider.pickup_latitude),\(rider.pickup_longitude)", forKey: PICKUP_COORDINATES)
                //preference.set(rider.pickup_latitude)
            }
            self.gotoToRouteView(rider)
        default:
            print("")
        }
        
        
    }
    var player: AVAudioPlayer?
    let AUDIO_PLAY_SPEED = 0.7
    let myThread = DispatchQueue.init(label: "MyThread")
    var continuePlaying = true
    func loopAndPlay(){
        
        self.myThread.async {
            while self.continuePlaying{
                self.playSound("ub__reminder")
                sleep(1)
            }
        }
        
    }
    func playSound(_ fileName: String) {
        let url = Bundle.main.url(forResource: fileName, withExtension: "mp3")!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    //MARK: ShowRequestPage
    
    func showRequestPage(dict : NSDictionary){
        var info: [String: Any] = [
            "pickup_latitude" : UberSupport().checkParamTypes(params:dict, keys:"pickup_latitude"),
            "pickup_longitude" : UberSupport().checkParamTypes(params:dict, keys:"pickup_longitude"),
            "request_id" : UberSupport().checkParamTypes(params:dict, keys:"request_id"),
            "pickup_location" : UberSupport().checkParamTypes(params:dict, keys:"pickup_location"),
            "min_time" : UberSupport().checkParamTypes(params:dict, keys:"min_time"),
            "just_launched" : false,
            ]
        if let window = self.window,
            let root = window.rootViewController,
            root == uberTabBarCtrler{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ResquestRide"), object: self, userInfo: info)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                //info["just_launched"] = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ResquestRide"), object: self, userInfo: info)
            }
        }
    }
    
    // MARK: Register Push notification Class Methods
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound]) { (granted, error) in
                if error == nil{
                    DispatchQueue.main.async(execute: {
                      UIApplication.shared.registerForRemoteNotifications()
                    }) 
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    var s = 0
    
    //MARK: ----- UPDATING DEVICE TO SERVER -----
    func sendDeviceTokenToServer(strToken: String)
    {
        if s == 0 {
            var devicetoken = strToken
            print("aaaaaaaa = \(devicetoken)")
            if devicetoken.isEmpty {
                devicetoken = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) ?? ""
            }
            guard !devicetoken.isEmpty else {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.tokenRefreshNotification()
                }
                return
            }
            var dicts = [String: Any]()
            dicts["token"] = devicetoken//
            Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
            dicts["device_id"] = String(format:"%@",strToken)
            UberAPICalls().PostRequest(dicts,methodName: METHOD_UPDATE_DEVICE_TOKEN as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
                let genModel = response as! GeneralModel
                OperationQueue.main.addOperation {
                    if genModel.status_code == "1"   // Number Not exist
                    {
                        
                    }
                    else
                    {
                        //                    self.tokenRefreshNotification()
                    }
                    //iApp.HamellyError.server.error
                }
            }, andFailureBlock: {(_ error: Error) -> Void in
                OperationQueue.main.addOperation {
                    self.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
                }
            })
            s = 1
            
        }
    }
    
    // MARK: - Display Toast Message
    func createToastMessage(_ strMessage:String, bgColor: UIColor = .ThemeMain, textColor: UIColor = .white)
    {
        guard let window = UIApplication.shared.keyWindow else{return}
        let lblMessage=UILabel(frame: CGRect(x: 0,
                                             y: window.frame.size.height + 70,
                                             width: window.frame.size.width,
                                             height: 70))
        lblMessage.tag = 500
        lblMessage.text = YSSupport.isNetworkRechable() ? strMessage : iApp.GoferError.connection.error
        lblMessage.textColor = textColor
        lblMessage.backgroundColor = .ThemeMain//bgColor
        lblMessage.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
        lblMessage.textAlignment = NSTextAlignment.center
        lblMessage.numberOfLines = 0
        lblMessage.layer.shadowColor = UIColor.ThemeMain.cgColor;
        lblMessage.layer.shadowOffset = CGSize(width:0, height:1.0);
        lblMessage.layer.shadowOpacity = 0.5;
        lblMessage.layer.shadowRadius = 1.0;
        
        moveLabelToYposition(lblMessage)
        UIApplication.shared.keyWindow?.addSubview(lblMessage)
    }
    
    func moveLabelToYposition(_ lblView:UILabel)
    {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
            guard let window = UIApplication.shared.keyWindow else{return}
            lblView.frame = CGRect(x: 0,
                                   y: window.frame.size.height - 70,
                                   width: window.frame.size.width,
                                   height: 70)
        }, completion: { (finished: Bool) -> Void in
            self.onCloseAnimation(lblView)
        })
    }
    
    // Remove toast message
    func onCloseAnimation(_ lblView:UILabel)
    {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        UIView.animate(withDuration: 0.3, delay: 2.5, options: UIView.AnimationOptions(), animations: { () -> Void in
            guard let window = UIApplication.shared.keyWindow else{return}
            lblView.frame = CGRect(x: 0,
                                   y: window.frame.size.height + 70,
                                   width: window.frame.size.width,
                                   height: 70)
        }, completion: { (finished: Bool) -> Void in
            lblView.removeFromSuperview()
        })
    }
    
    
    func createToastMessageForAlamofire(_ strMessage:String, bgColor: UIColor, textColor: UIColor, forView:UIView)
    {
        let lblMessage=UILabel(frame: CGRect(x: 0, y: (forView.frame.size.height)+70, width: (forView.frame.size.width), height: 70))
        lblMessage.tag = 500
        lblMessage.text = YSSupport.isNetworkRechable() ? NSLocalizedString(strMessage, comment: "") : NSLocalizedString(iApp.GoferError.connection.error, comment: "")
        lblMessage.textColor = textColor
        lblMessage.backgroundColor = bgColor
        lblMessage.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
        lblMessage.textAlignment = NSTextAlignment.center
        lblMessage.numberOfLines = 0
        lblMessage.layer.shadowColor = UIColor.ThemeMain.cgColor;
        lblMessage.layer.shadowOffset = CGSize(width:0, height:1.0);
        lblMessage.layer.shadowOpacity = 0.5;
        lblMessage.layer.shadowRadius = 1.0;
        
        downTheToast(lblView: lblMessage, forView: forView)
        UIApplication.shared.keyWindow?.addSubview(lblMessage)
    }
    
    func downTheToast(lblView:UILabel, forView:UIView) {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
            lblView.frame = CGRect(x: 0, y: (forView.frame.size.height)-70, width: (forView.frame.size.width), height: 70)
        }, completion: { (finished: Bool) -> Void in
            self.closeTheToast(lblView, forView: forView)
        })
    }
    
    func closeTheToast(_ lblView:UILabel, forView:UIView)
    {
        UIView.animate(withDuration: 0.3, delay: 3.5, options: UIView.AnimationOptions(), animations: { () -> Void in
            lblView.frame = CGRect(x: 0, y: (forView.frame.size.height)+70, width: (forView.frame.size.width), height: 70)
        }, completion: { (finished: Bool) -> Void in
            lblView.removeFromSuperview()
        })
    }
 
    
}

