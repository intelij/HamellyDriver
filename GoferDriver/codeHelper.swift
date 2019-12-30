//
//  codeHelper.swift
//  GoferDriver
//
//  Created by bowshul sheik rahaman on 20/12/18.
//  Copyright © 2018 Vignesh Palanivel. All rights reserved.
//

import Foundation
import CoreLocation


typealias JSON = [String: Any]
extension Dictionary where Dictionary == JSON{
    var status_code : Int{
        return self.int("status_code")
        //Int(self["status_code"] as? String ?? String()) ?? Int()
    }
    var isSuccess : Bool{
        return status_code != 0
    }
    var status_message : String{
        if let message =  self["status_message"] as? String, !message.isEmpty{
            return message
        }
        return "Error status " //  self["success_message"] as! String
    }

    func value<T>(forKeyPath path : String) -> T?{
        var keys = path.split(separator: ".")
        var childJSON = self
        let lastKey : String
        if let last = keys.last{
            lastKey = String(last)
        }else{
            lastKey = path
        }
        keys.removeLast()
        for key in keys{
            childJSON = childJSON.json(String(key))
        }
        return childJSON[lastKey] as? T
    }
    func array<T>(_ key : String) -> [T]{
        return self[key] as? [T] ?? [T]()
    }
    func array(_ key : String) -> [JSON]{
        return self[key] as? [JSON] ?? [JSON]()
    }
    func json(_ key : String) -> JSON{
        return self[key] as? JSON ?? JSON()
    }
    
     func string(_ key : String)-> String{
     // return self[key] as? String ?? String()
         let value = self[key]
         if let str = value as? String{
            return str
         }else if let int = value as? Int{
            return int.description
         }else if let double = value as? Double{
            return double.description
         }else{
            return String()
         }
     }
     func int(_ key : String)-> Int{
     //return self[key] as? Int ?? Int()
         let value = self[key]
         if let str = value as? String{
            return Int(str) ?? Int()
         }else if let int = value as? Int{
            return int
         }else if let double = value as? Double{
            return Int(double)
         }else{
            return Int()
         }
     }
     func double(_ key : String)-> Double{
         //return self[key] as? Double ?? Double()
         let value = self[key]
         if let str = value as? String{
            return Double(str) ?? Double()
         }else if let int = value as? Int{
            return Double(int)
         }else if let double = value as? Double{
            return double
         }else{
            return Double()
         }
     }
    func bool(_ key : String) -> Bool{
        let value = self[key]
        if let bool = value as? Bool{
            return bool
        }else if let int = value as? Int{
            return int == 1
        }else if let str = value as? String{
            return ["1","true"].contains(str)
        }else{
            return Bool()
        }
    }
    
}
extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension CLLocation{
    //MARK:::::::::::::::::::CLLocationValidator:::::::::::::::::::::::::::::::::
    var isValid : Bool{
        let age = -self.timestamp.timeIntervalSinceNow
        
        if age > 10{//"Locaiton is old."
            return false
        }
        
        if self.horizontalAccuracy < 0{//"Latitidue and longitude values are invalid."
            return false
        }
        
        if self.horizontalAccuracy > 100{//"Accuracy is too low."
            return false
        }
        
        //"Location quality is good enough."
        return true
        
    }
}
func isValidMail(mail : String) -> Bool{
    //let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
    return emailTest.evaluate(with: mail)
}
extension UIAlertController {
    
    func addColorInTitleAndMessage(titleColor:UIColor,messageColor:UIColor,titleFontSize:CGFloat = 18, messageFontSize:CGFloat = 13){
        
        let attributesTitle =  [NSAttributedString.Key.foregroundColor:titleColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: titleFontSize)]
        
        let attributesMessage = [NSAttributedString.Key.foregroundColor:messageColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: messageFontSize)]
        let attributedTitleText = NSAttributedString(string: self.title ?? "", attributes: attributesTitle)
        let attributedMessageText = NSAttributedString(string: self.message ?? "", attributes: attributesMessage)
        
        self.setValue(attributedTitleText, forKey: "attributedTitle")
        self.setValue(attributedMessageText, forKey: "attributedMessage")
        
    }
    
}
extension UIViewController {
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
//        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
//            statusBar.backgroundColor = style == .lightContent ? UIColor.ThemeMain : .white
//            statusBar.setValue(style == .lightContent ? UIColor.white : .ThemeMain, forKey: "foregroundColor")
//        }
    }
}
extension UIViewController{
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(index)
            }))
        }
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
            
        }else{
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
