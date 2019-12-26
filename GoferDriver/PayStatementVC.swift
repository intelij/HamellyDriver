/**
* PayStatementVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation
import MapKit

class PayStatementVC : UIViewController,UITableViewDelegate, UITableViewDataSource
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var tblPayStatement: UITableView!

    let arrMenus: [String] = ["Trip History", "Pay Statements"]
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    var arrPayStatementData : NSMutableArray = NSMutableArray()
    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func getPayStatement()
    {
        UberSupport().showProgress(viewCtrl: self, showAnimation: true)
        var dicts = [AnyHashable: Any]()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        
        UberAPICalls().GetRequest(dicts,methodName: METHOD_PAY_STATEMENT as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let genData = response as! GeneralModel
            OperationQueue.main.addOperation
                {
                    if genData.status_code == "1"
                    {
                        self.arrPayStatementData.addObjects(from: (genData.arrTemp3 as NSArray) as! [Any])
                    }
                    else
                    {
                        if genData.status_message == "user_not_found" || genData.status_message == "token_invalid" || genData.status_message == "Invalid credentials" || genData.status_message == "Authentication Failed"
                        {
                            self.appDelegate.logOutDidFinish()
                            return
                        }
                        else{
                        
                        }
                    }
                    
                    UberSupport().removeProgress(viewCtrl: self)
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                UberSupport().removeProgress(viewCtrl: self)
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })

    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .lightContent)
        self.navigationController?.isNavigationBarHidden = true
    }

    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: UITableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPayStatementData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellEarnItems = tblPayStatement.dequeueReusableCell(withIdentifier: "CellEarnItems") as! CellEarnItems
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let payModel = arrPayStatementData[indexPath.row] as! PayStatementModel
        cell.lblTitle.text = payModel.pay_date
        cell.lblSubTitle.text = String(format:"%@ %@", strCurrency, payModel.pay_amount)
        return cell
    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let tripView = self.storyboard?.instantiateViewController(withIdentifier: "WeeklyEarningVC") as! WeeklyEarningVC
        let payModel = arrPayStatementData[indexPath.row] as! PayStatementModel
        tripView.strTripID = payModel.trip_id
        self.navigationController?.pushViewController(tripView, animated: true)
    }
}
