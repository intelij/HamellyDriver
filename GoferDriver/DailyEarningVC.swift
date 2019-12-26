/**
* DailyEarningVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import AVFoundation



class DailyEarningVC : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var imgMapRoot : UIImageView!
    @IBOutlet var imgUserThumb : UIImageView!
    @IBOutlet var tblDailyEarning : UITableView!
    @IBOutlet var lblPickUpLoc : UILabel!
    @IBOutlet var lblDropLoc : UILabel!
    @IBOutlet var lblTripTime: UILabel!
    @IBOutlet var lblCost: UILabel!
    @IBOutlet var lblCarType: UILabel!
    @IBOutlet var lblTripStatus: UILabel!
    @IBOutlet var lblDriverName: UILabel!

    @IBOutlet var viewTapper:UIView!
    @IBOutlet var btnHelp : UIButton!
    @IBOutlet var btnReceipt : UIButton!
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()

//        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .lightContent)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    //MARK: ---------------------------------------------------------------
    //MARK: ***** Weekly Earning Table view Datasource Methods *****
    /*
     Weekly Earning Table Datasource & Delegates
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  80
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellTripsInfo = tblDailyEarning.dequeueReusableCell(withIdentifier: "CellTripsInfo")! as! CellTripsInfo
        return cell
    }
    
    //MARK: ---- Table View Delegate Methods ----
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "NewTripsDetailsVC") as! NewTripsDetailsVC

    }
    
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: INTERNET OFFLINE DELEGATE METHOD
    /*
     Here Calling the API again
     */
    internal func RetryTapped()
    {
    }
    
    
}

