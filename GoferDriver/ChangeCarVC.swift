/**
* ChangeCarVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation
import MapKit

class ChangeCarVC : UIViewController,UITableViewDelegate, UITableViewDataSource
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var tblChangeCar: UITableView!
    var strVehicleName = ""
    var strVehicleNo = ""
    var strCarType = ""
    var profile : ProfileModel?
    var titleLabel = UILabel()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var rectTblView = tblChangeCar.frame
        rectTblView.size.height = self.view.frame.size.height-70
        tblChangeCar.frame = rectTblView
        if let company_name = self.profile?.company_name{
            self.titleLabel.text = company_name
        }
        self.titleLabel.backgroundColor = .ThemeLight
        self.titleLabel.textColor = .white
        self.titleLabel.textAlignment = .center
        self.tblChangeCar.tableHeaderView = self.titleLabel
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
//        UberSupport().changeStatusBarStyle(style: .lightContent)
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
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return [0,1].contains(self.profile?.company_id) ? 0 : 35
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let viewHolder:UIView = UIView()
        viewHolder.frame =  CGRect(x: 0, y:0, width: (self.view.frame.size.width) ,height: 35)
        viewHolder.backgroundColor = UIColor(red: 239.0 / 255.0, green: 238.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        return titleLabel
        //return viewHolder
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellEarnItems = tblChangeCar.dequeueReusableCell(withIdentifier: "CellEarnItems") as! CellEarnItems
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.lblTitle.text = strVehicleName
        cell.lblSubTitle.text = strVehicleNo
        if let _profile = self.profile,
            let carURL = URL(string: _profile.car_active_image){
            let carImage = UIImageView()
            carImage.frame = cell.lblIcon.frame
            carImage.sd_setImage(with: carURL)
            cell.contentView.addSubview(carImage)
            cell.contentView.bringSubviewToFront(carImage)
            cell.lblIcon.isHidden = true
        }
        cell.carType.text = strCarType
        return cell
    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
}
