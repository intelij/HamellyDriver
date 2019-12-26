//
//  NewTripsDetailsVC.swift
//  TruckitDriver
//
//  Created by Trioangle on 04/10/18.
//  Copyright © 2018 Vignesh Palanivel. All rights reserved.
//

import UIKit

class NewTripsDetailsVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tripsTableView: UITableView!

    var riderModel : RiderDetailModel!
    var strOriginalDate = ""
    var totalAmt = ""
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    var tripsDict = [[String:Any]]()
    var arrInfoKey : NSMutableArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func backButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
// MARK: TABLE VIEW DELEGATE AND DATA SOURCE ADDED
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 3
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:	 Int) -> Int {
        if section == 1 {
            return riderModel!.invoices.isEmpty ? 0 : riderModel!.invoices.count
        }
        else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let createat = riderModel.created_at
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = createat.components(separatedBy: " ")
        let datestr = dateFormatter.date(from:strDate[0])
        dateFormatter.dateFormat = "EEEE, dd-MM-yyyy"
        let strOriginalDate = dateFormatter.string(from: datestr!)
//        print(strOriginalDate)
        if indexPath.section == 0{
            let cell = tripsTableView.dequeueReusableCell(withIdentifier: "CellTimeDateTVC") as! CellTimeDateTVC
            var price = riderModel.driver_payout
            cell.priceLabel.text = String(format:"%@ %@", strCurrency,price)
            if Constants.userDefaults.bool(forKey: IS_COMPANY_DRIVER) {
               price = riderModel.sub_total_fare
                cell.priceLabel.text = String(format:"%@",price)
            }
            
            cell.timeDateLable.text = strOriginalDate
            
            
            
            return cell

        }
        else if indexPath.section == 1{
            let cell = tripsTableView.dequeueReusableCell(withIdentifier: "CellSpecialAmountTVC") as! CellSpecialAmountTVC
            
            cell.basefareIcon.isHidden = indexPath.row == 0 ? false : true
            let tripModel = riderModel.invoices[indexPath.row]
            
            cell.titleLabel.text = tripModel.invoiceKey
            cell.setBar(tripModel.bar == 1)
            let price = tripModel.invoiceValue
            if price.isEmpty,
                price.contains("x") || price.contains("X"){
                cell.amountLabel.text = price
            }else{
                cell.amountLabel.text =  tripModel.invoiceValue
            }
            cell.titleLabel.textColor = UIColor.ThemeMain
            cell.amountLabel?.textColor = UIColor.ThemeMain
            if tripModel.color == "green"
            {
                cell.titleLabel.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
                cell.amountLabel?.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
                 cell.titleLabel.textColor = UIColor(red: 0/255, green: 188/255, blue: 34/255, alpha: 1.0)
                cell.amountLabel?.textColor = UIColor(red: 0/255, green: 188/255, blue: 34/255, alpha: 1.0)
                cell.titleLabel.textColor = UIColor(hex: "27aa0b")
                cell.amountLabel?.textColor = UIColor(hex: "27aa0b")
            }
            if tripModel.color == "black"
            {
                cell.titleLabel.font = UIFont(name: iApp.GoferFont.bold.font, size: CGFloat(17))
                cell.amountLabel?.font = UIFont(name: iApp.GoferFont.bold.font, size: CGFloat(17))
            }
            else{
                cell.titleLabel.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
                cell.amountLabel?.font = UIFont(name: iApp.GoferFont.medium.font, size: CGFloat(15))
            }
            return cell
        }
        else {
            let cell = tripsTableView.dequeueReusableCell(withIdentifier: "CellMapTVC") as! CellMapTVC
            cell.pickUpAddLabel.text = riderModel.pickup_location
            cell.dropAddLabel.text = riderModel.drop_location
            cell.distanceLabel.text = riderModel.total_km + " " + "KM".localize
            cell.durationLabel.text = riderModel.total_time + " " + "MINS".localize
            if !riderModel.map_image.isEmpty{
                cell.mapImageView.sd_setImage(with: URL(string: riderModel.map_image), placeholderImage:UIImage(named:""))
            }
            else {
                 cell.mapImageView.sd_setImage(with: riderModel.getGooglStaticMap, placeholderImage:UIImage(named:""))
               /* let startlatlong = "\(riderModel.pickup_latitude),\(riderModel.pickup_longitude)"
               
                let droplatlong = "\(riderModel.drop_latitude),\(riderModel.drop_longitude)"
              
                let tripPath = riderModel.trip_path
                let mapmainUrl = "https://maps.googleapis.com/maps/api/staticmap?"
                let mapUrl  = mapmainUrl + startlatlong
                let size = "&size=" +  "\(Int(640))" + "x" +  "\(Int(350))"
                let enc = "&path=color:0x000000ff|weight:4|enc:" + tripPath
                let key = "&key=" +  iApp.GoogleKeys.map.key
                let pickupImgUrl = String(format:"%@public/images/pickup_icon|",iApp.baseURL.rawValue)
                let dropImgUrl = String(format:"%@public/images/dropoff_icon|",iApp.baseURL.rawValue)
                let positionOnMap = "&markers=size:mid|icon:" + pickupImgUrl + startlatlong
                let positionOnMap1 = "&markers=size:mid|icon:"  + dropImgUrl + droplatlong
                let staticImageUrl = mapUrl + positionOnMap + size + "&zoom=14" + positionOnMap1 + enc + key
                if let urlStr = staticImageUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)! as NSString?{
                    cell.mapImageView.sd_setImage(with: NSURL(string: (urlStr) as String)! as URL, placeholderImage:UIImage(named:""))
                }*/
                
            }
            return cell
                
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        }
        else if indexPath.section == 1{
           return 50
        }
        else {
            return 400
        }
    }
        
}
class CellSpecialAmountTVC : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var basefareIcon: UILabel!
    
    let bar = UIView()
    override func awakeFromNib() {
        super.awakeFromNib()
        bar.frame = CGRect(x: 0, y: 1, width: self.contentView.frame.width, height: 1)
        bar.backgroundColor = .lightGray
        bar.alpha = 0.5
        self.contentView.addSubview(bar)
    }
    func setBar(_ val : Bool){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.bar.frame = CGRect(x: 0, y: 1, width: self.contentView.frame.width, height: 1)
            self.bar.isHidden = !val
        }
    }
}

class CellMapTVC : UITableViewCell {
    
    @IBOutlet weak var pickUpAddLabel: UILabel!
    @IBOutlet weak var dropAddLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
}
class CellTimeDateTVC : UITableViewCell {
    
    @IBOutlet weak var timeDateLable: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}
