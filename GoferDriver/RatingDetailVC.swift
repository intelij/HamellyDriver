/**
* RatingDetailVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation
import MapKit

class RatingDetailVC : UIViewController,UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var tblReview: UITableView!

    let arrMenus: [String] = ["Trip History", "Pay Statements"]
    var arrFeedBackData : NSMutableArray = NSMutableArray()
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate

// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var rectTblView = tblReview.frame
        rectTblView.size.height = self.view.frame.size.height-70
        tblReview.frame = rectTblView
        self.getRiderFeedBack()
      }
    
    override func viewWillAppear(_ animated: Bool)
    {
//        UberSupport().changeStatusBarStyle(style: .lightContent)
    }
    
    //MARK: - API CALL - GETTING RIDER FEEDBACK
    func getRiderFeedBack()
    {
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        var dicts = [AnyHashable: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        UberAPICalls().GetRequest(dicts,methodName:METHOD_RIDER_FEEDBACK as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let gModel = response as! GeneralModel
            OperationQueue.main.addOperation {
                if gModel.status_code == "1"
                {
                    self.arrFeedBackData.addObjects(from: (gModel.arrTemp1 as NSArray) as! [Any])
                    self.tblReview.reloadData()
                }
                else
                {
                    if gModel.status_message == "user_not_found" || gModel.status_message == "token_invalid" || gModel.status_message == "Invalid credentials" || gModel.status_message == "Authentication Failed"
                    {
                        self.appDelegate.logOutDidFinish()
                        return
                    }
                    else{
                  
                    }
                }
                UberSupport().removeProgressInWindow(viewCtrl: self)
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                UberSupport().removeProgressInWindow(viewCtrl: self)
                self.appDelegate.createToastMessage(iApp.GoferError.server.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        })
    }


    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let feedbackModel = arrFeedBackData[indexPath.row] as? RatingFeedBackModel
        if feedbackModel?.rating_comments.count == 0
        {
            return 98 // setting row if have no comment text
        }
        else
        {
            let hight = UberSupport().onGetStringHeight(self.view.frame.size.width - 10, strContent: (feedbackModel?.rating_comments)! as NSString, font: UIFont (name: iApp.GoferFont.medium.font, size: 18)!)
            if hight < 50
            {
                return 160
            }
            else
            {
                return hight + 70
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrFeedBackData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellEarnItems = tblReview.dequeueReusableCell(withIdentifier: "CellEarnItems") as! CellEarnItems
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let feedbackModel = arrFeedBackData[indexPath.row] as? RatingFeedBackModel
        // Optional params
        cell.floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        cell.floatRatingView.rating = Float((feedbackModel?.rider_rating)!)!
        cell.lblTitle.isHidden = ["0 bytes",""].contains(feedbackModel?.rating_comments)
        cell.lblTitle.text = feedbackModel?.rating_comments
        cell.lblSubTitle.text = feedbackModel?.date
        return cell
    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
