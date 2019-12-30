/**
 * DocumentMainVC.swift
 *
 * @package GoferDriver
 * @author Trioangle Product Team
 * @version - Stable 1.0
 * @link http://trioangle.com
 */



import UIKit
import Foundation
import Alamofire

protocol DocumentUploadDelegate
{
    func enableVerifyButton(type:String,strDocUrls:String,count:String)
}

class DocumentDetailVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var imgCertificate: UIImageView!
    @IBOutlet var lblTitle: UITextView!
    @IBOutlet var lblChangePhoto: UILabel!
    @IBOutlet var lblMainTitle: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var viewChange: UIView!
    @IBOutlet var viewMediaHoder: UIView!
    @IBOutlet var btnCancel: UIButton!
    
    var delegate: DocumentUploadDelegate?
    
    
    var arrTitle = [String]()
    
    var strTitle = ""
    var nSelectedIndex = 0
    var isFromProfile : Bool = false
    var imagePicker = UIImagePickerController()
    var strDocType = ""
    var proImageModel : ProfileImageModel!
    var strCarType = ""
    var strCarId = ""
    var strCarName = ""
    var strCarNumber = ""
    var token = ""
    var strUserImgUrl = ""
    var strTotalCount = ""
    var strDocUrl = ""
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()       
        token = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        
        if appDelegate.language == "ja" {
            lblMainTitle.text = "Take a photo of your".localize
            lblTitle.text = "Motor Insurance Certificate".localize
            lblDescription.text = "Please make sure we can easily read all the details.".localize
            
        }
        
        arrTitle = [
            NSLocalizedString("Driver's License - (Back/Reverse)", comment: ""),NSLocalizedString("Driver's License - (Front)", comment: ""),NSLocalizedString("Motor Insurance Certificate", comment: ""),NSLocalizedString("Certificate of Registration", comment: ""),NSLocalizedString("Contract Carriage Permit", comment: "")]
        
//        UIApplication.shared.statusBarStyle = .default
        viewMediaHoder.isHidden = true
        imgCertificate.image = UIImage(named:(nSelectedIndex==0 || nSelectedIndex==1) ? "driveid.png" : "insurance.png")
        lblTitle.text = strTitle
        viewChange.isHidden = true
        if isFromProfile
        {
            viewChange.isHidden = false
            lblMainTitle.isHidden = true
            lblDescription.isHidden = true
        }
        if strDocUrl.count > 0
        {
            imgCertificate.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            imgCertificate.sd_setImage(with: NSURL(string: strDocUrl)! as URL, placeholderImage:UIImage(named:""))
            viewChange.isHidden = false
            lblMainTitle.isHidden = true
            lblDescription.isHidden = true
        }
        btnCancel.layer.borderColor = UIColor.black.cgColor
        btnCancel.layer.borderWidth = 1.0
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
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        UberSupport().changeStatusBarStyle(style: .default)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddPhotoTapped(_ sender:UIButton!)
    {
        setupShareAppViewAnimationWithView(viewMediaHoder)
    }
    
    
    // MARK: Navigating to Email field View
    /*
     */
    //  action sheect delegate methods
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
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let settingsActionSheet: UIAlertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Device has no camera", comment: ""), preferredStyle:UIAlertController.Style.alert)
            
            settingsActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:nil))
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
            let settingsActionSheet: UIAlertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please give permission to access photo.", comment: ""), preferredStyle:UIAlertController.Style.alert)
            settingsActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertAction.Style.cancel, handler:nil))
            present(settingsActionSheet, animated:true, completion:nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let pickedImage = info[.originalImage] as? UIImage
        self.photoSave(pickedImage!, type : strDocType)
        imgCertificate.image = pickedImage
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Uploading Proifle Picture Operation
    func photoSave(_ photoImage : UIImage, type : String)
    {
//        UberSupport().showProgress(viewCtrl: self, showAnimation: true)
        let urlString = iApp.APIBaseUrl + "document-upload"
        let imageUpload = photoImage.jpegData(compressionQuality: 1.0)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            let date = Date().timeIntervalSince1970 * 1000
            let fileName = String(date) + "Image.jpg"
            
            multipartFormData.append(imageUpload!, withName: "image", fileName: fileName, mimeType: "image/jpg")
            multipartFormData.append((self.token.data(using: String.Encoding.utf8, allowLossyConversion: false)!), withName: "token")
            multipartFormData.append((type.data(using: String.Encoding.utf8, allowLossyConversion: false))!, withName: "document_type")
            
        }, to: urlString, method: .post, encodingCompletion: { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    
                    print("response : ", response)
                    
                    if response.result.isSuccess
                    {
                        let result : AnyObject = response.result.value as AnyObject
                        if result["status_code"] as? String == "1"{
                            
                            if result["document-url"] != nil
                            {
                                self.viewChange.isHidden = false
                                self.strUserImgUrl = result["document-url"] as? String ?? String()
                            }
                            if result["driver_document_count"] != nil
                            {
                                self.strTotalCount = UberSupport().checkParamTypes(params: result as! NSDictionary, keys:"driver_document_count") as String
                            }
                            self.delegate?.enableVerifyButton(type:self.strDocType,strDocUrls:self.strUserImgUrl,count:self.strTotalCount)
                            
                        }
                        else{
                            let msg = result["status_message"] as? String
                            self.appDelegate.createToastMessage(msg!, bgColor: UIColor.black, textColor: UIColor.white)
                        }
                        UberSupport().removeProgress(viewCtrl: self)
                    }
                    else
                    {
                        DispatchQueue.main.async
                            {
                                let alert = UIAlertController(title: "Network Connection Lost", message: "Please try again", preferredStyle: .alert)
                                let ok = UIAlertAction(title: "OK", style: .cancel, handler: { Void in
                                    UberSupport().removeProgress(viewCtrl: self)
                                })
                                alert.addAction(ok)
                                self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                UberSupport().removeProgress(viewCtrl: self)
            }
        })
    }
    
    
}



//MARK: MainStory board to use localize concept
extension UILabel{
    @IBInspectable
    var localize : Bool{
        get{
            return false
        }
        set{
            if newValue{
             self.text = self.text?.localize
            }
        }
    }
}

extension UITextField {
    @IBInspectable
    var localizePlaceHolder: Bool {
        get {
            return false
        }
        set {
            if newValue {
                self.placeholder = self.placeholder?.localize
            }
        }
    }
}

extension UIButton {
    @IBInspectable
    var localizeTitle: Bool {
        get {
            return false
        }
        set {
            if newValue {
                self.setTitle(self.currentTitle?.localize, for: .normal)
            }
        }
    }
}

extension UITextView {
    @IBInspectable
    var localizeText: Bool {
        get {
            return false
        }
        set {
            if newValue {
                self.text = self.text.localize
            }
        }
    }
}

