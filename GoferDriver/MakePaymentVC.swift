/**
* MakePaymentVC.swift
*
* @package UberClone
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import AVFoundation
import Alamofire

class MakePaymentVC : UIViewController, UITableViewDelegate, UITableViewDataSource,APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum) {
        switch response {
        case .RiderModel(let rider):
            let thumbImg = rider.rider_thumb_image
            self.strTripID = rider.getTripID
            self.gotoRateYourRatingPage(withRiderImage: thumbImg)
        default:
            print()
        }
    }
    
    func onFailure(error: String) {
        print(error)
    }
    
    @IBOutlet var tblPaymentDetails:UITableView!
    @IBOutlet var btnBack : UIButton!
    @IBOutlet var viewFooter : UIView!
    @IBOutlet var btnPayment : UIButton!

    var isFromRatingPage : Bool = false
    var arrInfoKey : NSMutableArray = NSMutableArray()
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var strTripID = ""
    var strPaymentStatus = ""
    var totalAmt = ""
    var payment_method = ""
    var payAmount = ""
    var tripModel : EndTripModel!
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    var isPaidShown : Bool = false
    var isFromTripPage : Bool = false
    var arrTripsDate : NSMutableArray = NSMutableArray()

    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UberSupport().removeProgressInWindow()
        self.apiInteractor = APIInteractor(self)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.checkPaymentStatus()
        }
        /*
        if (payment_method == "Cash & Wallet" || payment_method == "Cash") && (totalAmt == "0" || totalAmt == "0.00") {
            btnPayment.setTitle(NSLocalizedString("WAITING FOR RIDER CONFIRMATION", comment: ""), for: UIControlState.normal)
            self.btnPayment.backgroundColor = UIColor.lightGray
            btnPayment.isUserInteractionEnabled = false
        }
        else if payment_method == "Cash & Wallet" || payment_method == "Cash"{
                btnPayment.setTitle(NSLocalizedString("CASH COLLECTED", comment: ""), for: UIControlState.normal)
                btnPayment.titleLabel?.text = NSLocalizedString("CASH COLLECTED", comment: "")
                btnPayment.isUserInteractionEnabled = true
        }
        else if (payment_method == "PayPal" || payment_method == "PayPal & Wallet") && (totalAmt == "0" || totalAmt == "0.00") {
            btnPayment.setTitle(NSLocalizedString("WAITING FOR RIDER CONFIRMATION", comment: ""), for: UIControlState.normal)
            self.btnPayment.backgroundColor = UIColor.lightGray
            btnPayment.isUserInteractionEnabled = false
        }
        else{
            btnPayment.setTitle(NSLocalizedString("WAITING FOR PAYMENT", comment: ""), for: UIControlState.normal)
            self.btnPayment.backgroundColor = UIColor.lightGray
            btnPayment.titleLabel?.text = NSLocalizedString("WAITING FOR PAYMENT", comment: "")
            btnPayment.isUserInteractionEnabled = false
        }*/
//        UIApplication.shared.statusBarStyle = .lightContent
        btnBack.isHidden = isFromRatingPage ? true : false
        tblPaymentDetails.tableFooterView = viewFooter
        NotificationCenter.default.addObserver(self, selector: #selector(self.getPaymentSuccess), name: NSNotification.Name(rawValue: "PaymentSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoHomePage), name: NSNotification.Name(rawValue: "PaymentSuccessInHomeAlert"), object: nil)
        _ = PipeAdapter.createEvent(withName: "PaymentSuccess", dataAction: { (data) in
            if let json = data as? JSON{
                self.onPaymentSucces(json)
            }
        })
    }

    //MARK: Payment  btn status
    func checkPaymentStatus()
    {
        btnPayment.isUserInteractionEnabled = true
        switch self.payment_method{
        case let x where x.lowercased().contains("cash")://Cash
            if totalAmt.isEmpty || Double(totalAmt) == 0.0{
                self.setBtnState(to: .waitingForConfirmation)
            }else{
                self.setBtnState(to: .cashCollected)
            }
        case let x where x.lowercased().first == "p"://Pay Pal
            if totalAmt.isEmpty || Double(totalAmt) == 0.0{
                self.setBtnState(to: .waitingForConfirmation)
            }else{
                self.setBtnState(to: .waitingForConfirmation)
            }
        case let x where x.lowercased().first == "s"://Pay Pal
            if totalAmt.isEmpty || Double(totalAmt) == 0.0{
                self.setBtnState(to: .waitingForConfirmation)
            }else{
                self.setBtnState(to: .waitingForConfirmation)
            }
        default:
            self.setBtnState(to: .paid)
            self.strPaymentStatus = "PAID"
        }
        
    }
    func setBtnState(to state : BtnPymtStatus){
        switch state {
        case .cashCollected:
            btnPayment.setTitle(NSLocalizedString("CASH COLLECTED", comment: ""), for: UIControl.State.normal)
            btnPayment.backgroundColor = .ThemeMain
            btnPayment.isUserInteractionEnabled = true
        case .waitingForConfirmation:
            btnPayment.setTitle(NSLocalizedString("WAITING FOR PAYMENT", comment: ""), for: UIControl.State.normal)
            btnPayment.backgroundColor = .ThemeInactive
            btnPayment.isUserInteractionEnabled = false
        case .proceed:
            btnPayment.setTitle(NSLocalizedString("PROCEED", comment: ""), for: UIControl.State.normal)
            btnPayment.backgroundColor = .ThemeMain
            btnPayment.isUserInteractionEnabled = true
        default:
            btnPayment.setTitle(NSLocalizedString("PAID", comment: ""), for: UIControl.State.normal)
            btnPayment.backgroundColor = .ThemeMain
            btnPayment.isUserInteractionEnabled = true
        }
    }
  // goto payment success page
    @objc func getPaymentSuccess(_ notification : Notification)
    {
        if isPaidShown
        {
            return
        }
        //self.apiInteractor?.getResponse(for: .)
        btnPayment.setTitle(NSLocalizedString("PAID", comment: ""),for: .normal)
        btnPayment.backgroundColor = UIColor.green
        btnPayment.isUserInteractionEnabled = false
        Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
        Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
        let rider_thumb_image = notification.userInfo?["rider_thumb_image"] as? String ?? String()
        self.gotoRateYourRatingPage(withRiderImage: rider_thumb_image)
        //appDelegate.onSetRootViewController(viewCtrl: self)
    }
    func onPaymentSucces(_ json : JSON){
        Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
        Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
        let riderImage = json.string("rider_thumb_image")
        let tripId = json.string("trip_id")
        self.strTripID = tripId
        let settingsActionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Rider successfully paid", comment: ""), preferredStyle: .alert)
        
        settingsActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:  .cancel, handler:{ action in
            self.gotoRateYourRatingPage(withRiderImage: riderImage)
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
    }
    
    // after completed the payment to go home page
    @IBAction func gotoHomePage()
    {
        if strPaymentStatus == "PAID"
        {
            Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
            Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
            appDelegate.onSetRootViewController(viewCtrl: self)
        }
        else if btnPayment.titleLabel?.text == NSLocalizedString("CASH COLLECTED", comment: "")
        {
            print("cash payment")
            self.cashPayment()
        }
    }
 // if rider paid a cash payment driver update the server to the api
    func cashPayment(){
        var parameters = Parameters()
        parameters["trip_id"] = self.strTripID
        self.apiInteractor?.getResponse(forAPI: .cashCollected, params: parameters).shouldLoad(true)
        /*  self.apiInteractor?.getResponse(forAPI: .cashCollected,params: parameters,responseValue: { (response) in
                            switch(response){
                            case .RiderModel(let rider):
                                let thumbImg = rider.rider_thumb_image
                                self.strTripID = rider.getTripID
                                self.gotoRateYourRatingPage(withRiderImage: thumbImg)
                            default:
                                print()
                            }
        }).shouldLoad(true)
      
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        var dicts = [AnyHashable: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["trip_id"] = strTripID
        UberAPICalls().PostRequest(dicts,methodName:METHOD_CASH_COLLECT as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let genModel = response as! GeneralModel
            
            OperationQueue.main.addOperation {
                if genModel.status_code == "1"
                {
                    Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
                    Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
                    let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Payment Completed successfully", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
                    settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:UIAlertActionStyle.cancel, handler:{ action in
                        self.appDelegate.onSetRootViewController(viewCtrl: self)
                    }))
                    UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
                }
                else
                {
                    if genModel.status_message == "user_not_found" || genModel.status_message == "token_invalid" || genModel.status_message == "Invalid credentials" || genModel.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                    }
                    else{
                        Constants().STOREVALUE(value: "Offline", keyname: USER_ONLINE_STATUS)
                        Constants().STOREVALUE(value: "Offline", keyname: TRIP_STATUS)
                    }
                }
               UberSupport().removeProgressInWindow(viewCtrl: self)
              
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                UberSupport().removeProgressInWindow(viewCtrl: self)
               
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })*/
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .lightContent)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func gotoRateYourRatingPage(withRiderImage imgURL : String)
    {
      let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "RateYourRideVC") as! RateYourRideVC
         propertyView.strRiderImgUrl = imgURL
         propertyView.strTripID = self.strTripID
         propertyView.isFromRoutePage = true
         self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    //MARK: - ***** Edit Profile Table view Datasource Methods *****
    /*
     Edit Profile List View Table Datasource & Delegates
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrInfoKey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellTripsInfo = tblPaymentDetails.dequeueReusableCell(withIdentifier: "CellTripsInfo")! as! CellTripsInfo
        let listModel = arrInfoKey[indexPath.row] as? InvoiceModel
        cell.lblTitle?.text = listModel?.invoiceKey
        cell.lblCostInfo.text = listModel?.invoiceValue
      
        cell.setBar(listModel?.bar == 1)
        if let colorStr = listModel?.color,
            !colorStr.isEmpty{
            let color = colorStr == "black" ? UIColor(hex: "000000") : UIColor(hex: "27aa0b")
            cell.lblCostInfo.font = UIFont(name: iApp.GoferFont.bold.font, size: CGFloat(17))
            cell.lblTitle?.font = UIFont(name: iApp.GoferFont.bold.font, size: CGFloat(17))
            cell.lblCostInfo.textColor = color
            cell.lblTitle?.textColor = color
        }else{
            cell.lblCostInfo.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
            cell.lblTitle?.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
            let color = UIColor(hex: "000000") 
            cell.lblCostInfo.textColor = color
            cell.lblTitle?.textColor = color
        }/*
        if cell.lblTitle?.text == NSLocalizedString("Cash collected", comment: "")
        {
            cell.lblCostInfo.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
            cell.lblTitle?.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
            cell.lblCostInfo.textColor = UIColor(red: 0/255, green: 188/255, blue: 34/255, alpha: 1.0)
            cell.lblTitle?.textColor = UIColor(red: 0/255, green: 188/255, blue: 34/255, alpha: 1.0)
            if cell.lblCostInfo.text!.range(of:"0.00") != nil {
                print("exists")
                cell.lblCostInfo.isHidden = true
                cell.lblTitle?.isHidden = true
            }
        }
        else if cell.lblTitle?.text == NSLocalizedString("Total trip Fare", comment: "")  || cell.lblTitle?.text == NSLocalizedString("Wallet Amount", comment: "")
        {
            cell.lblCostInfo.font = UIFont(name: iApp.GoferFont.bold.font, size: CGFloat(17))
            cell.lblTitle?.font = UIFont(name: iApp.GoferFont.bold.font, size: CGFloat(17))
        }
        else{
            cell.lblCostInfo.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
            cell.lblTitle?.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
        }*/
        return cell
    }
    
    //MARK: ---- Table View Delegate Methods ----
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    // User when press back button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        if isFromTripPage
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            let sts  = (strPaymentStatus == "PAID") ? "Online" : "Trip"
            Constants().STOREVALUE(value: sts, keyname: TRIP_STATUS)
            appDelegate.onSetRootViewController(viewCtrl: self)
        }
    }    
   
}
