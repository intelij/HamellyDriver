/**
* CancelRideVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/


import UIKit
import Foundation

class CancelRideVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var tblCancelList: UITableView!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var btnCanceReason: UIButton!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var txtViewCancel: UITextView!
    @IBOutlet var lblPlaceHolder: UILabel!

    var strCancelReason = ""
    var arrCancelReason = [String]()
    var strTripId = ""
    var isFromTripDetail : Bool = false
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        txtViewCancel.keyboardType = .asciiCapable
        arrCancelReason =  [
            NSLocalizedString("Rider No show", comment: ""),NSLocalizedString("Rider requested cancel", comment: ""),NSLocalizedString("Wrong address shown", comment: ""),NSLocalizedString("Involved in an accident", comment: ""),NSLocalizedString("Do not charge Rider", comment: "")]

//        UIApplication.shared.statusBarStyle = .default
        checkSaveButtonStatus()
        tblCancelList.isHidden = true
        var lblFrame = lblPlaceHolder.frame
        lblFrame.origin.y = txtViewCancel.frame.origin.y+8
        lblFrame.origin.x = txtViewCancel.frame.origin.x+5
        lblPlaceHolder.frame = lblFrame

        tblCancelList.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        tblCancelList.layer.borderWidth = 1.0
        tblCancelList.layer.cornerRadius = 3.0

        viewHolder.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        viewHolder.layer.borderWidth = 1.0
        viewHolder.layer.cornerRadius = 3.0

        txtViewCancel.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtViewCancel.layer.borderWidth = 1.0
        txtViewCancel.layer.cornerRadius = 3.0
        btnSave.layer.cornerRadius = 3.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.driverCancelledTrip), name: NSNotification.Name(rawValue: "cancel_trip_driver"), object: nil)
    }
   
    /*
     CANCEL TRIP DONE NAVIGATE TO HOME PAGE
     */
    @objc func driverCancelledTrip(notification: Notification)
    {
        Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
        Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
//        if let nav = self.navigationController{
//            nav.popToRootViewController(animated: true)
//        }else{
            self.appDelegate.onSetRootViewController(viewCtrl: self)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
//        UberSupport().changeStatusBarStyle(style: .default)
    }

    // MARK: - API CALL -> CANCEL TRIP
    /*
     CANCEL TRIP DONE NAVIGATE TO HOME PAGE
     */
    @IBAction func onCancelTripTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        btnSave.isUserInteractionEnabled = false
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        
        var dicts = [String: Any]()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["trip_id"] = strTripId
        dicts["cancel_comments"] = txtViewCancel.text!
        dicts["cancel_reason"] = strCancelReason
        
        UberAPICalls().PostRequest(dicts,methodName: METHOD_CANCEL_TRIP as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let gModel = response as! GeneralModel
            OperationQueue.main.addOperation
            {
                if gModel.status_code == "1"
                {
                    Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancel_trip_by_driver"), object: self, userInfo: nil)
                    let info: [String: Any] = [
                        "cancelled_by" : "YES",
                        ]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowHomePage"), object: self, userInfo: info)
                }
                else
                {
                    if gModel.status_message == "user_not_found" || gModel.status_message == "token_invalid" || gModel.status_message == "Invalid credentials" || gModel.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                    }
                    else{
                        self.appDelegate.createToastMessage(gModel.status_message, bgColor: UIColor.black, textColor: UIColor.white)
                    }
                }
                UberSupport().removeProgressInWindow(viewCtrl: self)
                self.btnSave.isUserInteractionEnabled = true
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                UberSupport().removeProgressInWindow(viewCtrl: self)
                self.btnSave.isUserInteractionEnabled = true
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }
    
    // MARK: When User Press Back Button
    @IBAction func chooseCancelDropDown(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        tblCancelList.isHidden = !tblCancelList.isHidden
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TEXTVIEW DELEGATE METHOD
    func textViewDidChange(_ textView: UITextView)
    {
        lblPlaceHolder.isHidden = (txtViewCancel.text.count > 0) ? true : false
        checkSaveButtonStatus()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if range.location == 0 && (text == " ") {
            return false
        }
        if (text == "") {
            return true
        }
        else if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    //MARK: TEXTVIEW DELEGATE END
    
    //MARK: - ***** UPdate vechicle Table view Datasource Methods *****
    /*
     CANCEL REASON List View Table Datasource & Delegates
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrCancelReason.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellEarnItems = tblCancelList.dequeueReusableCell(withIdentifier: "CellEarnItems")! as! CellEarnItems
        cell.lblTitle?.text = arrCancelReason[indexPath.row]
        cell.lblAccessory?.layer.borderColor = UIColor.black.cgColor
        cell.lblAccessory?.layer.borderWidth = 1.0
        cell.lblAccessory?.text = (strCancelReason == cell.lblTitle.text) ? "3" : ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        strCancelReason = arrCancelReason[indexPath.row]
        btnCanceReason.setTitle(strCancelReason,for:.normal)
        btnCanceReason.titleLabel?.text = strCancelReason
        tblCancelList.isHidden = true
        tblCancelList.reloadData()
        checkSaveButtonStatus()
    }
    
    func checkSaveButtonStatus()
    {
        if btnCanceReason.titleLabel?.text != "Cancel reason"
        {
            btnSave.isUserInteractionEnabled = true
            btnSave.backgroundColor = UIColor.ThemeMain
        }
        else
        {
            btnSave.backgroundColor = UIColor.ThemeInactive
            btnSave.isUserInteractionEnabled = false
        }
    }

}
