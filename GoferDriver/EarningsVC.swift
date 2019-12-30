/**
* MainMapView.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation
import MapKit

class EarningsVC : UIViewController,UITableViewDelegate, UITableViewDataSource, ChartViewDelegate,APIViewProtocol
{
    //MARK:- APIHandlers
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum) {
        switch response {
        case .driverStatus(let dStatus):
            self.appDelegate.createToastMessage(dStatus.getString)
            self.updateDriverStatus(dStatus: dStatus)
        default:
            print()
        }
    }
    
    func onFailure(error: String) {
        print(error)
    }
    //MARK:-
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var viewChartHolder: UIView!
    @IBOutlet var tblEarnings: UITableView!
    @IBOutlet var lblWeekDate: UILabel!
    @IBOutlet var btnNextWeek: UIButton!
    @IBOutlet var btnPreviousWeek: UIButton!
    @IBOutlet var lblWeekCost: UILabel!
    @IBOutlet var viewTopHeader: UIView!
    @IBOutlet var viewRateHolder: UIView!
    @IBOutlet var lblCurrentRate: UILabel!
    @IBOutlet var lblOnlineStatus: UILabel!
    @IBOutlet var lblNoData: UILabel!
    @IBOutlet var lblTopAmount: UILabel!
    @IBOutlet var lblTopAmount1: UILabel!
    @IBOutlet var lblTopAmount2: UILabel!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var switchButton: UISwitch!

    @IBOutlet weak var totalPayoutTitleLabel: UILabel!
    var arrMenus = [String]()
    var weekDays = [String]()
    
    var strStartDate = ""
    var strEndDate = ""
    
    var strStartDateTemp = ""
    var strEndDateTemp = ""

    var dateStart : NSDate = NSDate()
    var dateEnd : NSDate = NSDate()
    var dateStartTemp : NSDate = NSDate()
    var dateEndTemp : NSDate = NSDate()
    var arrWeeklyCharyData : NSMutableArray = NSMutableArray()
    var dateFormatter = DateFormatter()
    var chartModel : EarningsModel!
    var strCurrency = ""
    var status = ""
    var checkAvailabilityBtn = UIButton()
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        status = Constants().GETVALUE(keyname: TRIP_STATUS)
        switchButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        if UserDefaults.standard.bool(forKey: IS_COMPANY_DRIVER){
            self.totalPayoutTitleLabel.text = "TOTAL TRIPS AMOUNT".localize
        }else {
            self.totalPayoutTitleLabel.text = "TOTAL PAYOUT".localize
        }
        self.checkAvailabilityBtn.setTitle("Check Status".localize, for: .normal)
        arrMenus = [NSLocalizedString("Trips & Payments", comment:"")]
        weekDays = [NSLocalizedString("Sunday", comment:""),NSLocalizedString("Monday", comment: ""),NSLocalizedString("Tuesday", comment: ""),NSLocalizedString("Wednesday", comment: ""),NSLocalizedString("Thursday", comment: ""),NSLocalizedString("Friday", comment: ""),NSLocalizedString("Saturday", comment: "")]
        strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        var rectTblView = tblEarnings.frame
        rectTblView.size.height = self.view.frame.size.height-120
        tblEarnings.frame = rectTblView
        lblNoData.isHidden = true
        view1.isHidden = false
        view2.isHidden = false
        viewRateHolder.isHidden = true
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "yyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US")
        let todayDate = Date()
        let getWeekDayName = self.getDayOfWeek(today: dateFormatter.string(from: todayDate as Date))
        if appDelegate.language == "en" {
            if getWeekDayName == NSLocalizedString("Monday", comment: "")
            {
                dateStart = get(.Next, "Monday",considerToday: true)
                let endDate = Calendar.current.date(byAdding: .day, value: 6, to: dateStart as Date)
                dateEnd = endDate! as NSDate
            }
            else
            {
                let startDate = Calendar.current.date(byAdding: .day, value: getMonday(setWeekDayName:getWeekDayName), to: todayDate as Date)
                dateStart = startDate! as NSDate
                let endDate = Calendar.current.date(byAdding: .day, value: getEndDate(setWeekDayName:getWeekDayName), to: todayDate as Date)
                dateEnd = endDate! as NSDate
            }
        }
        else{
            if getWeekDayName == NSLocalizedString("Sunday", comment: "")
            {
                dateStart = get(.Next, "Sunday",considerToday: true)
                let endDate = Calendar.current.date(byAdding: .day, value: 6, to: dateStart as Date)
                dateEnd = endDate! as NSDate
            }
            else
            {
                let startDate = Calendar.current.date(byAdding: .day, value: getMonday(setWeekDayName:getWeekDayName), to: todayDate as Date)
                let startDateString = dateFormatter.string(from: startDate!)
                dateFormatter.locale = Locale(identifier: "en_US")

                dateStart = dateFormatter.date(from: startDateString)! as NSDate
                // dateStart = startDate! as Date as NSDate

                let endDate = Calendar.current.date(byAdding: .day, value: getEndDate(setWeekDayName:getWeekDayName), to: todayDate as Date)
                let endDateString = dateFormatter.string(from: endDate!)
                dateFormatter.locale = Locale(identifier: "en_US")
                dateEnd = dateFormatter.date(from: endDateString) as! NSDate
               // dateEnd = endDate! as Date as NSDate
            }

        }
        dateStartTemp = dateStart
        dateEndTemp = dateEnd
        strStartDate = dateFormatter.string(from: dateStart as Date)
        strEndDate = dateFormatter.string(from: dateEnd as Date)
        strStartDateTemp = strStartDate
        strEndDateTemp = strEndDate
        dateFormatter.dateFormat = "dd MMM yyy"
        lblWeekDate.text = String(format: "%@ - %@", dateFormatter.string(from: dateStartTemp as Date),dateFormatter.string(from: dateEndTemp as Date))

        if strStartDateTemp == strStartDate
        {
            btnNextWeek.isHidden = true
            lblWeekDate.text = NSLocalizedString("THIS WEEK", comment: "")
        }
        else
        {
            btnNextWeek.isHidden = false
        }
        self.checkAvailabilityBtn.addAction(for: .tap) {
            self.apiInteractor?.getResponse(for: .checkDriverStatus).shouldLoad(true)
        }
    }

    @IBAction func switchButtonAction(_ sender: Any) {
        
        if switchButton.isOn == true {
            print("On")
            Constants().STOREVALUE(value: "Online", keyname: USER_ONLINE_STATUS)
            Constants().STOREVALUE(value: "Online", keyname: TRIP_STATUS)
            lblOnlineStatus.text = NSLocalizedString("Online", comment: "")
            self.updateCurrentLocationToServer(status: "Online")
        }
        else {
            print("Off")
            Constants().STOREVALUE(value: "Offline", keyname: USER_ONLINE_STATUS)
            Constants().STOREVALUE(value: "Offline", keyname: TRIP_STATUS)
            lblOnlineStatus.text = NSLocalizedString("Offline", comment: "")
            self.updateCurrentLocationToServer(status: "Offline")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.updateDriverStatus()
        status = Constants().GETVALUE(keyname: TRIP_STATUS)
        self.updateCurrentLocationToServer(status: status)
        if status ==  "Online"{
            lblOnlineStatus.text = "Online".localize
            switchButton.setOn(true, animated: false)
        }else if status == "Trip"{
            lblOnlineStatus.text = "Online".localize
            switchButton.setOn(true, animated: false)
        }else {
            lblOnlineStatus.text = "Offline".localize
            switchButton.setOn(false, animated: false)
        }
        strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        self.getThisWeekEarnings(startDate: strStartDate, endDate: strEndDate)
//        UberSupport().changeStatusBarStyle(style: .lightContent)
    }
    //check driver status
    
    func updateDriverStatus(dStatus : DriverStatus = .getStatusFromPreference())
    {
        let screenWidth = self.view.frame.width
        let buttonWidth : CGFloat  = 145
        let buttonHeight : CGFloat = 30
        self.checkAvailabilityBtn.frame = CGRect(x: screenWidth - buttonWidth - 5 ,
                                                 y: self.lblOnlineStatus.frame.midY + 5,
                                                 width: buttonWidth,
                                                 height: buttonHeight);
        self.checkAvailabilityBtn.titleLabel?.font = UIFont(name: iApp.GoferFont.bold.font,
                                                            size: 15)
        self.checkAvailabilityBtn.backgroundColor = UIColor.init(hex: "#CF2E11")
        self.checkAvailabilityBtn.setTitleColor(.white, for: .normal)
        self.checkAvailabilityBtn.setTitle("Check Status".localize, for: .normal)
      
        let status = Constants().GETVALUE(keyname: USER_STATUS)
        if dStatus != .active
        {
            self.view.addSubview(self.checkAvailabilityBtn)
            self.view.bringSubviewToFront(self.checkAvailabilityBtn)
            self.lblOnlineStatus.isHidden = true
            switchButton.isHidden = true
        }
        else
        {
            self.checkAvailabilityBtn.removeFromSuperview()
            self.lblOnlineStatus.isHidden = false
            switchButton.isHidden = false
        }
    }
    
    //MARK: - API CALL -> UPDATE DRIVER CURRENT LOCATION TO SERVER 
    func updateCurrentLocationToServer(status: String)
    {
        var dicts = [String: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["latitude"] = Constants().GETVALUE(keyname: USER_LATITUDE)
        dicts["longitude"] = Constants().GETVALUE(keyname: USER_LONGITUDE)
        dicts["car_id"] = Constants().GETVALUE(keyname: USER_CAR_ID)
        dicts["status"] = status
        UberAPICalls().PostRequest(dicts,methodName:METHOD_UPDATING_DRIVER_LOCATION as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let endModel = response as! GeneralModel
            
            OperationQueue.main.addOperation {
                if endModel.status_code == "1"
                {
                }
                else
                {
                    if endModel.status_message.lowercased() == "please complete your current trip" && self.status != "Trip"
                    {
                        let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Message!!!", comment: ""), message:endModel.status_message, preferredStyle:UIAlertController.Style.alert)
                        settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
                        }))
                        UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
                    }
                    else if self.status != "Trip"
                    {
                        self.appDelegate.createToastMessage(endModel.status_message, bgColor: UIColor.black, textColor: UIColor.white)
                    }
                    if endModel.status_message == "user_not_found" || endModel.status_message == "token_invalid" || endModel.status_message == "Invalid credentials" || endModel.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                        
                    }
                    else{
                    }
                    
                }
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }

    //MARK: Getting Previous Monday on this week
    /*
     Weekly earnings calculated by Moday - Sunday
     */
    func getMonday(setWeekDayName:String) -> Int
    {
        if setWeekDayName == NSLocalizedString("Tuesday", comment: "")
        {
            return -1
        }
        else if setWeekDayName == NSLocalizedString("Wednesday", comment: "")
        {
            return -2
        }
        else if setWeekDayName == NSLocalizedString("Thursday", comment: "")
        {
            return -3
        }
        else if setWeekDayName == NSLocalizedString("Friday", comment: "")
        {
            return -4
        }
        else if setWeekDayName == NSLocalizedString("Saturday", comment: "")
        {
            return -5
        }
        else if setWeekDayName == NSLocalizedString("Sunday", comment: "")
        {
            return -6
        }
        return 0
    }
    
    func getEndDate(setWeekDayName:String) -> Int
    {
        if setWeekDayName == NSLocalizedString("Tuesday", comment: "")
        {
            return 5
        }
        else if setWeekDayName == NSLocalizedString("Wednesday", comment: "")
        {
            return 4
        }
        else if setWeekDayName == NSLocalizedString("Thursday", comment: "")
        {
            return 3
        }
        else if setWeekDayName == NSLocalizedString("Friday", comment: "")
        {
            return 2
        }
        else if setWeekDayName == NSLocalizedString("Saturday", comment: "")
        {
            return 1
        }
        else if setWeekDayName == NSLocalizedString("Sunday", comment: "")
        {
            return 0
        }
        return 0
    }
    //MARK: - NEXT PREVIOUS ACTION
    /*
     PASSING START DATE & END DATE
     START DATE -> MONDAY
     END DATE -> SUNDAY
     */
    @IBAction func gotoNextPreviousOfWeek(_ sender: UIButton!)
    {
        if sender.tag == 11  //  Previous week
        {
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: dateStartTemp as Date)
            dateStartTemp = startDate! as NSDate
            let endDate = Calendar.current.date(byAdding: .day, value: 6, to: dateStartTemp as Date)
            dateEndTemp = endDate! as NSDate

        }
        else   //  Next week
        {
            let startDate = Calendar.current.date(byAdding: .day, value: 7, to: dateStartTemp as Date)
            dateStartTemp = startDate! as NSDate
            let endDate = Calendar.current.date(byAdding: .day, value: 6, to: dateStartTemp as Date)
            dateEndTemp = endDate! as NSDate
        }
        
        dateFormatter.dateFormat = "yyy-MM-dd"

        strStartDateTemp = dateFormatter.string(from: dateStartTemp as Date)
        strEndDateTemp = dateFormatter.string(from: dateEndTemp as Date)
        
        dateFormatter.dateFormat = "dd MMM yyy"
        lblWeekDate.text = String(format: "%@ - %@", dateFormatter.string(from: dateStartTemp as Date),dateFormatter.string(from: dateEndTemp as Date))
        if strStartDateTemp == strStartDate
        {
            btnNextWeek.isHidden = true
            lblWeekDate.text = NSLocalizedString("THIS WEEK", comment: "")
        }
        else
        {
            btnNextWeek.isHidden = false
        }
        
        self.getThisWeekEarnings(startDate: strStartDateTemp, endDate: strEndDateTemp)
    }
    
    func getDayOfWeek(today:String)->String {
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd"
        let todayDate = formatter.date(from: today)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: todayDate)
        let weekDay = myComponents.weekday
        return weekDays[weekDay!-1]
    }
    
    //MARK: - API CALL -> GETTING WEEKLY EARNINGS
    func getThisWeekEarnings(startDate: String, endDate: String)
    {
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        var dicts = [String: Any]()
        
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["start_date"] = String(format:"%@",startDate)
        dicts["end_date"] = String(format:"%@",endDate)

        UberAPICalls().PostRequest(dicts,methodName: METHOD_WEEKLY_EARNINGS as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let earnModel = response as! EarningsModel
            OperationQueue.main.addOperation {
                self.arrWeeklyCharyData.removeAllObjects()
                if earnModel.status_code == "1" && earnModel.arrWeeklyData.count > 0
                {
                    self.chartModel = earnModel
                    self.arrWeeklyCharyData.addObjects(from: (earnModel.arrWeeklyData as NSArray) as! [Any])
                }
                else
                {
                    if earnModel.status_message == "user_not_found" || earnModel.status_message == "token_invalid" || earnModel.status_message == "Invalid credentials" || earnModel.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                    }
                    else{
                   
                    }
                }
                self.setChartWeeklyData()
                UberSupport().removeProgressInWindow(viewCtrl: self)
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                self.arrWeeklyCharyData.removeAllObjects()
                UberSupport().removeProgressInWindow(viewCtrl: self)
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }
    
    // SETTING CHART INFO AFTER GETTING WEEKLY INFO
    func setChartWeeklyData()
    {
        lblWeekCost.text = String(format:"%@ %@",strCurrency,chartModel.total_week_amount)
        tblEarnings.reloadData()
        let refs: [Any] = ["M", "TU", "W", "TH", "F", "SA", "SU"]
        var vals: [String] = []

        if arrWeeklyCharyData.count > 0
        {
            lblNoData.isHidden = true
            view1.isHidden = false
            view2.isHidden = false
            viewChartHolder.isHidden = false
            let arrTemp : NSMutableArray = NSMutableArray()
            
            for i in 0..<arrWeeklyCharyData.count
            {
                let modelInfo = arrWeeklyCharyData[i] as! EarningsDataModel
                arrTemp.add(modelInfo.daily_fare)
//               print("arrTemp\(arrTemp)")
            }
            vals = arrTemp as! [String]
            
        }
        
        if Float(chartModel.total_week_amount)! == 0.0
        {
            lblTopAmount.text = ""
            lblTopAmount1.text = ""
            lblTopAmount2.text = ""
            lblNoData.isHidden = false
            view1.isHidden = true
            view2.isHidden = true
            viewChartHolder.isHidden = true
        }
        else
        {
            let maxValue = vals.max()
//            print("maxValue \(maxValue!)")
            let maxval = Float(maxValue!)
            let value = (Float(maxValue!)! / 10)
            let value1 = Float(value)
            let add = Int(maxval! + value1)
            lblTopAmount.text = String(add)
            lblTopAmount1.text = String(add/2)
            viewChartHolder.isHidden = false
            lblNoData.isHidden = true

        }
        for view in viewChartHolder.subviews
        {
            view.removeFromSuperview()
        }

        let chart = DSBarChart.init(frame: viewChartHolder.bounds, color: UIColor(red: 214.0 / 255.0, green: 214.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0), references: refs, andValues: vals)
        chart?.delegate = self
        viewChartHolder.addSubview(chart!)
    }
    
    // MOVEING PRICE INFO WHEN CHART BAR TAPPED
    func chartViewTapped(_ tag: Int)
    {
        viewRateHolder.isHidden = false
        var rectTblView = viewRateHolder.frame
        rectTblView.origin.x = CGFloat(tag * 50)
        viewRateHolder.frame = rectTblView
        let modelInfo = arrWeeklyCharyData[tag] as! EarningsDataModel
        lblCurrentRate.text = modelInfo.daily_fare
    }
    
    
    func getWeekDaysInEnglish() -> [String] {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        return calendar.weekdaySymbols
    }
    
    enum SearchDirection
    {
        case Next
        case Previous
        
        var calendarOptions: NSCalendar.Options {
            switch self {
            case .Next:
                return .matchNextTime
            case .Previous:
                return [.searchBackwards, .matchNextTime]
            }
        }
    }
    
    // GETTING WEEKLY START DATE & END DATE
    func get(_ direction: SearchDirection, _ dayName: String, considerToday consider: Bool = false) -> NSDate {
        let weekdaysName = getWeekDaysInEnglish()
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let nextWeekDayIndex = weekdaysName.index(of: dayName)! + 1 // weekday is in form 1 ... 7 where as index is 0 ... 6
        
        let today = NSDate()
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        if consider && calendar.component(.weekday, from: today as Date) == nextWeekDayIndex {
            return today
        }
        
        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        
        
        let date = calendar.nextDate(after: today as Date, matching: nextDateComponent as DateComponents, options: direction.calendarOptions)
        
        return date! as NSDate
    }

    // MARK: UITableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellEarnItems = tblEarnings.dequeueReusableCell(withIdentifier: "CellEarnItems") as! CellEarnItems
        cell.selectionStyle = .none
        cell.lblTitle.text = arrMenus[indexPath.row]
        cell.lblIcon.text = indexPath.row == 0 ? "R" : "h"
        
        if chartModel != nil
        {
            cell.lblSubTitle.text = indexPath.row == 0 ? String(format:(chartModel.last_trip.count > 0) ? "Last trip: %@ %@" : "Last trip: %@ 0",strCurrency,chartModel.last_trip) : String(format:(chartModel.recent_payout.count > 0) ? "Most recent payout: %@ %@" : "Most recent payout: %@ 0" ,strCurrency, chartModel.recent_payout)
            
            cell.lblSubTitle.text = indexPath.row == 0 ? String(format:(chartModel.last_trip.count > 0) ? NSLocalizedString("Last trip: %@ %@", comment: "") : NSLocalizedString("Last trip: %@ 0", comment: ""),strCurrency,chartModel.last_trip) : String(format:(chartModel.recent_payout.count > 0) ? NSLocalizedString("Most recent payout: %@ %@", comment: ""): NSLocalizedString("Most recent payout: %@ 0", comment: "") ,strCurrency, chartModel.recent_payout)
        }
        
        return cell
    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0
        {
            let tripView = self.storyboard?.instantiateViewController(withIdentifier: "TripsVC") as! TripsVC
            self.navigationController?.pushViewController(tripView, animated: true)
        }
        else if indexPath.row == 1
        {
            let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "PayStatementVC") as! PayStatementVC
            self.navigationController?.pushViewController(propertyView, animated: true)
        }
    }
}

class CellEarnItems: UITableViewCell
{
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var lblIcon: UILabel!
    @IBOutlet var txtFldValues: UITextField!
    @IBOutlet var lblAccessory: UILabel!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var floatRatingView: FloatRatingView!
    @IBOutlet weak var carType: UILabel!
    @IBOutlet var selectedCurrency: UILabel!
   
   
    
}
