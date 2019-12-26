/**
* CountryListVC.swift
*
* @package UberDiver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import AVFoundation

protocol CountryListDelegate
{
    func countryCodeChanged(countryCode:String, dialCode:String, flagImg:UIImage)
}


class CountryListVC : UIViewController, UITableViewDelegate, UITableViewDataSource,  UITextFieldDelegate
{
    @IBOutlet var tblCountryList : UITableView!
    @IBOutlet var txtFldSearch:UITextField!
    @IBOutlet var viewPickerHolder:UIView!

    @IBOutlet weak var selectCountryLabel: UILabel!
    var delegate: CountryListDelegate?
    var arrCountryList : NSMutableArray = NSMutableArray()
    var arrFilterList : NSMutableArray = NSMutableArray()
    
    
    var strPreviousCountry = ""

    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if appDelegate.language != "es" && appDelegate.language != "fa" && appDelegate.language != "ar" {
            selectCountryLabel.text = "Select a Country".localize
            txtFldSearch.placeholder = "Search".localize
        }
        let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
        arrCountryList = NSMutableArray(contentsOfFile: path!)!
    }
    // MARK: - ViewController Methods
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .lightContent)
        self.navigationController?.isNavigationBarHidden = true
    }
    // MARK: - ViewController Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: ***** Edit Profile Table view Datasource Methods *****
    /*
        Edit Profile List View Table Datasource & Delegates
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (txtFldSearch?.text?.count)! > 0
        {
            return arrFilterList.count
        }
        else
        {
            return arrCountryList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellCountry = tblCountryList.dequeueReusableCell(withIdentifier: "CellCountry")! as! CellCountry
        cell.lblTitle?.text = ((txtFldSearch?.text?.count)! > 0) ? ((arrFilterList[indexPath.row] as AnyObject).value(forKey: "name") as? String ?? String()) : ((arrCountryList[indexPath.row] as AnyObject).value(forKey: "name") as? String ?? String())

        if ((txtFldSearch?.text?.count)! > 0)
        {
            cell.imgFlag.image = UIImage.imageFlagBundleNamed(named: ((arrFilterList[indexPath.row] as AnyObject).value(forKey: "code") as? String ?? String()).lowercased() + ".png") as UIImage
        }
        else
        {
            cell.imgFlag.image = UIImage.imageFlagBundleNamed(named: ((arrCountryList[indexPath.row] as AnyObject).value(forKey: "code") as? String ?? String()).lowercased() + ".png") as UIImage
        }
        
        cell.contentView.backgroundColor = UIColor.white
        return cell
    }
    
    //MARK: ---- Table View Delegate Methods ----
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if ((txtFldSearch?.text?.count)! > 0)
        {
            let dialCode = ((arrFilterList[indexPath.row] as AnyObject).value(forKey: "dial_code") as? String ?? String())
            let countryCode = ((arrFilterList[indexPath.row] as AnyObject).value(forKey: "code") as? String ?? String())
            let flagImg = UIImage.imageFlagBundleNamed(named: ((arrFilterList[indexPath.row] as AnyObject).value(forKey: "code") as? String ?? String()).lowercased() + ".png") as UIImage
            delegate?.countryCodeChanged(countryCode:countryCode, dialCode:dialCode, flagImg:flagImg)
        }
        else
        {
            let dialCode = ((arrCountryList[indexPath.row] as AnyObject).value(forKey: "dial_code") as? String ?? String())
            let countryCode = ((arrCountryList[indexPath.row] as AnyObject).value(forKey: "code") as? String ?? String())
            let flagImg = UIImage.imageFlagBundleNamed(named: ((arrCountryList[indexPath.row] as AnyObject).value(forKey: "code") as? String ?? String()).lowercased() + ".png") as UIImage
            delegate?.countryCodeChanged(countryCode:countryCode, dialCode:dialCode, flagImg:flagImg)
        }
        self.view.endEditing(true)
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    // MARK: TextField Delegate Method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
    {
        return true
    }
    
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        updatedCountryResults(NormalListArr: arrCountryList, strKey: "name",strSearchText:(textField.text)!)
    }
    
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
    
    
    //MARK:- Search Update
    func updatedCountryResults(NormalListArr: NSMutableArray, strKey: NSString, strSearchText:String) {
        
        var filteredListarr: NSMutableArray?
        filteredListarr = nil
        
        filteredListarr = NSMutableArray.init(array: NormalListArr)
        
        let predicate: NSPredicate?
        
        if strKey.length > 0 {
            predicate = NSPredicate(format: "%K BEGINSWITH[cd]%@", strKey, "\(strSearchText)")
        }
        else {
            predicate = NSPredicate(format: "self BEGINSWITH[cd] %@", "\(strSearchText)")
        }
        
        filteredListarr?.filter(using: predicate!)
        
        if strSearchText.count == 0 {
            self.tblCountryList.reloadData()
        }
        else{
            updateTableView(filteredarr: filteredListarr!)
        }
    }
    
    func updateTableView(filteredarr: NSMutableArray) {
            self.arrFilterList = filteredarr
            self.tblCountryList.reloadData()
    }
    // MARK: When User Press Back Button

    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController!.popViewController(animated: true)
        }
    }

}

class CellCountry : UITableViewCell
{
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgFlag: UIImageView!
}

extension UIImage{
    class func imageFlagBundleNamed(named:String)->UIImage{
        let image = UIImage(named: "assets.bundle".appendingFormat("/"+(named as String)))!
        return image
    }
}
