//
//  CurrencyVC.swift
//  Gofer
//
//  Created by Trioangle on 16/05/18.
//  Copyright © 2018 Vignesh Palanivel. All rights reserved.
//

import UIKit
import Social

protocol currencyListDelegate
{
    func onCurrencyChanged(currency:String)
}

class CurrencyVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblCurrency: UITableView!
    @IBOutlet var btnSave: UIButton!
    
    var delegate: currencyListDelegate?
    var strCurrentCurrency = ""
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var arrCurrencyData : NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userCurrencySym = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        let userCurrencyCode = Constants().GETVALUE(keyname: USER_CURRENCY_ORG)
        strCurrentCurrency = String(format: "%@ | %@",userCurrencyCode,userCurrencySym)
        self.navigationController?.isNavigationBarHidden = true
        self.callCurrencyAPI()
        btnSave.layer.cornerRadius = 5.0
    }
    
    //MARK: INTERNET OFFLINE DELEGATE METHOD
    /*
     Here Calling the API again
     */
    internal func RetryTapped()
    {
        callCurrencyAPI()
    }
    
    // MARK: CURRENCY API CALL
    /*
     */
    func callCurrencyAPI()
    {
        var dicts = [AnyHashable: Any]()
        UberSupport().showProgress(viewCtrl: self, showAnimation: true)
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        UberAPICalls().GetRequest(dicts,methodName: METHOD_CURRENCY_LIST as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            
            let currencyModel = response as! GeneralModel
            
            OperationQueue.main.addOperation {
                if currencyModel.status_code == "1"
                {
                    self.arrCurrencyData.addObjects(from: (currencyModel.arrTemp1 as NSArray) as! [Any])
                    //                    self.makeScroll()
                    self.tblCurrency.reloadData()
                    
                }
                else
                {
                    if currencyModel.status_message == "user_not_found" || currencyModel.status_message == "token_invalid" || currencyModel.status_message == "Invalid credentials" || currencyModel.status_message == "Authentication Failed"
                    {
                        let userDefaults = UserDefaults.standard
                        userDefaults.set("", forKey:"getmainpage")
                        userDefaults.synchronize()
                        self.appDelegate.onSetRootViewController(viewCtrl:self)
                    }
                    else
                    {
                        self.appDelegate.createToastMessage(currencyModel.status_message, bgColor: UIColor.black, textColor: UIColor.white)
                    }
                }
                UberSupport().removeProgressInWindow(viewCtrl: self)
                
            }
            
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                if !YSSupport.isNetworkRechable()
                {
                    self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
                    UberSupport().removeProgressInWindow(viewCtrl: self)
                    
                }
            }
        })
        
    }
    func makeScroll()
    {
        for i in 0...arrCurrencyData.count-1
        {
            let currencyModel = arrCurrencyData[i] as? CurrencyModel
            let str = strCurrentCurrency.components(separatedBy: "  |  ")
            if currencyModel?.currency_code as String? == str[0]
            {
                let indexPath = IndexPath(row: i, section: 0)
                tblCurrency.scrollToRow(at: indexPath, at: .top, animated: true)
                break
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func showProgress()
    {
        let loginPageView = self.storyboard?.instantiateViewController(withIdentifier: "ProgressHud") as! ProgressHud
        loginPageView.willMove(toParent: self)
        loginPageView.view.tag = 1234
        self.view.addSubview(loginPageView.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        let userCurrencySym = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        let userCurrencyCode = Constants().GETVALUE(keyname: USER_CURRENCY_ORG)
        strCurrentCurrency = String(format: "%@ | %@",userCurrencyCode,userCurrencySym)
        
    }
    
    //
    //MARK: Room Detail Table view Handling
    /*
     Room Detail List View Table Datasource & Delegates
     */
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrCurrencyData.count != 0 ? arrCurrencyData.count : 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellCurrency = tblCurrency.dequeueReusableCell(withIdentifier: "CellCurrency") as! CellCurrency
        
        let currencyModel = arrCurrencyData[indexPath.row] as? CurrencyModel
        let strSymbol = self.makeCurrencySymbols(encodedString: (currencyModel?.currency_symbol as String?)!)
        let checkdata = String(format: "%@ | %@",(currencyModel?.currency_code as NSString?)!,strSymbol)
        cell.lblCurrency?.text = String(format: "%@ | %@",(currencyModel?.currency_code as NSString?)!,strSymbol)
        cell.imgTickMark?.isHidden = (strCurrentCurrency == checkdata) ? false : true
        cell.imgTickMark?.image = UIImage(named: "tick.png")
        //        self.makeScroll()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedCell = tblCurrency.cellForRow(at: indexPath) as! CellCurrency
        appDelegate.nSelectedIndex = indexPath.row
        strCurrentCurrency = (selectedCell.lblCurrency?.text)!
        let str = strCurrentCurrency.components(separatedBy: " | ")
        Constants().STOREVALUE(value: str[1] as? String ?? String(), keyname: USER_CURRENCY_SYMBOL_ORG)
        Constants().STOREVALUE(value: str[0] as? String ?? String(), keyname: USER_CURRENCY_ORG)
        tblCurrency.reloadData()
    }
    
    
    func makeCurrencySymbols(encodedString : String) -> String
    {
        let encodedData = encodedString.stringByDecodingHTMLEntities
        return encodedData
    }
    
    @IBAction func onSaveTapped(_ sender:UIButton!)
    {
        UberSupport().showProgress(viewCtrl: self, showAnimation: true)
        
        var dicts = [AnyHashable: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        let str = strCurrentCurrency.components(separatedBy: " | ")
        dicts["currency_code"] = str[0]
        UberAPICalls().GetRequest(dicts,methodName: METHOD_CHANGE_CURRENCY as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let gModel = response as! GeneralModel
            OperationQueue.main.addOperation {
                UberSupport().removeProgress(viewCtrl: self)
                if gModel.status_code == "1"
                {
                    self.delegate?.onCurrencyChanged(currency: self.strCurrentCurrency)
                    
                    self.navigationController?.popViewController(animated: true)
                }
                else
                {
                    if gModel.status_message == "user_not_found" || gModel.status_message == "token_invalid" || gModel.status_message == "Invalid credentials" || gModel.status_message == "Authentication Failed"
                    {
                        let userDefaults = UserDefaults.standard
                        userDefaults.set("", forKey:"getmainpage")
                        userDefaults.synchronize()
                        self.appDelegate.onSetRootViewController(viewCtrl:self)
                    }
                    else
                    {
                        self.appDelegate.createToastMessage(gModel.status_message, bgColor: UIColor.black, textColor: UIColor.white)
                    }
                }
                UberSupport().removeProgressInWindow(viewCtrl: self)
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                UberSupport().removeProgressInWindow(viewCtrl: self)
            }
        })
    }
    
    func updateOrgCurrency()
    {
        let currencyModel = arrCurrencyData[appDelegate.nSelectedIndex] as? CurrencyModel
    }
    
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onAddListTapped(){
        
    }
}

class CellCurrency: UITableViewCell
{
    @IBOutlet var lblCurrency: UILabel?
    @IBOutlet var imgTickMark: UIImageView?
}


