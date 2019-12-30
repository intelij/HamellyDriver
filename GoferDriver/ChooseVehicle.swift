/**
* DocumentMainVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/


import UIKit
import Foundation

class ChooseVehicle: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var tblVehicle: UITableView!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var btnVehicleType: UIButton!
    @IBOutlet var txtFldVehicleName: UITextField!
    @IBOutlet var txtFldVehicleNumber: UITextField!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var btnBack: UIButton!

    var strVehicleId = ""
    var strVehicleType = ""
    var carDetailModel = NSArray()
    var isHideBackBtn : Bool = false
    var isFromOtherPage : Bool = false
    var carId = NSArray()

    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            txtFldVehicleName.keyboardType = .asciiCapable
            txtFldVehicleNumber.keyboardType = .asciiCapable
        } else {
            // Fallback on earlier versions
            txtFldVehicleName.keyboardType = .asciiCapable
            txtFldVehicleNumber.keyboardType = .asciiCapable
        }
        if isFromOtherPage
        {
            let userDefaults = UserDefaults.standard
            let usercardetails = userDefaults.value(forKey: USER_CAR_TYPE) as? String ?? String()
            let usercarids = userDefaults.value(forKey: USER_CAR_IDS) as? String ?? String()
            carDetailModel = usercardetails.components(separatedBy: ",") as NSArray
            carId = usercarids.components(separatedBy: ",") as NSArray
        }
        btnBack.isHidden = isHideBackBtn ? true : false

//        UIApplication.shared.statusBarStyle = .default
        checkSaveButtonStatus()
        
        tblVehicle.isHidden = true
        
        txtFldVehicleName.setLeftPaddingPoints(10)
        txtFldVehicleName.setRightPaddingPoints(10)
        txtFldVehicleNumber.setLeftPaddingPoints(10)
        txtFldVehicleNumber.setRightPaddingPoints(10)

        tblVehicle.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        tblVehicle.layer.borderWidth = 1.0
        tblVehicle.layer.cornerRadius = 3.0
        
        tblVehicle.layer.shadowColor = UIColor.gray.cgColor;
        tblVehicle.layer.shadowOffset = CGSize(width:0, height:1.0);
        tblVehicle.layer.shadowOpacity = 0.5;
        tblVehicle.layer.shadowRadius = 3.0;


        viewHolder.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        viewHolder.layer.borderWidth = 1.0
        viewHolder.layer.cornerRadius = 3.0

        txtFldVehicleName.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtFldVehicleName.layer.borderWidth = 1.0
        txtFldVehicleName.layer.cornerRadius = 3.0

        txtFldVehicleNumber.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtFldVehicleNumber.layer.borderWidth = 1.0
        txtFldVehicleNumber.layer.cornerRadius = 3.0
        btnSave.layer.cornerRadius = 3.0
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .default)
        self.navigationController?.isNavigationBarHidden = true
    }

    // MARK: User When Click on Update Phone No
    @IBAction func onSaveTapped(_ sender:UIButton!)
    {
        tblVehicle.isHidden = true
        btnSave.isUserInteractionEnabled = false
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        self.view.endEditing(true)

        var dicts = [String: Any]()
        
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["vehicle_id"] = strVehicleId
        dicts["vehicle_name"] = txtFldVehicleName.text!
        dicts["vehicle_type"] = strVehicleType
        dicts["vehicle_number"] = txtFldVehicleNumber.text

        UberAPICalls().PostRequest(dicts,methodName: METHOD_UPDATE_VEHICLE_INFO as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let gModel = response as! GeneralModel
            OperationQueue.main.addOperation
                {
                    if gModel.status_code == "1"
                    {
                        self.gotoDocumentPage()
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
    
    // NAVIGATE TO DOCUMENT PAGE
    /*
     IF USER UPDATING HIS VEHICLE DETAILS
     */
    func gotoDocumentPage()
    {
        Constants().STOREVALUE(value: strVehicleId, keyname: USER_CAR_ID)
        Constants().STOREVALUE(value: "Document_details", keyname: USER_STATUS)
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "DocumentMainVC") as! DocumentMainVC
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // MARK: When User Press Back Button
    @IBAction func chooseVehicleTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        tblVehicle.isHidden = !tblVehicle.isHidden
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: ---------------------------------------------------------------
    //MARK: ***** UPdate vechicle Table view Datasource Methods *****
    /*
     Edit Profile List View Table Datasource & Delegates
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return carDetailModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellEarnItems = tblVehicle.dequeueReusableCell(withIdentifier: "CellEarnItems")! as! CellEarnItems
        if isFromOtherPage
        {
            cell.lblTitle?.text = carDetailModel[indexPath.row] as? String
        }
        else
        {
            let carModel = carDetailModel[indexPath.row] as! CarDetailModel
            cell.lblTitle?.text = carModel.car_name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if isFromOtherPage
        {
            strVehicleType = (carDetailModel[indexPath.row] as? String)!
            strVehicleId = (carId[indexPath.row] as? String)!
        }
        else
        {
            let carModel = carDetailModel[indexPath.row] as! CarDetailModel
            strVehicleId = carModel.car_id
            strVehicleType = carModel.car_name
        }
        btnVehicleType.setTitle(strVehicleType,for:.normal)
        btnVehicleType.titleLabel?.text = strVehicleType
        tblVehicle.isHidden = true
        checkSaveButtonStatus()
    }
    
    // MARK: - TextField Delegate Method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if range.location == 0 && (string == " ") {
            return false
        }
        if (string == "") {
            return true
        }
        else if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
    {
        if textField.tag == 0   // USER NAME
        {
        }
        else if textField.tag == 1   // EMAIL ID
        {
        }
        
        return true
    }
    
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        checkSaveButtonStatus()
    }
    
    func checkSaveButtonStatus()
    {
        if (txtFldVehicleName.text?.count)! > 0 && (txtFldVehicleNumber.text?.count)! > 4 && btnVehicleType.titleLabel?.text != "Choose Vehicle Type".localize
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
