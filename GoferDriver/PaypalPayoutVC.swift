//
//  PaypalPayoutVC.swift
//  GoferDriver
//
//  Created by bowshul sheik rahaman on 28/01/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import UIKit
import Alamofire

class PaypalPayoutVC: UIViewController {
    //MARK: Outlets
    
    @IBOutlet weak var paypalTableView: UITableView!
    
    @IBOutlet weak var navigationView : UIView!
    @IBOutlet var pickerHolderView: UIView!
    @IBOutlet weak var payPalEmailIDTF: UITextField!
    
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var titleLable : UILabel!
    
    @IBOutlet var paypalMailView: UIView!
    @IBOutlet weak var countryPickerView: UIPickerView!
    let content_titles = ["Address".localize, "Address2".localize, "City".localize, "State".localize, "Postal Code".localize,"Country".localize]
    var paypalParams = Parameters()
    var selectedCoutry = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.setSemantic(true){//if arabic change back button text
            self.backBtn.setTitle("I", for: .normal)
        }else{
            self.backBtn.setTitle("e", for: .normal)
        }
        self.initView()
//        self.listen2Keyboard(withView: self.paypalTableView)
        // Do any additional setup after loading the view.
    }
    
    //MARK: initializers
    func initView(){
        self.paypalTableView.delegate = self
        self.paypalTableView.dataSource = self
        
        self.titleLable.text = "Payouts".localize
        self.payPalEmailIDTF.delegate = self
        self.payPalEmailIDTF.placeholder = "Paypal "+"Email ID".localize
       
       // self.paypalTableView.tableFooterView = footer_btn
        self.pickerHolderView.frame = CGRect(x: 0, y: self.view.frame.height - 200, width: self.view.frame.width, height: 200)
        self.pickerHolderView.isHidden = true
        self.paypalMailView.frame = CGRect(x: 0,
                                           y: self.navigationView.frame.height,
                                           width: self.view.frame.width,
                                           height: self.view.frame.height - self.navigationView.frame.height)
        self.view.addSubview(self.paypalMailView)
        self.view.bringSubviewToFront(self.paypalMailView)
        self.paypalMailView.isHidden = true
       
    }
   
    class func initWithStory()->PaypalPayoutVC{
        return Stories.payment.instance.instantiateViewController(withIdentifier: "PaypalPayoutVC") as! PaypalPayoutVC
    }
    //MARK:Actions
    @IBAction func backAction(_ sender: Any?) {
        _ = self.setSemantic(false)
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func pickAction(_ sender: Any) {
        
    }
    @IBAction func submitStage1Data(_ sender : UIButton){
        var params = Parameters()
        var i = 0
        for key in self.content_titles{
            if let  cell = self.paypalTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? PaypalPayoutCell,
                let text = cell.textField.text,
                (/*key == "Address2".localize ||*/ !text.isEmpty){
                params[key] = cell.textField.text
            }else{
                appDelegate.createToastMessage("Please Enter the".localize+" "+key,
                                               bgColor: .black,
                                               textColor: .white)
                return
            }
            
            i = i + 1
        }
        self.paypalParams = params
        self.paypalMailView.isHidden = false
    }
    @IBAction func submitPhase2(_ sender: Any) {
        self.view.endEditing(true)
        guard let email = self.payPalEmailIDTF.text, !email.isEmpty,isValidMail(mail: email) else{
            appDelegate.createToastMessage("Please enter valid mail id".localize, bgColor: .black, textColor: .white)
            return
        }
        self.view.endEditing(true)
        var params = Parameters()
        params["address1"] = self.paypalParams["Address".localize]
        params["address2"] = self.paypalParams["Address2".localize]
        params["city"] = self.paypalParams["City".localize]
        params["state"] = self.paypalParams["State".localize]
        params["postal_code"] = self.paypalParams["Postal Code".localize]
        params["country"] = self.selectedCoutry
        params["email"] = email
        params["payout_method"] = "paypal"
        params["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        let uberSupport = UberSupport()
        uberSupport.showProgressInWindow(showAnimation: true)
        PaymentInteractor.instance.addPayout(withDetails: params) { (val) in
            
            uberSupport.removeProgressInWindow()
            if val{
                self.backAction(nil)
            }
        }
        
    }
}
extension PaypalPayoutVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.content_titles.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 70
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_btn = UIButton()
        footer_btn.frame = CGRect(x: 8,
                                  y: 15,
                                  width: self.paypalTableView.frame.width - 16,
                                  height: 40)
        footer_btn.backgroundColor = .ThemeMain
        footer_btn.setTitleColor(.white, for: .normal)
        footer_btn.setTitle("Submit".localize, for: .normal)
        footer_btn.isClippedCorner = true
        
        footer_btn.addTarget(self, action: #selector(self.submitStage1Data(_:)), for: .touchUpInside)
        let footerView = UIView()
        footerView.backgroundColor = .white
        footerView.addSubview(footer_btn)
        return footerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaypalPayoutCell") as! PaypalPayoutCell
        cell.setcell(WithTitle: self.content_titles[indexPath.row])
      
        cell.parentVC = self
            
        
        return cell
    }
    
    
}
extension PaypalPayoutVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.payPalEmailIDTF{
            self.view.endEditing(true)
        }
        return true
    }
}
 class PaypalPayoutCell : UITableViewCell,UITextFieldDelegate{
    @IBOutlet weak var title: UILabel!

    @IBOutlet weak var textField: UITextField!
    let countryPickerView = UIPickerView()
    internal var countries = [CountryList]()
    var parentVC : PaypalPayoutVC!
    var selectedRow = -1
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.textField.delegate = self
        self.countryPickerView.delegate = self
        self.countryPickerView.dataSource = self
        self.countryPickerView.backgroundColor = .clear
//        self.getCountries()
        
    }
    
    internal func getCountries(){
        PaymentInteractor.instance.getCountry { (countries) in
            self.countries = countries
            self.countryPickerView.reloadAllComponents()
        }
    }
    func setcell(WithTitle title: String){
        self.title.text = title
        self.setPicker(self.title.text == "Country".localize)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.title.text == "Postal Code".localize{
            self.parentVC.paypalTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.title.text == "Postal Code".localize{
            self.parentVC.paypalTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 130, right: 0)
        }
       return true
    }
    func setPicker(_ toSet : Bool){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .ThemeMain
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done".localize, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicking))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        if toSet{
            self.textField.inputView = self.countryPickerView
            self.textField.inputAccessoryView = toolBar
            self.countryPickerView.delegate = self
            self.countryPickerView.dataSource = self
            self.getCountries()
        }else{
            self.countryPickerView.delegate = nil
            self.countryPickerView.dataSource = nil
        }
    }
}
extension PaypalPayoutCell : UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1;
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        self.parentVC.paypalTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 230, right: 0)
        if self.countries.count == 0 || self.countries == nil {
           self.getCountries()
            return 0
        }
        else{
            return self.countries.count;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.countries[row].countryName
        //((arrCountryData[row] as AnyObject).value(forKey: "country_name") as? String ?? String())
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.selectedRow = row
        //        let currencyModel = ((arrCountryData[row] as AnyObject).value(forKey: "country_name") as? String ?? String())
        /*self.parentVC.paypalTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
       self.textField.text = self.countries[row].countryName
        self.parentVC.selectedCoutry = self.countries[row].countryCode
        self.textField.resignFirstResponder()
        */
        //((arrCountryData[row] as AnyObject).value(forKey: "country_code") as? String ?? String())
    }
    @objc func donePicking(){
        self.parentVC.paypalTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      
        var country : CountryList!
        if self.countries.indices ~= self.selectedRow{
            country = self.countries[self.selectedRow]
        }else{
            return
            //country = self.countries[0]
        }
        self.textField.text = country.countryName
        self.parentVC.selectedCoutry = country.countryCode
        self.textField.resignFirstResponder()
    }
}
