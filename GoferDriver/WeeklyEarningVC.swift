/**
* WeeklyEarningVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import AVFoundation



class WeeklyEarningVC : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var imgMapRoot : UIImageView!
    @IBOutlet var imgUserThumb : UIImageView!
    @IBOutlet var tblWeeklyInfo : UITableView!
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
    var strTripID = ""

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
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellTripsInfo = tblWeeklyInfo.dequeueReusableCell(withIdentifier: "CellTripsInfo")! as! CellTripsInfo
        return cell
    }
    
    //MARK: ---- Table View Delegate Methods ----
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let tripView = self.storyboard?.instantiateViewController(withIdentifier: "DailyEarningVC") as! DailyEarningVC
        self.navigationController?.pushViewController(tripView, animated: true)
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
class CellTripsInfo : UITableViewCell
{
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblArrow: UILabel!
    @IBOutlet var lblCostInfo: UILabel!
    let bar = UIView()
    override func awakeFromNib() {
        super.awakeFromNib()
        bar.frame = CGRect(x: 0, y: 1, width: self.contentView.frame.width, height: 1)
        bar.backgroundColor = .lightGray
        self.contentView.addSubview(bar)
    }
    func setBar(_ val : Bool){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.bar.frame = CGRect(x: 0, y: 1, width: self.contentView.frame.width, height: 1)
            self.bar.isHidden = !val
        }
    }
    
}

