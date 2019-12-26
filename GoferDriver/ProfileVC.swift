/**
* ProfileVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation
import MapKit

class ProfileVC : UIViewController,UITableViewDelegate, UITableViewDataSource, EditProfileDelegate,currencyListDelegate,APIViewProtocol,BankDetailsProtocolo
{
    func getBankDetails() {
        self.getUserProfileInfo()
    }
    
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
    @IBOutlet var tblProfile: UITableView!
    @IBOutlet var imgUserThumb: UIImageView!
    @IBOutlet var imgCarThumb: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblVehicleNo: UILabel!
    @IBOutlet var lblVehicleName: UILabel!
    @IBOutlet var viewTopHeader: UIView!
    @IBOutlet var lblOnlineStatus: UILabel!
    @IBOutlet var btnEditIcon: UIButton!
    
    @IBOutlet weak var viewButtonOutlet: UIButton!
    @IBOutlet var viewTblHeader: UIView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet var btnCheckStatus: UIButton!
    var checkAvailabilityBtn = UIButton()
    

    var profileModel : ProfileModel!
    var strCurrency : String = ""
    var customenum = ""

    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var arrMenus =  [TitleArray]()
    var arrIcons: [String] = ["P", "s", "S"]
    var status = ""
    
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        
        
        status = Constants().GETVALUE(keyname: TRIP_STATUS)
        switchButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
       
//        arrMenus = [NSLocalizedString("Documents", comment: ""),NSLocalizedString("Payout", comment: "")]
        let Currency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        let Currency1 = Constants().GETVALUE(keyname: USER_CURRENCY_ORG)
        if (Currency != "") && (Currency1 != " ")
        {
            strCurrency = "\(Currency) \(Currency1)"
            tblProfile.reloadData()
        }
        btnEditIcon.isHidden = true
        viewTblHeader.isHidden = true
        var rectTblView = tblProfile.frame
        rectTblView.size.height = self.view.frame.size.height-120
        tblProfile.frame = rectTblView
        imgUserThumb.layer.cornerRadius = imgUserThumb.frame.size.width / 2
        imgUserThumb.clipsToBounds = true
        imgCarThumb.layer.cornerRadius = imgUserThumb.frame.size.width / 2
        imgCarThumb.clipsToBounds = true
        self.checkAvailabilityBtn.addAction(for: .tap) {
            self.apiInteractor?.getResponse(for: .checkDriverStatus).shouldLoad(true)
        }
        
        self.checkAvailabilityBtn.setTitle("Check Status".localize, for: .normal)
//        CF2E11
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
        getUserProfileInfo()
        status = Constants().GETVALUE(keyname: TRIP_STATUS)
        

        self.updateCurrentLocationToServer(status: status)
        if status ==  "Online"{
            switchButton.setOn(true, animated: false)
            lblOnlineStatus.text = "Online".localize
        }else if status == "Trip"{
            switchButton.setOn(true, animated: false)
            lblOnlineStatus.text = "Online".localize
        }
        else {
            switchButton.setOn(false, animated: false)
            lblOnlineStatus.text = "Offline".localize
        }
        let Currency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        let Currency1 = Constants().GETVALUE(keyname: USER_CURRENCY_ORG)
        if (Currency != nil && Currency != "") && (Currency1 != nil && Currency1 != "")
        {
            strCurrency = "\(Currency) \(Currency1)"
            tblProfile.reloadData()
        }
        self.updateDriverStatus()
//        UberSupport().changeStatusBarStyle(style: .lightContent)

    }
    
    internal func onCurrencyChanged(currency: String)
    {
        let str = currency.components(separatedBy: " | ")
        strCurrency = String(format:"%@ %@", str[0],str[1])
//        let indexPath = IndexPath(row: 1, section: 0)
//        tblProfile.reloadRows(at: [indexPath], with: .none)
        tblProfile.reloadData()
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
        dicts["longitude"] = Constants().GETVALUE(keyname: USER_LONGITUDE)
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
    
    //MARK: - API CALL -> GETTING LOGGEDIN USER DETAILS
    func getUserProfileInfo()
    {
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        var dicts = [AnyHashable: Any]()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        UberAPICalls().GetRequest(dicts,methodName: METHOD_VIEW_PROFILE_INFO as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let proModel = response as! ProfileModel
            OperationQueue.main.addOperation
                {
                    if proModel.status_code == "1"
                    {
                        self.btnEditIcon.isHidden = false
                        Constants().STOREVALUE(value: proModel.car_id, keyname: USER_CAR_ID)
                        self.setprofileInfo(proModel: proModel)
                    }
                    else
                    {
                        if proModel.status_message == "user_not_found" || proModel.status_message == "token_invalid" || proModel.status_message == "Invalid credentials" || proModel.status_message == "Authentication Failed"
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
    
    // SETTING USER PROFILE INFO AFTER API SUCCESS
    func setprofileInfo(proModel: ProfileModel)
    {
        self.arrMenus.removeAll()
        self.arrIcons.removeAll()
        self.profileModel = proModel
        let document = TitleArray.document
        let payout = TitleArray.payout
        let bank = TitleArray.bank
        arrMenus.append(document)
        arrIcons.append("s")
//            .append("Documents".localize)
//        arrMenus.append("Payout".localize)
//        arrMenus = [NSLocalizedString("Documents", comment: ""),NSLocalizedString("Payout", comment: "")]
        if ![0,1].contains(self.profileModel.company_id) {//Company Driver
           arrMenus.append(bank)
            arrIcons.append("S")
        }else{//Normanl driver
            arrMenus.append(payout)
            arrIcons.append("P" )
        }
        imgUserThumb.image = UIImage(named: "")
        imgUserThumb?.sd_setImage(with: NSURL(string: profileModel.user_thumb_image)! as URL, placeholderImage:UIImage(named:""))
        lblUserName.text = profileModel.user_name
        if profileModel.vehicle_no != "" && profileModel.vehicle_name != "" {
            lblVehicleNo.text = profileModel.vehicle_no
            lblVehicleName.text = profileModel.vehicle_name
            lblVehicleNo.isHidden = false
            viewButtonOutlet.isHidden = false
            viewButtonOutlet.isUserInteractionEnabled = true
            lblVehicleName.transform = .identity
        }else {
            lblVehicleNo.isHidden = true
            viewButtonOutlet.isHidden = true
            viewButtonOutlet.isUserInteractionEnabled = false
            lblVehicleName.text = "No vehicle assigned".localize
            lblVehicleName.transform = CGAffineTransform(translationX: 0, y: -self.viewTblHeader.center.y/2)
        }
        
        viewTblHeader.isHidden = false
        self.imgCarThumb.sd_setImage(with: URL(string: proModel.car_active_image))
        self.tblProfile.reloadData()
    }
    
    //MARK: - WHEN USER PRESS EDIT BUTTON
    @IBAction func onProfileEditTapped()
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        propertyView.delegate = self
        if profileModel != nil
        {
            propertyView.profileModel = profileModel
        }
        self.navigationController?.pushViewController(propertyView, animated: true)
    }

    //MARK: - WHEN USER PRESS CHANGE CAR TAPPED
    @IBAction func onChangeCarTapped()
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "ChangeCarVC") as! ChangeCarVC
        propertyView.strVehicleName = profileModel.vehicle_name
        propertyView.strVehicleNo = profileModel.vehicle_no
        propertyView.strCarType = profileModel.car_type
        propertyView.profile = profileModel
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // MARK: - UITableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let viewHolder:UIView = UIView()
        viewHolder.frame =  CGRect(x: 0, y:0, width: (self.view.frame.size.width) ,height: 22)
        viewHolder.backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        return viewHolder
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 1{
            return 85
        }
        else{
            return 60
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (section == 0) ? arrMenus.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

            let cell:CellEarnItems = tblProfile.dequeueReusableCell(withIdentifier: "CellEarnItems") as! CellEarnItems
            cell.lblTitle.text = indexPath.section == 0 ? arrMenus[indexPath.row].instance : NSLocalizedString("Currency", comment: "")
            
            if indexPath.section == 0
            {
                cell.lblTitle.text = arrMenus[indexPath.row].instance
                cell.lblTitle.font = UIFont (name: iApp.GoferFont.bold.font, size: 16)
                cell.lblIcon.text = arrIcons[indexPath.row]
                cell.selectedCurrency.isHidden = true
            }
            else
            {
                cell.selectedCurrency.isHidden = false
                cell.lblTitle.text = NSLocalizedString("Currency", comment: "")
                cell.selectedCurrency.text = strCurrency
                cell.lblTitle.font = UIFont (name: iApp.GoferFont.medium.font, size: 17)
                cell.selectedCurrency.font = UIFont (name: iApp.GoferFont.medium.font, size: 17)
            }
            
            if appDelegate.language == "en" || appDelegate.language == "es" {
                var rectTblView = cell.lblTitle.frame
                rectTblView.origin.x = (indexPath.section == 0) ? 50 : 20
                cell.lblTitle.frame = rectTblView
            }
            cell.lblAccessory.isHidden = (indexPath.section == 0) ? false : true
            cell.lblIcon.isHidden = (indexPath.section == 0) ? false : true
            return cell

        
    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0
        {
            let cell:CellEarnItems = tableView.cellForRow(at: indexPath) as! CellEarnItems
            if indexPath.row == 0
            {
                let docView = self.storyboard?.instantiateViewController(withIdentifier: "DocumentMainVC") as! DocumentMainVC
                if profileModel != nil
                {
                    docView.strlicense_back = profileModel.license_back
                    docView.strlicense_front = profileModel.license_front
                    docView.strinsurance = profileModel.insurance
                    docView.strrc = profileModel.rc
                    docView.strpermit = profileModel.permit
                }
                docView.isFromProfile = true
                self.navigationController?.pushViewController(docView, animated: true)
            }
            else if indexPath.row == 1
            {
                if ![0,1].contains(self.profileModel.company_id){//company
                    let vc = PayoutBankDetailViewController.initWithStory()
                    vc.bankDetails = profileModel.bankDetails
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{//normal
                    let vc = ListPayoutsVC.initWithStory()
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                /*
                let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "AddPaymentVC") as! AddPaymentVC
                self.navigationController?.pushViewController(propertyView, animated: true)*/
            }
        }
        else if indexPath.section == 1
        {
            let locView = self.storyboard?.instantiateViewController(withIdentifier: "CurrencyVC") as! CurrencyVC
            locView.delegate = self
            locView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(locView, animated: true)
        }
        else{
            if let phoneCallURL:NSURL = NSURL(string:"tel://\(customenum)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL as URL)) {
                    application.openURL(phoneCallURL as URL);
                }
            }
        }
    }
    
    @IBAction func signoutAction(_ sender: Any) {
        self.callLogoutAPI()
       
    }
    
    // MARK: LOGOUT API CALL
    /*
     */
    func callLogoutAPI()
    {
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        var dicts = [AnyHashable: Any]()
       dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        UberAPICalls().GetRequest(dicts,methodName: METHOD_LOGOUT as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let gModel = response as! GeneralModel
            OperationQueue.main.addOperation {
                if gModel.status_code == "1"
                {
                    let userDefaults = UserDefaults.standard
                    userDefaults.set("", forKey:"getmainpage")
                    userDefaults.synchronize()
                    self.appDelegate.logOutDidFinish()
                }
                else if gModel.status_code == "2"
                {
                    let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Message!!!", comment: ""), message:gModel.status_message, preferredStyle:UIAlertController.Style.alert)
                    settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
                    }))
                    UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
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
                UberSupport().removeProgressInWindow(viewCtrl: self)
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }
}
class CellContactTVC : UITableViewCell {
    
    @IBOutlet var cotnum: UILabel!
}
enum TitleArray:String {
    case document
    case payout
    case bank
    var instance:String {
        switch self {
        case .document:
            return "Documents".localize
        case .payout:
            return "Payout".localize
        case .bank:
            return "Bank Details".localize
        }
    }
}
