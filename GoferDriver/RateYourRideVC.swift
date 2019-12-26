/**
 * RateYourRideVC.swift
 *
 * @package UberClone
 * @author Trioangle Product Team
 * @version - Stable 1.0
 * @link http://trioangle.com
 */

import UIKit

class RateYourRideVC: UIViewController, FloatRatingViewDelegate,UITextViewDelegate
{
    @IBOutlet var floatRatingView: FloatRatingView!
    @IBOutlet var btnSubmit: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var lblPlaceHolder: UILabel!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var txtComments: UITextView!

    var skipBtn = UIButton()
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var strTripID = ""
    var strRiderImgUrl = ""
    var isFromRoutePage : Bool = false
    var isFromTripPage : Bool = false
    var tripModel : EndTripModel!
    var arrTemp1 : NSMutableArray = NSMutableArray()
    var arrTripsData : NSMutableArray = NSMutableArray()

// MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        txtComments.keyboardType = .asciiCapable
        if !(self.tabBarController?.tabBar.isHidden ?? false){
            self.tabBarController?.tabBar.isHidden = true
        }
        /** Note: With the exception of contentMode, all of these
            properties can be set directly in Interface builder **/
        btnBack.isHidden = isFromRoutePage ? true : false
        txtComments.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        txtComments.layer.borderWidth = 2.0
        txtComments.layer.cornerRadius = 3.0
        btnSubmit.layer.cornerRadius = 3.0
        
        // Required float rating view params
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        self.floatRatingView.fullImage = UIImage(named: "StarFull")
        // Optional params
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 0
        self.floatRatingView.rating = 0.0
        self.floatRatingView.editable = true
      
        var lblFrame = lblPlaceHolder.frame
        lblFrame.origin.y = txtComments.frame.origin.y+8
        lblFrame.origin.x = txtComments.frame.origin.x+5
        lblPlaceHolder.frame = lblFrame
        
        imgUser.layer.cornerRadius = imgUser.frame.size.width / 2
        imgUser.clipsToBounds = true
        imgUser.sd_setImage(with: NSURL(string: strRiderImgUrl)! as URL, placeholderImage:UIImage(named:""))

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
      
//        UberSupport().changeStatusBarStyle(style: .default)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.initSkipButton()
            self.btnBack.isHidden = true
        }
    }
    //MARK:- skipButton
    func initSkipButton(){
        self.view.addSubview(self.skipBtn)
        self.view.bringSubviewToFront(self.skipBtn)
        
        self.skipBtn.setTitle("Skip".localize, for: .normal)
        self.skipBtn.titleLabel?.font = self.lblPlaceHolder.font
        self.skipBtn.setTitleColor(.ThemeMain, for: .normal)
        self.skipBtn.backgroundColor = .white
        
        let margin = view.layoutMarginsGuide
        let safeFrame = margin.layoutFrame
        let width : CGFloat = 50
        let height : CGFloat = 48
        let isRTL = ["ar","fa"].contains(appDelegate.language)
        self.skipBtn.frame = CGRect(x: isRTL ? 0 :safeFrame.maxX - width,
                                    y: safeFrame.minY,
                                    width: width,
                                    height: height)
        
        
        
        //        NSLayoutConstraint.activate([
        //            skipBtn.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
        //            skipBtn.widthAnchor.constraint(equalToConstant: 150),
        //            skipBtn.heightAnchor.constraint(equalToConstant: 60),
        //            skipBtn.topAnchor.constraint(equalTo: margin.topAnchor)
        //        ])
        
        self.skipBtn.addAction(for: .tap) {
            self.appDelegate.onSetRootViewController(viewCtrl: self)
        }
    }
    // MARK: - ViewController Methods
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .default)
//        self.setStatusBarStyle(UIStatusBarStyle.lightContent)
        self.navigationController?.isNavigationBarHidden = true
    }
    //Dissmiss keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: keyboardFrame.size.height, btnView: self.view)
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: 0, btnView: self.view)
    }

    //MARK: - TEXTVIEW DELEGATE METHOD
    func textViewDidChange(_ textView: UITextView)
    {
        lblPlaceHolder.isHidden = (txtComments.text.count > 0) ? true : false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if range.location == 0 && (text == " ") {
            return false
        }
        if (text == "") {
            return true
        }
        else if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    //MARK: TEXTVIEW DELEGATE END
    //MARK: -

    // MARK: FloatRatingViewDelegate
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
        self.view.endEditing(true)

    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        let strRating = NSString(format: "%.2f", self.floatRatingView.rating) as String
        floatRatingView.rating = Float(strRating)!
    }
   
    // MARK: When User Press Submit Button
    @IBAction func onSubmitTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        if Int(self.floatRatingView.rating) == 0
        {
            let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Message!!!", comment: ""), message: NSLocalizedString("Please give rating", comment: ""), preferredStyle:UIAlertController.Style.alert)
            settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
            }))
            present(settingsActionSheet, animated:true, completion:nil)

            return
        }

        updateRatingToApi()
    }
    
//MARK: - API CALL -> SUBMIT RATING
    
    func updateRatingToApi() {
        let paramDict = ["token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN),
                         "trip_id" : strTripID,
                         "rating" : String(format: "%d", Int(self.floatRatingView.rating)),
                         "rating_comments" :txtComments.text ?? String(),
                         "user_type" : "driver"] as [String : Any]
        WebServiceHandler.sharedInstance.getWebService(wsMethod:"trip_rating", paramDict: paramDict, viewController:self, isToShowProgress:true, isToStopInteraction:true) { (response) in
            let responseJson = response
            DispatchQueue.main.async {
                if responseJson["status_code"] as? String ?? String() == "1" {
                    self.arrTripsData.removeAllObjects()
                    self.arrTemp1.removeAllObjects()
                    let arrData = responseJson["invoice"] as? NSArray ?? NSArray()
                    for i in 0 ..< arrData.count
                    {
                        self.arrTemp1.addObjects(from: [InvoiceModel().initInvoiceData(responseDict: arrData[i] as! NSDictionary)])
                    }
                    self.arrTripsData.addObjects(from: (self.arrTemp1 as NSArray) as! [Any])
                    self.appDelegate.onSetRootViewController(viewCtrl: self)
//                    let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "MakePaymentVC") as! MakePaymentVC
//                    propertyView.payment_method = responseJson["payment_method"] as? String ?? String()
//                    propertyView.totalAmt = responseJson["total_fare"] as? String ?? String()
//                    propertyView.strTripID = self.strTripID
//                    propertyView.arrInfoKey = self.arrTripsData
//                    self.navigationController?.pushViewController(propertyView, animated: true)
                }
                else if responseJson["status_code"] as? String ?? String() == "2" {
                    self.appDelegate.self.makeSplashView(isFirstTime: true)
                    self.appDelegate.createToastMessageForAlamofire(responseJson.status_message, bgColor: UIColor.black, textColor: UIColor.white, forView:self.view)
                    self.onBackTapped(nil)
                }
                else{
                    self.appDelegate.createToastMessageForAlamofire(responseJson.status_message, bgColor: UIColor.black, textColor: UIColor.white, forView:self.view)
                }
            }
        }
    }
 
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)

        if isFromTripPage
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            appDelegate.onSetRootViewController(viewCtrl: self)
        }
    }
}

