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

class DocumentMainVC: UIViewController,UITableViewDelegate,UITableViewDataSource,DocumentUploadDelegate
{
    @IBOutlet var tblDocument: UITableView!
    @IBOutlet var btnContinue: UIButton!
    @IBOutlet var viewHeader: UIView!
    @IBOutlet var viewContinueHolder: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblPageTitle: UILabel!
    @IBOutlet var btnBack: UIButton!

    var arrTitle = [String]()

    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
 
    let arrDocType = ["license_back","license_front","insurance","rc","permit"]
    var arrDocUrl = [String]()

    var isFromProfile : Bool = false
    
    var strCarName = ""
    var strCarId = ""
    var isHideBackBtn : Bool = false
    
    var strlicense_front = ""
    var strlicense_back = ""
    var strinsurance = ""
    var strrc = ""
    var strpermit = ""
    var imgCount = 0

    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if appDelegate.language == "ja" {
            lblPageTitle.text = "Please upload your documents".localize
            btnContinue.setTitle("VERIFY".localize, for: .normal)
        }
        arrTitle = [
            NSLocalizedString("Driver's License - (Back/Reverse)", comment: ""),NSLocalizedString("Driver's License - (Front)", comment: ""),NSLocalizedString("Motor Insurance Certificate", comment: ""),NSLocalizedString("Certificate of Registration", comment: ""),NSLocalizedString("Contract Carriage Permit", comment: "")]
       
        lblTitle.text = "\(NSLocalizedString("To drive with", comment: "")) \(iApp.appName) \(NSLocalizedString("your vehicle must be 2000 or newer, and be a mid-size or full-size sedan that comfortably seats 4-8 passengers.", comment: ""))"
        
        let userDefaults = UserDefaults.standard
        let userLicBack = userDefaults.value(forKey: LICENSE_BACK) as? String
        if (userLicBack !=  nil && userLicBack != "")
        {
            strlicense_back = userLicBack!
            imgCount += 1
        }
        let userLicFront = userDefaults.value(forKey: LICENSE_FRONT) as? String
        if (userLicFront != nil && userLicFront != "")
        {
            strlicense_front = userLicFront!
            imgCount += 1
        }
        
        let userInsurance = userDefaults.value(forKey: LICENSE_INSURANCE) as? String
        if (userInsurance != nil && userInsurance != "")
        {
            strinsurance = userInsurance!
            imgCount += 1
        }
        
        let userLicRC = userDefaults.value(forKey: LICENSE_RC) as? String
        if (userLicRC != nil && userLicRC != "")
        {
            imgCount += 1
            strrc = userLicRC!
        }
        
        let userLicPermit = userDefaults.value(forKey: LICENSE_PERMIT) as? String
        if (userLicPermit != nil && userLicPermit != "")
        {
            strpermit = userLicPermit!
            imgCount += 1
        }
        
        userDefaults.synchronize()
        
        arrDocUrl = [strlicense_back,strlicense_front,strinsurance,strrc,strpermit]
        if imgCount == 5
        {
            btnContinue.isUserInteractionEnabled = true
            btnContinue.backgroundColor = UIColor.ThemeMain
        }
        else
        {
            btnContinue.isUserInteractionEnabled = false
            btnContinue.backgroundColor = UIColor.ThemeInactive
        }
        
        btnBack.isHidden = isHideBackBtn ? true : false
//        UIApplication.shared.statusBarStyle = .default
        viewContinueHolder.isHidden = isFromProfile ? true : false
        if isFromProfile
        {
            viewHeader.isHidden = true
            lblPageTitle.text = NSLocalizedString("Document Section", comment: "")
            arrDocUrl = [strlicense_back,strlicense_front,strinsurance,strrc,strpermit]
        }
        else
        {
            tblDocument.tableHeaderView = viewHeader
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .default)
        self.navigationController?.isNavigationBarHidden = true
    }


    // MARK: User When Click on Update Phone No
    @IBAction func onContinueTapped(_ sender:UIButton!)
    {
        self.showPage()
    }
    
    func showPage()
    {
//        if Constants().GETVALUE(keyname: USER_PAYPAL_EMAIL_ID).count == 0
//        {
//            let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "AddPaymentVC") as! AddPaymentVC
//            propertyView.isFromHomePage = true
//            self.navigationController?.pushViewController(propertyView, animated: false)
//        }
//        else
//        {
            let userDefaults = UserDefaults.standard
            userDefaults.set("driver", forKey:"getmainpage")
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.onSetRootViewController(viewCtrl: self)
//        }

    }

    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: ---------------------------------------------------------------
    //MARK: ***** Edit Profile Table view Datasource Methods *****
    /*
     Edit Profile List View Table Datasource & Delegates
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellPayment = tblDocument.dequeueReusableCell(withIdentifier: "CellPayment")! as! CellPayment
        cell.lblTitle?.text = arrTitle[indexPath.row]
        return cell
    }
        
    //MARK: ---- Table View Delegate Methods ----
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "DocumentDetailVC") as! DocumentDetailVC
        propertyView.delegate = self
        propertyView.strTitle = arrTitle[indexPath.row]
        propertyView.nSelectedIndex = indexPath.row
        propertyView.isFromProfile = isFromProfile
        propertyView.strDocType = arrDocType[indexPath.row]
        propertyView.strDocUrl = arrDocUrl[indexPath.row]
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // MARK: - DOCUMENT DETAIL DELEGATE METHOD
    /*
     AFTER USER UPLOAD ALL DOCUMENT, ENABLE VERIFY BUTTON 
     */
    internal func enableVerifyButton(type:String,strDocUrls:String,count:String)
    {
        btnContinue.isUserInteractionEnabled = false
        btnContinue.backgroundColor = UIColor.ThemeInactive
        if count == "5"
        {
            btnContinue.isUserInteractionEnabled = true
            btnContinue.backgroundColor = UIColor.ThemeMain
        }

        if type == "license_back"
        {
            strlicense_back = strDocUrls
            Constants().STOREVALUE(value: strlicense_back, keyname: LICENSE_BACK)
        }
        else if type == "license_front"
        {
            strlicense_front = strDocUrls
            Constants().STOREVALUE(value: strlicense_front, keyname: LICENSE_FRONT)
        }
        else if type == "insurance"
        {
            strinsurance = strDocUrls
            Constants().STOREVALUE(value: strinsurance, keyname: LICENSE_INSURANCE)
        }
        else if type == "rc"
        {
            strrc = strDocUrls
            Constants().STOREVALUE(value: strrc, keyname: LICENSE_RC)
        }
        else if type == "permit"
        {
            strpermit = strDocUrls
            Constants().STOREVALUE(value: strpermit, keyname: LICENSE_PERMIT)
        }
        
        arrDocUrl = [strlicense_back,strlicense_front,strinsurance,strrc,strpermit]
    }
}
