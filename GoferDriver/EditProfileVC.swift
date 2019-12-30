/**
* EditProfileVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import Foundation
import MapKit
import Photos
import AVFoundation
//Gofer

protocol EditProfileDelegate
{
    func setprofileInfo(proModel: ProfileModel)
}

class EditProfileVC : UIViewController,UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var tblEditProfile: UITableView!
    @IBOutlet var imgUserThumb: UIImageView!
    @IBOutlet var viewTblHeader: UIView!
    @IBOutlet var viewEditHolder: UIView!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var viewMediaHoder: UIView!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnEdiIcon: UIButton!
    @IBOutlet var btnCameraIcon: UIButton!

    var arrTitle = [String]()

    var arrProfileValues = [String]()
    var arrDummyValues = [String]()
    var imagePicker = UIImagePickerController()
    
    var profileModel : ProfileModel!
    var selectedCell : CellEarnItems!
    var delegate: EditProfileDelegate?

    var strUserName = ""
    var strFirstName = ""
    var strLastName = ""
    var strMobileNumber = ""
    var strEmailId = ""
    var strAddress1 = ""
    var strAddress2 = ""
    var strCity = ""
    var strPostalCode = ""
    var strState = ""
    var strUserImgUrl = ""
    
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()

        var frame = tblEditProfile.frame
        if self.checkDevice() {
            frame = CGRect(x: 0, y: 45, width: self.view.frame.width, height: self.view.frame.height)
             tblEditProfile.frame = frame
        }
        
       
        txtPassword.keyboardType = .asciiCapable
        arrTitle = [
            NSLocalizedString("First Name", comment: ""),NSLocalizedString("Last Name", comment: ""),NSLocalizedString("Email", comment: ""),NSLocalizedString("Phone Number", comment: ""),NSLocalizedString("Address Line 1", comment: ""),NSLocalizedString("Address Line 2", comment: ""),NSLocalizedString("City", comment: ""),NSLocalizedString("Postal Code", comment: ""),NSLocalizedString("State", comment: "")]

        viewEditHolder.isHidden = true
        viewMediaHoder.isHidden = true
        tblEditProfile.tableHeaderView = viewTblHeader
        imgUserThumb.layer.cornerRadius = imgUserThumb.frame.size.width / 2
        imgUserThumb.clipsToBounds = true        
        btnCancel.layer.borderColor = UIColor.ThemeMain.cgColor
        btnCancel.layer.borderWidth = 1.0
        UITextField.appearance().tintColor = UIColor(red: 30.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)

        if profileModel != nil
        {
            self.setUserProfileInfo()
        }
        checkSaveButtonStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateNewPhoneNo), name: NSNotification.Name(rawValue: "phonenochanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //Hide keyboards
    @objc func keyboardWillShow(notification: NSNotification)
    {
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        tblEditProfile.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(10.0)), animated: true)
    }
// set the profile data from the api
    func setUserProfileInfo()
    {
        imgUserThumb?.sd_setImage(with: NSURL(string: profileModel.user_thumb_image)! as URL, placeholderImage:UIImage(named:""))
        strUserName = ""
        strFirstName = profileModel.first_name
        strLastName = profileModel.last_name
        strMobileNumber = profileModel.mobile_number
        strEmailId = profileModel.email_id
        strAddress1 = profileModel.address_line1
        strAddress2 = profileModel.address_line2
        strCity = profileModel.city
        strPostalCode = profileModel.postal_code
        strState = profileModel.state
        strUserImgUrl = profileModel.user_thumb_image
        arrProfileValues = [strFirstName, strLastName, strEmailId, strMobileNumber, strAddress1, strAddress2, strCity, strPostalCode, strState]
        arrDummyValues = arrProfileValues
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
//        UberSupport().changeStatusBarStyle(style: .lightContent)
    }
// Update the phone no
    @objc func updateNewPhoneNo(notification: Notification)
    {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        for i in 0 ..< viewControllers.count
        {
            let obj = viewControllers[i]
            if obj is EditProfileVC
            {
                self.navigationController?.popToViewController(obj, animated: true)
            }
        }
        
        let str2 = notification.userInfo
        let strPhoneNo = str2?["phone_no"] as? String ?? String()
        strMobileNumber = strPhoneNo
        arrProfileValues = [strFirstName, strLastName, strEmailId, strMobileNumber, strAddress1, strAddress2, strCity, strPostalCode, strState]
        tblEditProfile.reloadData()
        self.makeTickButton()
    }

    // MARK: When User Press Back Button
    @IBAction func onEditProfileTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        if sender.tag == 0
        {
            if btnEdiIcon.titleLabel?.text != "z"
            {
                self.onSaveProfileTapped() // Update Profile API Calling
            }
        }
        else
        {
            viewMediaHoder.isHidden = false
        }
    }

    // MARK: When User Press Back Button
    @IBAction func onPasswordHelpbuttonTapped(_ sender:UIButton!)
    {
        txtPassword.resignFirstResponder()
        viewEditHolder.isHidden = true
    }

    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 1) ? 50 : 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let viewHolder:UIView = UIView()
        viewHolder.frame =  CGRect(x: 0, y:0, width: (self.view.frame.size.width) ,height: (section == 1) ? 20 :  50)
        viewHolder.backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
        
        let lblTitle:UILabel = UILabel()
        lblTitle.frame =  CGRect(x: 16, y:20, width: (self.view.frame.size.width) ,height:  (section == 1) ? 0 : 30)
        lblTitle.backgroundColor = UIColor.clear
        lblTitle.text = (section == 0) ? NSLocalizedString("Personal Information", comment: "") : NSLocalizedString("Address", comment: "")

        lblTitle.font = UIFont (name: iApp.GoferFont.bold.font, size: 12)
        lblTitle.textColor = UIColor(red: 58.0 / 255.0, green: 58.0 / 255.0, blue: 71.0 / 255.0, alpha: 1.0)
        viewHolder.addSubview(lblTitle)
        return viewHolder
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return (indexPath.section == 1) ? 70 : 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if profileModel != nil
        {
            return (section == 0) ? 3 : 5
        }
        
        return (section == 0) ? 0 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0
        {
            if indexPath.row == 0
            {
                let cell:CellProfileItems = tblEditProfile.dequeueReusableCell(withIdentifier: "CellProfileItems") as! CellProfileItems
                cell.lblTitle.text = arrTitle[0]
                cell.txtFldValues.text = arrProfileValues[0]
                cell.txtFldValues.tag = 0
                cell.lblTitle1.text = arrTitle[1]
                cell.txtFldValues1.text = arrProfileValues[1]
                cell.txtFldValues1.tag = 1
                return cell
            }
            else
            {
                let cell:CellEarnItems = tblEditProfile.dequeueReusableCell(withIdentifier: "CellEarnItems") as! CellEarnItems
                cell.lblTitle.text = arrTitle[indexPath.row+1]
                cell.txtFldValues.text = arrProfileValues[indexPath.row+1]
                if indexPath.row == 1
                {
                    cell.txtFldValues.tag = 2
                }
                else
                {
                    cell.txtFldValues.tag = 3
                }
//                cell.txtFldValues.tag = indexPath.row+1
                cell.txtFldValues.isUserInteractionEnabled = (indexPath.row == 2) ? false : true
                return cell
            }
        }
        else
        {
            let cell:CellEarnItems = tblEditProfile.dequeueReusableCell(withIdentifier: "CellEarnItems") as! CellEarnItems
            cell.lblTitle.text = arrTitle[indexPath.row+4]
            cell.txtFldValues.text = arrProfileValues[indexPath.row+4]
            cell.txtFldValues.isUserInteractionEnabled = true
            cell.txtFldValues.tag = indexPath.row+4
            cell.txtFldValues.isUserInteractionEnabled = true
            return cell
        }

    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 2 && indexPath.section == 0
        {
//            self.gotoPhoneNoPage()
            let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                      for: .changeNumber)
            self.present(mobileValidationVC, animated: true, completion: nil)
//            AccountKitHelper.instance.verifyWithView(self, number: nil, success: { (account) in
//                let number = account!.phoneNumber
//                self.verifynumber2API(number: number!.phoneNumber, code: number!.countryCode)
//            }) {
//
//            }
            
        }
    }
    func verifynumber2API(number : String, code : String ){
        AccountInteractor.instance.checkRegistrationStatus(forNumber : number, countryCode: code) { (isRegistered, message) in
            if !isRegistered{
                self.strMobileNumber = number
                self.arrProfileValues = [self.strFirstName, self.strLastName, self.strEmailId, self.strMobileNumber, self.strAddress1, self.strAddress2, self.strCity, self.strPostalCode, self.strState]
                self.tblEditProfile.reloadData()
                self.makeTickButton()
            }else{
                self.appDelegate.createToastMessage(message)
            }
        }
    }
    // MARK: *** UITable View Delegate End ***

    @IBAction func gotoPhoneNoPage()
    {
        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "PhoneNoVC") as! PhoneNoVC
        propertyView.strDialCode = ""
        propertyView.isFromProfile = true
        self.navigationController?.pushViewController(propertyView, animated: true)
    }

    func setupShareAppViewAnimationWithView(_ view:UIView)
    {
        viewMediaHoder.isHidden = false
        view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                view.transform = CGAffineTransform.identity
                view.alpha = 1.0;
        },  completion: { (finished: Bool) -> Void in
        })
    }

    // MARK: - Navigating to Email field View
    /*
     */
    @IBAction func onAlertTapped(_ sender:UIButton!)
    {
        if sender.tag == 11
        {
            takePhoto()
        }
        else if sender.tag == 22
        {
            choosePhoto()
        }
        viewMediaHoder.isHidden = true
    }

    func takePhoto()
    {
        var autorize = Bool()
        if AVCaptureDevice.authorizationStatus(for: .video) ==  AVAuthorizationStatus.authorized {
            autorize = true
        } else  if AVCaptureDevice.authorizationStatus(for: .video) ==  AVAuthorizationStatus.notDetermined {
            autorize = true
        }
        else {
            AVCaptureDevice.requestAccess(for: .video) { granted -> Void in
                if granted{
                    
                    autorize = true
                }else{
                    
                    autorize = false
                }
            }
        }
        if autorize
        {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Device has no camera", comment: ""), preferredStyle:UIAlertController.Style.alert)
            settingsActionSheet.addAction(
                UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:{(action) in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.openURL(settingsUrl)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                })
            )
            present(settingsActionSheet, animated:true, completion:nil)
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
            let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please give permission to access photo.", comment: ""), preferredStyle:UIAlertController.Style.alert)
            settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:nil))
            present(settingsActionSheet, animated:true, completion:nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        let uploadImage : UIImage? =  info[.editedImage] as? UIImage ?? (info[.originalImage] as? UIImage)
        
        if let toImage = uploadImage {
            
            imgUserThumb.image = toImage
            self.uploadProfileImage(displayPic:uploadImage!)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ****** Uploading Proifle Picture Operation ******
    func uploadProfileImage(displayPic:UIImage)
    {
        
        var paramDict = JSON()
        guard let imageData = displayPic.jpegData(compressionQuality: 0.8) else {return}
//        guard let image_data = UIImage.jpegData(displayPic) else {return} //UIImageJPEGRepresentation(displayPic, 0.6) as! NSData
        //            UIImagePNGRepresentation(displayPic)! as NSData
        paramDict["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        WebServiceHandler.sharedInstance.uploadPost(wsMethod: API_UPLOAD_PROFILE_IMAGE,
                                                    paramDict: paramDict,
                                                    imgData: imageData ,
                                                    viewController: self,
                                                    isToShowProgress: true,
                                                    isToStopInteraction: true) { (responseDict) in
            if responseDict.isSuccess {
                if responseDict["image_url"] != nil
                {
                    self.strUserImgUrl = responseDict.string("image_url")
                    
                    self.makeTickButton()

                }
            }else {
                self.appDelegate.createToastMessage(NSLocalizedString("Upload failed. Please try again", comment: ""), bgColor: UIColor.black, textColor: UIColor.white)
                self.imgUserThumb?.sd_setImage(with: NSURL(string: self.strUserImgUrl)! as URL, placeholderImage:UIImage(named:""))
                self.appDelegate.createToastMessage(iApp.GoferError.upload.error, bgColor: UIColor.black, textColor: UIColor.white)
            }
        }
//        UberSupport().showProgress(viewCtrl: self, showAnimation: true)
//        let url = URL(string:String(format:"%@%@",iApp.APIBaseUrl,API_UPLOAD_PROFILE_IMAGE))
//        var request = URLRequest(url: url! as URL)
//        request.httpMethod = "POST"
//        let boundary = generateBoundaryString()
//        request.setValue("multipart/form-data; boundary=\(boundary)",
//            forHTTPHeaderField: "Content-Type")
//        let image_data:NSData = UIImageJPEGRepresentation(displayPic, 0.4)! as NSData
//        let body = NSMutableData()
//
//        let fname = String(format:"%@.jpg","driver")
//
//        // Append Logged-In User ID
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Disposition: form-data; name=\"token\"\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append(Constants().GETVALUE(keyname: USER_ACCESS_TOKEN).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
//        body.append("\r\n".data(using: String.Encoding.utf8)!)
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//        // Appnend Image Data
//        body.append("Content-Disposition:form-data; name=\"image\";filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Type: image/jpg\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Transfer-Encoding: binary\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append(image_data as Data)
//        body.append("\r\n".data(using: String.Encoding.utf8)!)
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//
//        request.httpBody = body as Data
//
//        let session = URLSession.shared
//
//        let task = session.dataTask(with: request as URLRequest) {
//            (data, response, error) in
//            guard let _:Data = data, let _:URLResponse = response , error
//                == nil else {
//                    DispatchQueue.main.async {
//                        self.imgUserThumb?.sd_setImage(with: NSURL(string: self.strUserImgUrl)! as URL, placeholderImage:UIImage(named:""))
//                        self.appDelegate.createToastMessage(iApp.GoferError.upload.error, bgColor: UIColor.black, textColor: UIColor.white)
//                        UberSupport().removeProgress(viewCtrl: self)
//                    }
//                    return
//            }
//
//            do
//            {
//                let jsonResult : Dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary as Dictionary
//                let items = jsonResult as NSDictionary
//                print(items)
//                DispatchQueue.main.async {
//                    if (items.count>0)
//                    {
//                        if items["image_url"] != nil
//                        {
        
//                            self.strUserImgUrl = items["image_url"] as? String ?? String()
//                            self.makeTickButton()
//                        }
//                    }
//                    else
//                    {
//                        self.appDelegate.createToastMessage(iApp.GoferError.upload.error, bgColor: UIColor.black, textColor: UIColor.white)
//                    }
//                    UberSupport().removeProgress(viewCtrl: self)
//                }
//            }
//            catch _ {
//                DispatchQueue.main.async {
//                    self.imgUserThumb?.sd_setImage(with: NSURL(string: self.strUserImgUrl)! as URL, placeholderImage:UIImage(named:""))
//                    UberSupport().removeProgress(viewCtrl: self)
//                    self.appDelegate.createToastMessage(iApp.GoferError.upload.error, bgColor: UIColor.black, textColor: UIColor.white)
//                }
//            }
//        }
//
//        task.resume()
    }
    
    func generateBoundaryString() -> String {
        
        return "Boundary-\(NSUUID().uuidString)"
    }
    // MARK: Profile image upload end

    // MARK: - TextField Delegate Method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if range.location == 0 && (string == " ") {
            return false
        }
        if (string == "") {
            return true
        }
        else if (string == " ") {
            return false
        }
        else if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
    {
        if textField.tag == 0   // FIRST NAME
        {
            tblEditProfile.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(80.0)), animated: true)
        }
        else if textField.tag == 1   // LAST NAME
        {
            tblEditProfile.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(80.0)), animated: true)
        }
        else if textField.tag == 2   // EMAIL ID
        {
            tblEditProfile.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(150.0)), animated: true)
        }
        else if textField.tag == 3   // MOBILE NUMBER
        {
            tblEditProfile.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(220.0)), animated: true)
        }
        else if textField.tag == 4   // ADDRESS LINE 1
        {
            tblEditProfile.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(270.0)), animated: true)
        }
        else if textField.tag == 5   // ADDRESS LINE 2
        {
            tblEditProfile.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(320.0)), animated: true)
        }
        else if textField.tag == 6   // CITY
        {
            tblEditProfile.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(370.0)), animated: true)
        }
        else if textField.tag == 7   // POSTAL CODE
        {
            tblEditProfile.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(420.0)), animated: true)
        }
        else if textField.tag == 8   // STATE
        {
            tblEditProfile.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(470.0)), animated: true)
        }

        return true
    }
    
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        textField.keyboardType = .asciiCapable
        print(textField.tag)
        var indexPath = IndexPath(row: (textField.tag == 1) ? 0 : (textField.tag == 3) ? 2 : textField.tag, section: (textField.tag > 3) ? 1 : 0)
        
        if (textField.tag == 0 || textField.tag == 1)
        {
            let selectedCell1 = tblEditProfile.cellForRow(at: indexPath) as! CellProfileItems
            
            if textField.tag == 0   // USER NAME
            {
                strFirstName = selectedCell1.txtFldValues.text!
            }
            else if textField.tag == 1   // USER NAME
            {
                strLastName = selectedCell1.txtFldValues1.text!
            }
            arrProfileValues = [strFirstName, strLastName, strEmailId, strMobileNumber, strAddress1, strAddress2, strCity, strPostalCode, strState]

            checkSaveButtonStatus()
            return
        }
        else
        {
            if (textField.tag > 3)
            {
                indexPath = IndexPath(row: textField.tag-4, section: 1)
            }
            else
            {
                let row = (textField.tag == 3) ? 2 : (textField.tag == 2) ? 1 : textField.tag
                indexPath = IndexPath(row: row, section: 0)
            }
            selectedCell = tblEditProfile.cellForRow(at: indexPath) as! CellEarnItems
        }
        
        if textField.tag == 2   // EMAIL ID
        {
            strEmailId = selectedCell.txtFldValues.text!
        }
        else if textField.tag == 3   // MOBILE NUMBER
        {
            strMobileNumber = selectedCell.txtFldValues.text!
        }
        else if textField.tag == 4   // ADDRESS LINE 1
        {
            strAddress1 = selectedCell.txtFldValues.text!
        }
        else if textField.tag == 5   // ADDRESS LINE 2
        {
            strAddress2 = selectedCell.txtFldValues.text!
        }
        else if textField.tag == 6   // CITY
        {
            strCity = selectedCell.txtFldValues.text!
        }
        else if textField.tag == 7   // POSTAL CODE
        {
            strPostalCode = selectedCell.txtFldValues.text!
        }
        else if textField.tag == 8   // STATE
        {
            strState = selectedCell.txtFldValues.text!
        }
        arrProfileValues = [strFirstName, strLastName, strEmailId, strMobileNumber, strAddress1, strAddress2, strCity, strPostalCode, strState]

        checkSaveButtonStatus()
    }
    
    func checkSaveButtonStatus()
    {
        if arrProfileValues == arrDummyValues
        {
            btnEdiIcon.isUserInteractionEnabled = false
            btnEdiIcon.setTitle("3", for: .normal)
            btnEdiIcon.titleLabel?.text = "3"
            btnEdiIcon.setTitleColor(UIColor.ThemeInactive, for: .normal)
        }
        else
        {
            btnEdiIcon.isUserInteractionEnabled = false
            btnEdiIcon.setTitle("3", for: .normal)
            btnEdiIcon.titleLabel?.text = "3"
            btnEdiIcon.setTitleColor(UIColor.ThemeInactive, for: .normal)
            makeTickButton()
        }
    }
    
    func makeTickButton()
    {
        btnEdiIcon.isUserInteractionEnabled = true
        btnEdiIcon.setTitle("3", for: .normal)
        btnEdiIcon.titleLabel?.text = "3"
        btnEdiIcon.setTitleColor(UIColor(red: 30.0 / 255.0, green: 186.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0), for: .normal)
    }
    
    //MARK - API CALL -> SAVE PROFILE INFORMATION
    /*
        UPDATING USER INFORMATION TO SERVER
     */
    func onSaveProfileTapped()
    {
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        var dicts = [String: Any]()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["first_name"] = arrProfileValues[0]
        dicts["last_name"] = arrProfileValues[1]
        dicts["email_id"] = arrProfileValues[2]
        dicts["mobile_number"] = arrProfileValues[3]
        dicts["address_line1"] = arrProfileValues[4]
        dicts["address_line2"] = arrProfileValues[5]
        dicts["city"] = arrProfileValues[6]
        dicts["postal_code"] = arrProfileValues[7]
        dicts["state"] = arrProfileValues[8]
        dicts["profile_image"] = strUserImgUrl
        UberAPICalls().PostRequest(dicts,methodName: METHOD_UPDATE_PROFILE_INFO as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let proModel = response as! GeneralModel
            OperationQueue.main.addOperation
                {
                    if proModel.status_code == "1"
                    {
                        self.updateProfileModel()
                    }
                    else
                    {
                        if proModel.status_message == "user_not_found" || proModel.status_message == "token_invalid" || proModel.status_message == "Invalid credentials" || proModel.status_message == "Authentication Failed"
                        {
                            self.appDelegate.logOutDidFinish()
                            return
                        }
                        else{
                            
                             self.appDelegate.createToastMessage(proModel.status_message, bgColor: UIColor.black, textColor: UIColor.white)
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
    
    // UPDATE PROFILE INFO SUCCESS
    func updateProfileModel()
    {
        profileModel.user_name = String(format:"%@ %@", arrProfileValues[0],arrProfileValues[1])
        profileModel.first_name = arrProfileValues[0]
        profileModel.last_name = arrProfileValues[1]
        profileModel.email_id = arrProfileValues[2]
        profileModel.mobile_number = arrProfileValues[3]
        profileModel.address_line1 = arrProfileValues[4]
        profileModel.address_line2 = arrProfileValues[5]
        profileModel.city = arrProfileValues[6]
        profileModel.postal_code = arrProfileValues[7]
        profileModel.state = arrProfileValues[8]
        profileModel.user_thumb_image = strUserImgUrl
//        Constants().STOREVALUE(value: strUserImgUrl, keyname: USER_IMAGE_THUMB)
//        Constants().STOREVALUE(value: profileModel.user_name, keyname: USER_FULL_NAME)
//        Constants().STOREVALUE(value: profileModel.email_id, keyname: USER_EMAIL_ID)
//        Constants().STOREVALUE(value: profileModel.mobile_number, keyname: USER_PHONE_NUMBER)
        delegate?.setprofileInfo(proModel: profileModel)
        strUserImgUrl = ""
        self.onBackTapped(nil)
        
    }

}

class CellProfileItems: UITableViewCell
{
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var txtFldValues: UITextField!
    
    @IBOutlet var lblTitle1: UILabel!
    @IBOutlet var txtFldValues1: UITextField!

}
extension EditProfileVC : MobileNumberValiadationProtocol{
    func verified(number: MobileNumber) {
        
        self.strMobileNumber = number.number
        self.arrProfileValues = [self.strFirstName, self.strLastName, self.strEmailId, self.strMobileNumber, self.strAddress1, self.strAddress2, self.strCity, self.strPostalCode, self.strState]
        self.tblEditProfile.reloadData()
        self.makeTickButton()
    }
    
    
}

