//
//  AddPayoutVC.swift
//  GoferDriver
//
//  Created by bowshul sheik rahaman on 24/01/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
protocol AddStripePayoutDelegate
{
    func payoutStripeAdded()
}
class AddPayoutVC: UIViewController,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    //MARK: Outlets
    @IBOutlet weak var stripTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pickerHolder: UIView!
    @IBOutlet weak var closeButton : UIButton!
//    let pickerView = UIPickerView()
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var imgUserThumb: UIImageView!
    var pickerCloseButtonOutlet = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeAction));
    //MARK: Actions
    @IBAction func backAction(_ sender: Any) {
        _ = self.setSemantic(false)
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        let tagVal = sender.tag
        pickerHolder.isHidden = true
        
        var tempDict = [String:String]()
//        curencypicker = self.countries[tagVal].currencyCode
//        curencypicker = countries.filter({$0.countryName == self.selectedCountry}).first?.currencyCode ?? countries[0].currencyCode
//        let listModel = self.countryDicts[tagVal] as? PayoutPerferenceModel
        
        
        //(listModel?.currency_code) as! [String]
        
        switch type{
        case "gender":
            if selectedGender == String(){
                selectedGender = genderPicker[0]
            }
        case "currency":
            if selectedCurrency == String(){
                selectedCurrency = curencypicker[0]
            }
        default:
            if selectedCountry == String(){
            let modelTemp = countryNamepicker[0]
            let modele = countryCodepicker[0]
            selectedCountry = modelTemp as? String ?? String()
            selectedCountryCode = modele as? String ?? String()
            stripeArrayDataDict["Country".localize] = modelTemp as? String ?? String()//modele as? String ?? String()
            curencypicker = countries[0].currencyCode ?? [String]()
            }
        }
        switch selectedCountry {
        case "Australia":
            tempDict = ["Country".localize:selectedCountryCode,"Currency".localize:selectedCurrency,"BSB".localize:"","Account Number".localize:"","Account Holder Name".localize:"","Address1".localize:"","Address2".localize:"","City".localize:"","State / Province".localize:"","Postal Code".localize:""]
            stripeTitleArray = ["Country".localize,"Currency".localize,"BSB".localize,"Account Number".localize,"Account Holder Name".localize,"Address1".localize,"Address2".localize,"City".localize,"State / Province".localize,"Postal Code".localize]
        case "Canada":
            tempDict = ["Country".localize:selectedCountryCode,"Currency".localize:selectedCurrency,"Transit Number".localize:"","Institution Number".localize:"","Account Number".localize:"","Account Holder Name".localize:"","Address1".localize:"","Address2".localize:"","City".localize:"","State / Province".localize:"","Postal Code".localize:""]
            stripeTitleArray = ["Country".localize,"Currency".localize,"Transit Number".localize,"Institution Number".localize,"Account Number".localize,"Account Holder Name".localize,"Address1".localize,"Address2".localize,"City".localize,"State / Province".localize,"Postal Code".localize]
        case "New Zealand":
            tempDict = ["Country".localize:selectedCountryCode,"Currency".localize:selectedCurrency,"Rounting Number".localize:"","Account Number".localize:"","Account Holder Name".localize:"","Address1".localize:"","Address2".localize:"","City".localize:"","State / Province".localize:"","Postal Code".localize:""]
            stripeTitleArray = ["Country".localize,"Currency".localize,"Rounting Number".localize,"Account Number".localize,"Account Holder Name".localize,"Address1".localize,"Address2".localize,"City".localize,"State / Province".localize,"Postal Code".localize]
        case "United States":
            tempDict = ["Country".localize:selectedCountryCode,"Currency".localize:selectedCurrency,"Rounting Number".localize:"", "SSN Last 4 Digits".localize:"","Account Number".localize:"","Account Holder Name".localize:"","Address1".localize:"","Address2".localize:"","City".localize:"","State / Province".localize:"","Postal Code".localize:""]
            stripeTitleArray = ["Country".localize,"Currency".localize,"Rounting Number".localize, "SSN Last 4 Digits".localize,"Account Number".localize,"Account Holder Name".localize,"Address1".localize,"Address2".localize,"City".localize,"State / Province".localize,"Postal Code".localize]
        case "Singapore":
            tempDict = ["Country".localize:selectedCountryCode,"Currency".localize:selectedCurrency,"Bank Code".localize:"","Branch Code".localize:"","Account Number".localize:"","Account Holder Name".localize:"","Address1".localize:"","Address2".localize:"","City".localize:"","State / Province".localize:"","Postal Code".localize:""]
            stripeTitleArray = ["Country".localize,"Currency".localize,"Bank Code".localize,"Branch Code".localize,"Account Number".localize,"Account Holder Name".localize,"Address1".localize,"Address2".localize,"City".localize,"State / Province".localize,"Postal Code".localize]
        case "United Kingdom":
            tempDict = ["Country".localize:selectedCountryCode,"Currency".localize:selectedCurrency,"Sort Code".localize:"","Account Number".localize:"","Account Holder Name".localize:"","Address1".localize:"","Address2".localize:"","City".localize:"","State / Province".localize:"","Postal Code".localize:""]
            stripeTitleArray = ["Country".localize,"Currency".localize,"Sort Code".localize,"Account Number".localize,"Account Holder Name".localize,"Address1".localize,"Address2".localize,"City".localize,"State / Province".localize,"Postal Code".localize]
        case "Hong Kong":
            tempDict = ["Country".localize:selectedCountryCode,"Currency".localize:selectedCurrency,"Clearing Code".localize:"","Branch Code".localize:"","Account Number".localize:"","Account Holder Name".localize:"","Address1".localize:"","Address2".localize:"","City".localize:"","State / Province".localize:"","Postal Code".localize:""]
            stripeTitleArray = ["Country".localize,"Currency".localize,"Clearing Code".localize,"Branch Code".localize,"Account Number".localize,"Account Holder Name".localize,"Address1".localize,"Address2".localize,"City".localize,"State / Province".localize,"Postal Code".localize]
        case "Japan":
            tempDict = ["Country".localize:selectedCountryCode,
                        "Currency".localize:selectedCurrency,
                        "Bank Name".localize:"",
                        "Branch Name".localize:"",
                        "Bank Code".localize:"",
                        "Branch Code".localize:"",
                        "Account Number".localize:"",
                        "Account Owner Name".localize:"",
                        "Phone Number".localize:"",
                        "Account Holder Name".localize:"",
                        "Gender".localize:selectedGender,
                        "Address1".localize:"",
                        "Address2".localize:"",
                        "City".localize:"",
                        "State / Province".localize:"",
                        "Postal Code".localize:"",
                        "KanaAddress1".localize:"",
                        "KanaAddress2".localize:"",
                        "KanaCity".localize:"",
                        "KanaState / Province".localize:"",
                        "KanaPostal Code".localize:""]
            stripeTitleArray = ["Country".localize,
                                "Currency".localize,
                                "Bank Name".localize,
                                "Branch Name".localize,
                                "Bank Code".localize,
                                "Branch Code".localize,
                                "Account Number".localize,
                                "Account Owner Name".localize,
                                "Phone Number".localize,
                                "Account Holder Name".localize,
                                "Gender".localize]
            
            AddressKana = ["Address1".localize,"Address2".localize,"City".localize,"State / Province".localize,"Postal Code".localize]
            AddressKanji = ["KanaAddress1".localize,"KanaAddress2".localize,"KanaCity".localize,"KanaState / Province".localize,"KanaPostal Code".localize]
        default:
            tempDict = ["Country".localize:selectedCountryCode,
                        "Currency".localize:selectedCurrency,
                        "IBAN Number".localize:"",
                        "Account Holder Name".localize:"",
                        "Address1".localize:"",
                        "Address2".localize:"",
                        "City".localize:"",
                        "State / Province".localize:"",
                        "Postal Code".localize:""]
            stripeTitleArray = ["Country".localize,"Currency".localize,"IBAN Number".localize,
                                "Account Holder Name".localize,"Address1".localize,
                                "Address2".localize,
                                "City".localize,
                                "State / Province".localize,
                                "Postal Code".localize]
        }
        for key in tempDict.keys {
            if stripeArrayDataDict.keys.contains(key) {
                
                if ["gender", "currency"].contains(type){
                    if (!["Country".localize,"Currency".localize,"Gender".localize].contains(key)){
                        tempDict[key] = ""//stripeArrayDataDict[key]
                    }
                }else {
                    if (!["Country".localize].contains(key)){
                        tempDict[key] = ""//stripeArrayDataDict[key]
                        self.selectedGender = String()
                        self.selectedCurrency = String()
                    }
                }
            }
        }
        stripeArrayDataDict = tempDict
//        stripeTitleArray = tempDict.enumerated().compactMap({ (ofset,element) -> String? in
//            return element.key
//        })//tempDict.compactMap({$0.key})
        stripTableView.reloadData()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let address2 = "Address2".localize
        for title in stripeTitleArray{
            if title != address2 ||  title != address2{
                if (stripeArrayDataDict["\(title)"]?.count == 0) || stripeArrayDataDict["\(title)"] == nil  {
                    appDelegate.createToastMessage("Please Enter the".localize+" \(title)", bgColor: .black, textColor: .white)
                    
                    return
                }
            }

        }
        /*for key in stripeArrayDataDict {
            print(key.key,key.value,address2)
            if key.key != address2 ||  key.key != address2{
                if (stripeArrayDataDict["\(key.key)"]?.count == 0) || stripeArrayDataDict["\(key.key)"] == nil  {
                    appDelegate.createToastMessage("Please Enter the".localize+" \(key.key)", bgColor: .black, textColor: .white)
                 
                    return
                }
            }
        }*/
        var genderVal = ""
        genderVal = checkNilValue(value:stripeArrayDataDict["Gender"])
        genderVal = genderVal.lowercased()
        print(genderVal)
        var tokenDict = Parameters()
        tokenDict = ["country" :  checkNilValue(value:stripeArrayDataDict["Country".localize]),
                         "currency" : checkNilValue(value:stripeArrayDataDict["Currency".localize]),
                         "iban" : checkNilValue(value:stripeArrayDataDict["IBAN Number".localize]),
                         "bsb" : checkNilValue(value:stripeArrayDataDict["BSB".localize]),
                         "ssn_last_4" : checkNilValue(value:stripeArrayDataDict["SSN Last 4 Digits".localize]),
                         "sort_code" : checkNilValue(value:stripeArrayDataDict["Sort Code".localize]),
                         "clearing_code" : checkNilValue(value:stripeArrayDataDict["Clearing Code".localize]),
                         "transit_number" : checkNilValue(value:stripeArrayDataDict["Transit Number".localize]),
                         "institution_number": checkNilValue(value:stripeArrayDataDict["Institution Number".localize]),
                         "account_number" : checkNilValue(value:stripeArrayDataDict["Account Number".localize]),
                         "routing_number": checkNilValue(value:stripeArrayDataDict["Rounting Number".localize]),
                         "bank_name" : checkNilValue(value:stripeArrayDataDict["Bank Name".localize]),
                         "branch_name": checkNilValue(value:stripeArrayDataDict["Branch Name".localize]),
                         "bank_code" : checkNilValue(value:stripeArrayDataDict["Bank Code".localize]),
                         "branch_code": checkNilValue(value:stripeArrayDataDict["Branch Code".localize]),
                         "account_holder_name" : checkNilValue(value:stripeArrayDataDict["Account Holder Name".localize]),
                         "account_owner_name" : checkNilValue(value:stripeArrayDataDict["Account Owner Name".localize]),
                         "phone_number" : checkNilValue(value:stripeArrayDataDict["Phone Number".localize]),
                         "address1" : checkNilValue(value:stripeArrayDataDict["Address1".localize]),
                         "address2" : checkNilValue(value:stripeArrayDataDict["Address2".localize]),
                         "city" : checkNilValue(value:stripeArrayDataDict["City".localize]),
                         "state" : checkNilValue(value:stripeArrayDataDict["State / Province".localize]),
                         "postal_code" : checkNilValue(value:stripeArrayDataDict["Postal Code".localize]),
                         "kanji_address1" : checkNilValue(value:stripeArrayDataDict["KanaAddress1".localize]),
                         "kanji_address2" : checkNilValue(value:stripeArrayDataDict["KanaAddress2".localize]),
                         "kanji_city" : checkNilValue(value:stripeArrayDataDict["KanaCity".localize]),
                         "kanji_state" : checkNilValue(value:stripeArrayDataDict["KanaState / Province".localize]),
                         "kanji_postal_code" : checkNilValue(value:stripeArrayDataDict["KanaPostal Code".localize]),
                         "payout_method" : "stripe",
                         "gender" : genderVal,
                         "token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)]
        
//        "document" : updateimg,???
        if let image2Upload = self.uploadImage {
           
            self.submitButton.isUserInteractionEnabled = false
            let uberSupport = UberSupport()
            uberSupport.showProgressInWindow(showAnimation: true)
            PaymentInteractor.instance.addPayout(withDetails: tokenDict, imageName: self.imgName, data: self.uploadImageData ?? Data()) { (didSucceed) in
                self.submitButton.isUserInteractionEnabled = true
                uberSupport.removeProgressInWindow()
                if didSucceed{
                    self.navigationController?.popViewController(animated: true)
                }else{
                    print("∂",didSucceed)
                }
            }
           
        }
        else{
            
            appDelegate.createToastMessage("Please update a legal document.".localize, bgColor: .black, textColor: .white)
        }
        
    }
    @IBAction func onTableRowTapped(_ sender:UIButton!)
    {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        selectedCell = stripTableView.cellForRow(at: indexPath) as! StripeCell
        if sender.tag==0
        {
            self.view.endEditing(true)
            type = "country"
            pickerHolder.isHidden = false
            pickerView.reloadAllComponents()
            
            self.view.bringSubviewToFront(self.pickerHolder)
            if stripeArrayDataDict["Country".localize]?.count == 0 {
                stripeArrayDataDict["Country".localize] = countryNamepicker[0]//countryCodepicker[0]
                pickerView.selectRow(0, inComponent: 0, animated: true)
            }
            else {
                
                pickerView.selectRow(countryNamepicker.index(of: selectedCountry) ?? 0, inComponent: 0, animated: true)
            }
            stripeArrayDataDict["Currency".localize] = ""
        }
            
        else if sender.tag==1
        {
            guard (stripeArrayDataDict["Country".localize]?.count)! > 0 else {
                return
            }
            self.view.endEditing(true)
            type = "currency"
            pickerHolder.isHidden = false
            pickerView.reloadAllComponents()
            if stripeArrayDataDict["Currency".localize]?.count == 0,!curencypicker.isEmpty {
                stripeArrayDataDict["Currency".localize] = curencypicker[0]
                pickerView.selectRow(0, inComponent: 0, animated: true)
            }
            else {
                pickerView.selectRow(curencypicker.index(of: selectedCurrency) ?? 0, inComponent: 0, animated: true)
            }
        }
        else if sender.tag==10 // japan only
        {
            guard (stripeArrayDataDict["Country".localize]?.count)! > 0 else {
                return
            }
            self.view.endEditing(true)
            type = "gender"
            pickerHolder.isHidden = false
            pickerView.reloadAllComponents()
            if stripeArrayDataDict["Gender".localize]?.count == 0 {
                stripeArrayDataDict["Gender".localize] = genderPicker[0]
                pickerView.selectRow(0, inComponent: 0, animated: true)
            }
            else {
                pickerView.selectRow(genderPicker.index(of: selectedGender) ?? 0, inComponent: 0, animated: true)
            }
        }
        else
        {
            selectedCell.txtPayouts?.inputView = nil
            selectedCell.txtPayouts?.keyboardType = (sender.tag==4) ? UIKeyboardType.asciiCapable : UIKeyboardType.asciiCapable
            pickerHolder.isHidden = true
            selectedCell.txtPayouts?.becomeFirstResponder()
        }
        pickerView.reloadAllComponents()
    }
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var imagePicker = UIImagePickerController()
    var stripeArrayDataDict = [String:String]()
    var stripeTitleArray = [String]()
    var AddressKana = [String]()
    var AddressKanji = [String]()
    var curencypicker = [String]()
    var countryNamepicker = [String]()
    var countryIdpicker = [String]()
    var countryCodepicker = [String]()
    var genderPicker = ["Male".localize,"Female".localize]
    var countryDicts : NSMutableArray = NSMutableArray()
    var countries = [CountryList]()
    var selectedCountry = String()
    var selectedCountryCode = ""
    var selectedCurrency = ""
    var selectedGender = ""
    let triggerTF = UITextField()
    var type = ""
    var user_id = ""
    var updateimg = ""
    var imgName = ""
    var selectedCell : StripeCell!
    var uploadImage : UIImage?
    var uploadImageData : Data?
    var delegate: AddStripePayoutDelegate?
    //MARK: view life cycle
    override func viewDidLoad() {
        if self.setSemantic(true){
            self.backButton.setTitle("I", for: .normal)
        }else{
            self.backButton.setTitle("e", for: .normal)
        }
        super.viewDidLoad()
        self.initView()
        self.getCountryName()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    //MARK: initializers
    func initView(){
        
        self.stripTableView.delegate = self
        self.stripTableView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pageTitle.text = "Payouts".localize
        self.submitButton.setTitle("Submit".localize, for: .normal)
        self.closeButton.setTitle("Done".localize, for: .normal)
        self.pickerHolder.elevate(8.0)
      
        self.pickerHolder.isHidden = true
        stripeArrayDataDict = ["Country".localize:"",
                               "Currency".localize:"",
                               "IBAN Number".localize:"",
                               "Account Holder Name".localize:"",
                               "Address1".localize:"",
                               "Address2".localize:"",
                               "City".localize:"",
                               "State / Province".localize:"",
                               "Postal Code".localize:""]
        stripeTitleArray = ["Country".localize,"Currency".localize,"IBAN Number".localize,"Account Holder Name".localize,"Address1".localize,"Address2".localize,"City".localize,"State / Province".localize,"Postal Code".localize]
        stripTableView.showsHorizontalScrollIndicator = false
    }
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    //MARK: initwithStory
    class func initWithStory() -> AddPayoutVC{
        let view = UIStoryboard(name: STORY_PAYMENT, bundle: nil).instantiateViewController(withIdentifier: "AddPayoutVC") as! AddPayoutVC
        return view
    }
    @objc func openPhotoAccess(){
        self.view.endEditing(true)
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel".localize, destructiveButtonTitle: nil, otherButtonTitles: "Take Photo".localize, "Choose Photo".localize)
        actionSheet.show(in: self.view)
    }
    func checkNilValue(value:String?) -> String {
        if value == nil {
            return ""
        }
        else {
            return value!
        }
    }
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        if buttonIndex == 1
        {
            self.checkTakePhotoAuthorization()
        }
        else if buttonIndex == 2
        {
            self.choosePhoto()
        }
    }
    
    func takePhoto()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = true
            UIImagePickerController.isSourceTypeAvailable(.camera)
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let settingsActionSheet: UIAlertController = UIAlertController(title:"Error".localize, message:"Device has no camera".localize, preferredStyle:UIAlertController.Style.alert)
            settingsActionSheet.addAction(UIAlertAction(title:"OK".localize, style:UIAlertAction.Style.cancel, handler:nil))
            present(settingsActionSheet, animated:true, completion:nil)
        }
        
    }
    func checkTakePhotoAuthorization(){
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            self.takePhoto()
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // User granted
                    self.takePhoto()
                } else {
                    let alert = UIAlertController(
                        title: "Alert".localize,
                        message: "Camera access required for capturing photos!".localize,
                        preferredStyle: UIAlertController.Style.alert
                    )
                    alert.addAction(UIAlertAction(title: "Cancel".localize, style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Allow Camera".localize, style: .cancel, handler: { (alert) -> Void in
                       // UIApplication.shared.openURL()
                        if let url = URL(string: UIApplication.openSettingsURLString){
                            UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey:Any](), completionHandler: { (val) in
                            })
                            
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    func choosePhoto()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)
        {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            
        }
        
    }
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if (info[.originalImage] as? UIImage) != nil {
            let pickedImageEdited: UIImage? = (info[.editedImage] as? UIImage)
            self.uploadImage = pickedImageEdited
            let imageData:NSData = pickedImageEdited!.pngData()! as NSData as NSData
            self.uploadImageData = pickedImageEdited!.pngData()
            updateimg = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            imgName = "IMG_\(hour)\(minutes).png"
            stripTableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    //MARK: API integration
    func callApiUpdate(requestParams: [String:Any]) {
        
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        WebServiceHandler.sharedInstance.getWebService(wsMethod:"add_payout_preference", paramDict: requestParams, viewController:self, isToShowProgress:true, isToStopInteraction:true) { (response) in
            let responseJson = response
            DispatchQueue.main.async {
                if responseJson["status_code"] as? String ?? String() == "1" {
                    UberSupport().removeProgressInWindow(viewCtrl: self)
//                    self.delegate?.payoutStripeAdded()
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                       self.appDelegate.createToastMessage(responseJson.status_message, bgColor: .black, textColor: .white)
                    
                    UberSupport().removeProgressInWindow(viewCtrl: self)
                }
                
            }
        }
    }
    func getCountryName()
    {
        if !UberSupport().checkNetworkIssue(self, errorMsg: "")
        {
            return
        }
       
       
        PaymentInteractor.instance.getStripeCountry { (countryLists) in
            self.countries = countryLists
            self.countryNamepicker = self.countries.compactMap({$0.countryName})
            self.countryCodepicker = self.countries.compactMap({$0.countryCode})
            self.stripTableView.reloadData()
            self.pickerView.reloadAllComponents()
           
        }
        
    }
}
extension AddPayoutVC : UITableViewDelegate,UITableViewDataSource{
    // MARK: TABLE VIEW DELEGATE AND DATA SOURCE ADDED
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if selectedCountry == "Japan"{
            return 4
        }
        else{
            return 2
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if countryNamepicker.count != 0 {
            switch section{
            case 0:
                return stripeTitleArray.count
            case 1 where selectedCountry == "Japan":
                return AddressKana.count
            case 2 where selectedCountry == "Japan":
                return AddressKanji.count
            default:
                return 1
            }
        }else{
            return 0
        }
        //            if selectedCountry == "Japan"{
        //                return section == 0 ? stripeArrayDataDict.count : section == 1 ? AddressKana.count : section == 2 ? AddressKanji.count : 1
        //            }
        //            else{
        //                return section == 0 ? stripeArrayDataDict.count : 1
        //            }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let viewHolder:UIView = UIView()
        viewHolder.frame =  CGRect(x: 0, y:0, width: (stripTableView.frame.size.width) ,height: 40)
        let lblRoomName:UILabel = UILabel()
        lblRoomName.frame =  CGRect(x: 0, y:20, width: viewHolder.frame.size.width ,height: 40)
        if selectedCountry == "Japan"{
            if section == 0
            {
                lblRoomName.text = "Stripe Details".localize
            }
            else if section == 1
            {
                lblRoomName.text = "Address Kana".localize
            }
            else if section == 2
            {
                lblRoomName.text = "Address Kanji".localize
            }
            else
            {
                lblRoomName.text = ""
            }
        }
        else{
            lblRoomName.text = "Stripe Details".localize
            
            if section == 0
            {
                lblRoomName.text = "Stripe Details".localize
            }
            else
            {
                lblRoomName.text = ""
            }
        }
//        lblRoomName.font = UIFont (name: CIRCULAR_BOOK, size: 15)
        viewHolder.backgroundColor = self.view.backgroundColor
        lblRoomName.textAlignment = NSTextAlignment.center
        lblRoomName.textColor = UIColor.darkGray
        viewHolder.addSubview(lblRoomName)
        return viewHolder
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedCountry == "Japan".localize{
            if indexPath.section==0{
                let cell = stripTableView.dequeueReusableCell(withIdentifier: "StripeCell") as! StripeCell
                cell.txtPayouts?.autocorrectionType = .no
                cell.lblDetails?.text = stripeTitleArray[indexPath.row]
                cell.txtPayouts?.delegate = self
                cell.btnDetails?.tag = indexPath.row
                cell.additionalTitle.isHidden = true
                cell.lblDetails?.isHidden = false
                cell.btnDetails?.isHidden = (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 10) ? false : true
                cell.btnDetails?.addTarget(self, action: #selector(self.onTableRowTapped), for: UIControl.Event.touchUpInside)
                cell.btnDetails?.isUserInteractionEnabled = true
                if indexPath.row == 0 {
                    cell.txtPayouts?.text = selectedCountry
                }
                else{
                    cell.txtPayouts?.text = stripeArrayDataDict[(cell.lblDetails?.text)!]
                }
                return cell
            }
            else if indexPath.section==1{
                let cell = stripTableView.dequeueReusableCell(withIdentifier: "StripeCell") as! StripeCell
                cell.txtPayouts?.autocorrectionType = .no
                cell.lblDetails?.text = AddressKana[indexPath.row] as String
                cell.additionalTitle.isHidden = true
                cell.lblDetails?.isHidden = false
                cell.txtPayouts?.text = stripeArrayDataDict[(cell.lblDetails?.text)!]
                cell.btnDetails?.isHidden = true
                return cell
            }
            else if indexPath.section==2{
                let cell = stripTableView.dequeueReusableCell(withIdentifier: "StripeCell") as! StripeCell
                cell.txtPayouts?.autocorrectionType = .no
                let title = ["Address1".localize,"Address2".localize,"City".localize,"State / Province".localize,"Postal Code".localize]
                cell.additionalTitle.isHidden = false
                cell.lblDetails?.isHidden = true
                cell.lblDetails?.text = AddressKanji[indexPath.row] as String
                cell.additionalTitle?.text = title[indexPath.row] as String
                cell.txtPayouts?.text = stripeArrayDataDict[(cell.lblDetails?.text)!]
                
                cell.btnDetails?.isHidden = true
                return cell
            }
            else{
                let cell = stripTableView.dequeueReusableCell(withIdentifier: "legalCellTVC") as! legalCellTVC
                cell.choosecamerabutton.addTarget(self, action: #selector(self.openPhotoAccess), for: UIControl.Event.touchUpInside)
                cell.updateimgNameLabel.text = imgName
                return cell
            }
        }
        else{
            if indexPath.section==0{
                let cell = stripTableView.dequeueReusableCell(withIdentifier: "StripeCell") as! StripeCell
                cell.lblDetails?.text = stripeTitleArray[indexPath.row]
                cell.btnDetails?.tag = indexPath.row
                cell.additionalTitle.isHidden = true
                cell.lblDetails?.isHidden = false
                cell.btnDetails?.isHidden = (indexPath.row == 0 || indexPath.row == 1) ? false : true
                cell.btnDetails?.addTarget(self, action: #selector(self.onTableRowTapped), for: UIControl.Event.touchUpInside)
                cell.btnDetails?.isUserInteractionEnabled = true
                cell.txtPayouts?.delegate = self
                if indexPath.row == 0 {
                    cell.txtPayouts?.text = selectedCountry
                }
                else{
                    cell.txtPayouts?.text = stripeArrayDataDict[(cell.lblDetails?.text)!]
                }
                return cell
            }
            else{
                let cell = stripTableView.dequeueReusableCell(withIdentifier: "legalCellTVC") as! legalCellTVC
                cell.choosecamerabutton.addTarget(self, action: #selector(self.openPhotoAccess), for: UIControl.Event.touchUpInside)
                cell.updateimgNameLabel.text = imgName
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
extension AddPayoutVC : UITextFieldDelegate{
    // MARK:- TEXT DELEGATE METHOD
    
    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let string = textField.text else {return true}
        let cell: StripeCell = textField.superview!.superview as! StripeCell
        if string.count > 0 {
            stripeArrayDataDict[(cell.lblDetails?.text)!] = textField.text! + string
        }
        else{
            stripeArrayDataDict[(cell.lblDetails?.text)!] = string
        }
        return true
    }*/
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        guard let string = textField.text else {return}
        let cell: StripeCell = textField.superview!.superview as! StripeCell
        stripeArrayDataDict[(cell.lblDetails?.text)!] = string
    }
/*    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let cell: StripeCell = textField.superview!.superview as! StripeCell
        if string.count > 0 {
            stripeArrayDataDict[(cell.lblDetails?.text)!] = textField.text ?? String() + string
        }
        else{
            stripeArrayDataDict[(cell.lblDetails?.text)!] = string
        }
        return true
    }*/
}
extension AddPayoutVC: UIPickerViewDelegate,UIPickerViewDataSource{
    //MARK: PICKER VIEW DELEGATE AND DATA SOURCE
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        if type == "currency"  {
            return curencypicker.count
        }
        else if type == "gender"{
            return genderPicker.count
        }
        else{
            return countryNamepicker.count
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString: NSAttributedString!
        var modelTemp = ""
        if type == "currency" {
            modelTemp = curencypicker[row]
        }
        else if type == "country"{
            modelTemp = countryNamepicker[row]
        }
        else if type == "gender"{
            modelTemp = genderPicker[row]
        }
        attributedString = NSAttributedString(string: modelTemp, attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 42.0 / 255.0, green: 42.0 / 255.0, blue: 43.0 / 255.0, alpha: 1.0)])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if type == "currency" {
            let modelTemp = curencypicker[row]
            selectedCurrency = modelTemp
            stripeArrayDataDict["Currency".localize] = modelTemp
        }
        else if type == "gender" {
            let modelTemp = genderPicker[row]
            selectedGender = modelTemp
            stripeArrayDataDict["Gender".localize] = modelTemp
        }
        else{
            let modelTemp = countryNamepicker[row]
            let modele = countryCodepicker[row]
            selectedCountry = modelTemp as? String ?? String()
            selectedCountryCode = modele as? String ?? String()
            stripeArrayDataDict["Country".localize] = modelTemp as? String ?? String()//modele as? String ?? String()
            curencypicker = countries[row].currencyCode ?? [String]()
            pickerCloseButtonOutlet.tag = row
        }
//        self.closeAction(pickerCloseButtonOutlet)
        
    }
}
class legalCellTVC :UITableViewCell{
    
    @IBOutlet weak var updateimgNameLabel: UILabel!
    @IBOutlet weak var choosecamerabutton: UIButton!
    
}
class StripeCell : UITableViewCell,UITextFieldDelegate {
    @IBOutlet var txtPayouts: UITextField?
    @IBOutlet var lblDetails: UILabel?
    @IBOutlet var btnDetails: UIButton?
    @IBOutlet weak var additionalTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtPayouts?.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
