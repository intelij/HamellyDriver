/**
* RequestAcceptVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import AVFoundation
import MapKit

class RequestAcceptVC : UIViewController, ProgressViewHandlerDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var player: AVAudioPlayer?

    // MARK: - ViewController Methods
    @IBOutlet var viewDetailHoder: UIView!
    @IBOutlet var btnAccept: UIButton!
    
    @IBOutlet var lblLocationName: UILabel!
    @IBOutlet var lblPickUpMins: UILabel!
    @IBOutlet var lblAcceptOrCancel: UILabel!
    @IBOutlet var viewCircular: BIZCircularProgressView!
    @IBOutlet var viewAccepting: UIView!
    @IBOutlet var mapView: UIImageView!

    var rippleEffect = LNBRippleEffect()
    
    var isCalled : Bool = false
    var justLaunced = false
    
    var timerAni = Timer()
    var timerCancelTrip = Timer()
    var strRequestID = ""
    var strPickupLocation = ""
    var strPickupTime = ""
    var strPickUpLatitude = ""
    var strPickUpLongitude = ""

    var spinnerView = JTMaterialSpinner()
    var riderProfileModel : RiderDetailModel!
    
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.endEditing(true)
        setStaticMap()

        self.appDelegate.registerForRemoteNotification()
//        UIApplication.shared.statusBarStyle = .lightContent
        Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)

        lblPickUpMins.text = String(format:(strPickupTime == "1") ? NSLocalizedString("%@ MINUTE", comment: "") : NSLocalizedString("%@ MINUTES", comment:
            ""),strPickupTime)
        lblLocationName.text = strPickupLocation
        
        let frame = CGRect(x: (self.view.frame.size.width - (self.view.frame.size.width-80)) / 2, y: (self.view.frame.size.height - (self.view.frame.size.height - viewDetailHoder.frame.size.height)) / 2, width: self.view.frame.size.width-80, height: self.view.frame.size.width-80)
        
        viewAccepting.isHidden = true
        btnAccept.frame = CGRect(x: 0, y: (self.view.frame.size.height - (self.view.frame.size.height + 80 - viewDetailHoder.frame.size.height)) / 2, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        
        viewCircular.frame = CGRect(x: (self.view.frame.size.width - (self.view.frame.size.width-60)) / 2, y: (self.view.frame.size.height - (self.view.frame.size.height + 20 - viewDetailHoder.frame.size.height)) / 2, width: self.view.frame.size.width-60, height: self.view.frame.size.width-60)
        viewCircular.layer.cornerRadius = (self.view.frame.size.width-60) / 2
        
        
        mapView.frame = frame
        mapView.layer.cornerRadius = (self.view.frame.size.width-80) / 2
        mapView.clipsToBounds = true
        
        rippleEffect = LNBRippleEffect(image: UIImage(named: ""), frame: frame, color: UIColor.clear, target: #selector(self.onCallTimer), id: self)
        rippleEffect.setRippleColor(UIColor.clear)
        rippleEffect.setRippleTrailColor(UIColor(red: CGFloat((28.0 / 255.0)), green: CGFloat((212.0 / 255.0)), blue: CGFloat((255.0 / 255.0)), alpha: CGFloat(0.5)))
        self.view.addSubview(rippleEffect)
        self.view.addSubview(mapView)
        self.view.addSubview(btnAccept)
        
        viewCircular.progressLineWidth = 8
        let progressView = BIZProgressViewHandler.init(progressView: viewCircular,
                                                       minValue:  0,
                                                       maxValue: self.justLaunced ? 5 : 9)
        progressView?.liveProgress = true
        progressView?.delegate = self
        progressView?.start()
        
        btnAccept.backgroundColor = UIColor.clear
        onCallTimer()
        timerAni = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.onCallTimer), userInfo: nil, repeats: true)
        
        timerCancelTrip = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.onGoBack), userInfo: nil, repeats: false)
    }
    
    func setStaticMap()
    {
        let mapmainUrl = "https://maps.googleapis.com/maps/api/staticmap?"
        let startlatlong = String(format:"%@ , %@",strPickUpLatitude,strPickUpLongitude)
        let mapUrl  = mapmainUrl + startlatlong
        let key = "&key=" +  iApp.GoogleKeys.map.key
        let size = "&size=" +  "\(Int(350))" + "x" +  "\(Int(350))"
        let pickupImgUrl = String(format:"%@public/images/man_marker.png|",iApp.baseURL.rawValue)
        let positionOnMap = "&markers=size:mid|icon:" + pickupImgUrl + startlatlong
        let staticImageUrl = mapUrl + size + "&zoom=14" + positionOnMap + key
        
        if let urlStr = staticImageUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)! as NSString?{
            print(urlStr)
            mapView?.sd_setImage(with: NSURL(string: urlStr as String)! as URL, placeholderImage:UIImage(named:""))
        }
    }
    
    @objc func onGoBack()
    {
        lblAcceptOrCancel.text = NSLocalizedString("Cancelling Request...", comment: "")
        callRequestAcceptAPI(status: NSLocalizedString("Cancelled", comment: ""))
        btnAccept.isUserInteractionEnabled = false
        timerAni.invalidate()
        timerCancelTrip.invalidate()
        rippleEffect.stopRippleAnimation()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "handle_timer"), object: self, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    internal func progressViewHandler(_ progressViewHandler: BIZProgressViewHandler!, didFinishProgressFor progressView: BIZCircularProgressView!) {
        timerAni.invalidate()
        rippleEffect.stopRippleAnimation()
        btnAccept.layer.borderWidth = 0.0
    }
    
    @objc func onCallTimer()
    {
        playSound("ub__reminder")
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

    func clearAllAnimations()
    {
        self.player?.stop()
        timerAni.invalidate()
        timerCancelTrip.invalidate()
        viewAccepting.isHidden = false
        self.view.addSubview(viewAccepting)
        viewAccepting.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: 60, y: (viewAccepting.frame.size.height - 40) / 2, width: 40, height: 40)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor(red: 0.0 / 255.0, green: 150.0 / 255.0, blue: 130.0 / 255.0, alpha: 1.0).cgColor
        spinnerView.beginRefreshing()
        viewCircular.removeFromSuperview()
        rippleEffect.stopRippleAnimation()
    }
    
    @IBAction func onAcceptTapped()
    {
        callRequestAcceptAPI(status: "Trip")  // accepting rider trip
    }
    
    
    //MARK: ACCEPT RIDER TRIP REQUEST
    func callRequestAcceptAPI(status: String)
    {
        if YSSupport.checkDeviceType()
        {
            if !(UIApplication.shared.isRegisteredForRemoteNotifications)
            {
                let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Message!!!", comment: ""), message: NSLocalizedString("Please enable Push Notification in settings for Request.", comment: ""),preferredStyle:UIAlertController.Style.alert)
                settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
                    self.appDelegate.registerForRemoteNotification()
                }))
                present(settingsActionSheet, animated:true, completion:nil)
                return
            }
        }
        
        clearAllAnimations()
        self.btnAccept.isUserInteractionEnabled = false
        var dicts = [String: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["status"] = status
        dicts["request_id"] = strRequestID
        
        UberAPICalls().PostRequest(dicts,methodName: METHOD_CHANGE_DRIVER_STATUS as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let gModel = response as! RiderDetailModel
            OperationQueue.main.addOperation
                {
                    if gModel.status_code == "1"
                    {
                        self.riderProfileModel = gModel
                        let cash = self.riderProfileModel.payment_method
                        self.gotoToRouteView()
                        Constants().STOREVALUE(value: status, keyname: USER_ONLINE_STATUS)
                        Constants().STOREVALUE(value: "Trip", keyname: TRIP_STATUS)
                        Constants().STOREVALUE(value:  cash, keyname: CASH_PAYMENT)

                    }
                    else if gModel.status_code == "0"{
                        
                        print(gModel.status_message)
                        let messages = gModel.status_message
                        print(messages)
                        if(messages == NSLocalizedString("Already Accepted", comment: "")) {
                        let msg = NSLocalizedString("Already accepted by someone", comment: "")
                            
                        self.appDelegate.createToastMessage(msg, bgColor: UIColor.black, textColor: UIColor.white)
                        Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
                            let userDefaults = UserDefaults.standard
                            userDefaults.set("driver", forKey:"getmainpage")
                            self.appDelegate.onSetRootViewController(viewCtrl: self)                        }
                        else{
                            Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
                        }

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
            OperationQueue.main.addOperation {
               
                self.btnAccept.isUserInteractionEnabled = (status == "Cancelled") ? false : true
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    
    }
    
    // MARK: - NAVIGATE TO ROUTE VIEW AFTER ACCETPTING REQUEST
    func gotoToRouteView()
    {
        FIRObserver.instance.initialize(FireBaseNode.rider, forID: riderProfileModel.rider_id)
        FIRObserver.instance.update(FireBaseNode.rider, with: riderProfileModel)
        FIRObserver.instance.stopObservingRider(FireBaseNode.rider)
        Constants().STOREVALUE(value: "Trip", keyname: TRIP_STATUS)
        let tripView = self.storyboard?.instantiateViewController(withIdentifier: "RouteVC") as! RouteVC
        tripView.strTripID = riderProfileModel.trip_id
        tripView.riderProfileModel = riderProfileModel
        tripView.strPickupLocation = strPickupLocation
        tripView.isFromReqVC = true
        self.navigationController?.pushViewController(tripView, animated: true)
    }
    
    func animateBorderWidth(view: UIButton, from: CGFloat, to: CGFloat, duration: Double) {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        view.layer.add(animation, forKey: "Width")
        view.layer.borderWidth = to
    }
    
    //MARK: INTERNET OFFLINE DELEGATE METHOD
    /*
     Here Calling the API again
     */
    internal func RetryTapped()
    {
    }
    
}
