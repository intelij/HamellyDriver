//
//  PayoutBankDetailViewController.swift
//  GoferDriver
//
//  Created by trioangle on 18/05/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import UIKit

protocol BankDetailsProtocolo {
    func getBankDetails()
}

class PayoutBankDetailViewController: UIViewController,UITextFieldDelegate,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum) {
        delegate?.getBankDetails()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: false)
    }
    
    func onFailure(error: String) {
        appDelegate.createToastMessage(error)
    }
    

    
    @IBOutlet weak var submitButtonOutlet: UIButton!
    @IBOutlet weak var accountHolderView: UIView!
    @IBOutlet weak var holderLabel: UILabel!
    @IBOutlet weak var holderTextField: UITextField!
    @IBOutlet weak var holderLineLabel: UILabel!
    
    @IBOutlet weak var accountNumberView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var numberLineLabel: UILabel!

    @IBOutlet weak var bankNameView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLineLabel: UILabel!
    
    @IBOutlet weak var bankLocationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationLineLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var bankCodeView: UIView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var codeLineLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var childView: UIView!
    
    fileprivate let underLineColor = UIColor.blue
    var paramDict = [String:Any]()
    var selectedIndexPath:IndexPath!
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var delegate:BankDetailsProtocolo?
    var bankDetails = BankDetails()
    override func viewDidLoad() {

        super.viewDidLoad()
        apiInteractor = APIInteractor(self)
        self.initDataSource()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
   class func initWithStory() -> PayoutBankDetailViewController {
        let stroy = UIStoryboard(name: STORY_PAYMENT, bundle: nil).instantiateViewController(withIdentifier: "PayoutBankDetailViewController") as! PayoutBankDetailViewController
        return stroy
    }
    
    
    
    func initDataSource() {
        self.addkeyBoardObserverLocal()
        submitButtonOutlet.setTitle("Submit".localize, for: .normal)
//        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        
//        let accountHolderName = BankDetails(title: "Account Holder Name", placeHolder: "Account Holder Name")
        holderLabel.text = "Account Holder Name".localize
        holderTextField.placeholder = "Account Holder Name".localize
        holderLineLabel.backgroundColor = .lightGray
    
       
        numberLabel.text = "Account Number".localize
        numberTextField.placeholder = "Account Number".localize
        numberLineLabel.backgroundColor = .lightGray
       
        
        nameLabel.text = "Bank Name".localize
        nameTextField.placeholder = "Name of Bank".localize
        nameLineLabel.backgroundColor = .lightGray
        
    
        locationLabel.text = "Bank Location".localize
        locationTextField.placeholder = "Bank Location".localize
        locationLineLabel.backgroundColor = .lightGray
        
       
        codeLabel.text = "BIC/SWIFT Code".localize
        codeTextField.placeholder = "BIC/SWIFT Code".localize
        codeLineLabel.backgroundColor = .lightGray
       
//        numberTextField.keyboardType = .numberPad
        holderTextField.delegate = self
        numberTextField.delegate = self
        nameTextField.delegate = self
        locationTextField.delegate = self
        codeTextField.delegate = self
        
        holderTextField.text = bankDetails.holder_name
        numberTextField.text = bankDetails.account_number
        nameTextField.text = bankDetails.bank_name
        locationTextField.text = bankDetails.bank_location
        codeTextField.text = bankDetails.code
        
            paramDict[BankParams.account_number.rawValue] = bankDetails.account_number
       
            paramDict[BankParams.account_holder_name.rawValue] = bankDetails.holder_name
      
            paramDict[BankParams.bank_name.rawValue] = bankDetails.bank_name
       
            paramDict[BankParams.bank_location.rawValue] = bankDetails.bank_location
      
            paramDict[BankParams.bank_code.rawValue] = bankDetails.code
        submitButtonOutlet.isClippedCorner = true
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.changeColor(textField: textField, isColorChange: true)
        return true
    }
    
    func changeColor(textField:UITextField,isColorChange:Bool) {
        numberLineLabel.defaultColor()
        holderLineLabel.defaultColor()
        codeLineLabel.defaultColor()
        locationLineLabel.defaultColor()
        nameLineLabel.defaultColor()
        if isColorChange {
            if textField == numberTextField {
                numberLineLabel.changeColor()
            }
            if textField == holderTextField {
                holderLineLabel.changeColor()
            }
            if textField == nameTextField {
                nameLineLabel.changeColor()
            }
            if textField == locationTextField {
                locationLineLabel.changeColor()
            }
            if textField == codeTextField {
                codeLineLabel.changeColor()
            }
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == numberTextField {
            paramDict[BankParams.account_number.rawValue] = textField.text! + string
        }
        if textField == holderTextField {
            paramDict[BankParams.account_holder_name.rawValue] = textField.text! + string
        }
        if textField == nameTextField {
            paramDict[BankParams.bank_name.rawValue] = textField.text! + string
        }
        if textField == locationTextField {
            paramDict[BankParams.bank_location.rawValue] = textField.text! + string
        }
        if textField == codeTextField {
            paramDict[BankParams.bank_code.rawValue] = textField.text! + string
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.changeColor(textField: textField, isColorChange: false)
        textField.resignFirstResponder()
        return true
    }
    
    func addkeyBoardObserverLocal()
    {
        NotificationCenter.default.addObserver( self, selector: #selector(self.handleKeyboard(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(self.handleKeyboard(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //handle keyboard height dynamically
    @objc func handleKeyboard( note:NSNotification )
    {
        // read the CGRect from the notification (if any)
        if let keyboardFrame = (note.userInfo?[ UIResponder.keyboardFrameEndUserInfoKey ] as? NSValue)?.cgRectValue {
            if self.scrollView.contentInset.bottom == 0  {
                let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
                self.scrollView.contentInset = edgeInsets
                self.scrollView.scrollIndicatorInsets = edgeInsets
            }
            else {
                let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self.childView.frame.origin.y = 0
                self.scrollView.contentInset = edgeInsets
                self.scrollView.scrollIndicatorInsets = edgeInsets
            }
        }
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        
        guard [self.checkParam(param: .account_number),
               self.checkParam(param: .account_holder_name),
               self.checkParam(param: .bank_name),
               self.checkParam(param: .bank_location),
               self.checkParam(param: .bank_code)].allSatisfy({$0}) else {
            return
        }
        
//        else if self.checkParam(param: .account_holder_name) {
//
//        }
//        else if !self.checkParam(param: .bank_name) {
//
//        }
//        else if "\(paramDict[BankParams.bank_location.rawValue] ?? "")".count == 0{
//            self.checkParam(param: .bank_location)
//        }
//        else if "\(paramDict[BankParams.bank_code.rawValue] ?? "")".count == 0 {
//            self.checkParam(param: .bank_code)
//        }
        
        self.apiInteractor?.getResponse(forAPI: APIEnums.driver_bank_details, params: paramDict).shouldLoad(true)
       
        
    }
    
    func checkParam(param:BankParams) -> Bool {
        guard let value = paramDict[param.rawValue] as? String,value.count > 1 else{
            self.presentAlertWithTitle(title: "\(param.rawValue.replacingOccurrences(of: "_", with: " ").capitalized.localize)" + " " + "required".localize, message: "", options: "ok".localize) { (finished) in
            }
            return false
        }
        return true
//        if "\(paramDict[param.rawValue] ?? "")".count == 0 || "\(paramDict[param.rawValue] ?? "")".count == 1  {
//            
//            return false
//        } else {
//            return true
//        }
        
        
    }
    
    
    @IBAction func onBackButton(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}




enum BankParams:String {
    case account_holder_name
    case account_number
    case bank_name
    case bank_location
    case bank_code
}

extension UILabel {
    func defaultColor() {
        self.backgroundColor = .lightGray
    }
    func changeColor() {
        self.backgroundColor = UIColor.ThemeLight
    }
}
