/**
 * SplashVC.swift
 *
 * @package GoferDriver
 * @author Trioangle Product Team
 * @version - Stable 1.0
 * @link http://trioangle.com
 */

import UIKit
import Alamofire

class SplashVC: UIViewController ,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum) {
        switch response {
        case .forceUpdate(let update):
            self.shouldForceUpdate(update)
        default:
            print()
        }
    }
    
    func onFailure(error: String) {
        print(error)
        //self.routeToScreen(true)
    }
    var hasLaunchedAlready : Bool = false
    var window = UIWindow()
    @IBOutlet var lblMenuTitle: UILabel!
    @IBOutlet var imgAppIcon: UIImageView!
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var isFirstTimeLaunch : Bool = false
    
    var transitionDelegate: UIViewControllerTransitioningDelegate?
    @IBOutlet var button: UIButton!
    var timer : Timer?

    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        UIApplication.shared.statusBarStyle = .lightContent
        if YSSupport.checkDeviceType()
        {
            if !(UIApplication.shared.isRegisteredForRemoteNotifications)
            {
                let settingsActionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("Message!!!", comment: ""), message: NSLocalizedString("Please enable Push Notification in settings for continue to login.", comment: ""), preferredStyle:UIAlertController.Style.alert)
                settingsActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
                    self.appDelegate.registerForRemoteNotification()
                }))
                present(settingsActionSheet, animated:true, completion:nil)
                
            }
        }
        self.timer = Timer.scheduledTimer(timeInterval:1.0, target: self, selector: #selector(self.onSetRootViewController), userInfo: nil, repeats: true)
        self.apiInteractor = APIInteractor(self)
//        UIApplication.shared.statusBarStyle = .default
        _ = PipeLine.createEvent(key: PipeLineKey.app_entered_foreground) {
            self.onStart()
        }
    }
    
    // showing root viewcontroller after splash page shown
    @objc func onSetRootViewController()
    {
        if !iApp.isSimulator {
            guard let fcmToken = UserDefaults.standard.string(forKey: USER_DEVICE_TOKEN),
                !fcmToken.isEmpty,
                fcmToken != " " else{
                    self.appDelegate.registerForRemoteNotification()
                    return
            }
        }
        
        self.timer?.invalidate()
//        print("FCM : \(fcmToken)")
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        appDelegate.onSetRootViewController(viewCtrl:self)
//                self.onStart()
    }
    //Onapplicaiton start
    func onStart()
    {
        guard let appVersion = iApp.instance.version else {return}
        var params = Parameters()
        params["version"] = appVersion
//        _ = self.apiInteractor?.getResponse(forAPI: APIEnums.force_update, params: params)
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.onSetRootViewController(viewCtrl:self)
    }
    func shouldForceUpdate(_ should : Bool){
        if should{
            self.presentAlertWithTitle(title: "New Version Available",
                                       message: "Please update our app to enjoy the latest features! ",
                                       options: "Visit App store") { (option) in
                                        self.goToAppStore()
            }
        }else{
            
            guard !self.hasLaunchedAlready else {return}
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.onSetRootViewController(viewCtrl:self)
            self.hasLaunchedAlready = true
        }
    }
    //Redirect to App Store
    func goToAppStore(){
        
        if let url = iApp.Driver().appStoreLink{
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
                // Fallback on earlier versions
            }
        }
    }
}
