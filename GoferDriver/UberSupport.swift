/**
* UberSupport.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit

class UberSupport: NSObject {
    var userDefaults = UserDefaults.standard
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: SET DOT LOADER GIF
    func setDotLoader(animatedLoader:FLAnimatedImageView)
    {
        if let path =  Bundle.main.path(forResource: "dot_loading", ofType: "gif")
        {
            if let data = NSData(contentsOfFile: path) {
                let gif = FLAnimatedImage(animatedGIFData: data as Data?)
                animatedLoader.animatedImage = gif
            }
        }
    }
    //MARK: Check the Status Bar style
    func changeStatusBarStyle(style: UIStatusBarStyle)
    {
//        UIApplication.shared.statusBarStyle = style
//        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
//        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
//            statusBar.backgroundColor = UIColor.clear
//        }
    }
    
    //MARK: check the email validation
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //MARK: check the validated a zipcode
    func validateZipCode(strZipCode:String) -> Bool
    {
        let postcodeRegex: String = "^[0-9]{6}$"
        let postcodeValidate : NSPredicate = NSPredicate(format: "SELF MATCHES %@", postcodeRegex)
        if postcodeValidate.evaluate(with: strZipCode) == true {
            return true
        }
        else {
            return false
        }
    }
    
    func onGetStringWidth(_ width:CGFloat, strContent:NSString, font:UIFont) -> CGFloat
    {
        let textSize: CGSize = strContent.size(withAttributes: [NSAttributedString.Key.font : font])
        return textSize.width
    }

    //MARK: check the notwork status
    func isNetworkRechable(_ viewctrl : UIViewController) -> Bool
    {
        if !YSSupport.isNetworkRechable()
        {
            return false
        }
        else
        {
            return true
        }
    }
    // MARK: Check net work issue
    func checkNetworkIssue(_ viewctrl : UIViewController, errorMsg: String) -> Bool
    {
        if !YSSupport.isNetworkRechable()
        {
            return false
        }
        else if errorMsg.count > 0
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    //MARK: Check Param Type
    func checkParamTypes(params:NSDictionary, keys:NSString) -> String
    {
        if let latestValue = params[keys] as? NSString {
            return latestValue as String
        }
        else if let latestValue = params[keys] as? String {
            return latestValue as String
        }
        else if let latestValue = params[keys] as? Int {
            return String(format:"%d",latestValue) as String
        }
        else if (params[keys] as? NSNull) != nil {
            return ""
        }
        else
        {
            return ""
        }
    }
    
    //MARK: Show the progress view
    func showProgress(viewCtrl:UIViewController , showAnimation:Bool)
    {
        let viewProgress = UIStoryboard(name: STORY_MAIN, bundle: nil).instantiateViewController(withIdentifier: "ProgressHud") as! ProgressHud
        viewProgress.isShowLoaderAnimaiton = showAnimation
        viewProgress.view.tag = Int(123456)
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.window?.isUserInteractionEnabled = true
        viewCtrl.view.addSubview(viewProgress.view)
    }
 //MARK: Remove the progress view
    func removeProgress(viewCtrl:UIViewController)
    {
        viewCtrl.view.viewWithTag(Int(123456))?.removeFromSuperview()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.window?.isUserInteractionEnabled = true
    }
    
//MARK: Show the progress Window
    func showProgressInWindow(viewCtrl:UIViewController = UIViewController() , showAnimation:Bool)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewProgress = UIStoryboard(name: STORY_MAIN, bundle: nil).instantiateViewController(withIdentifier: "ProgressHud") as! ProgressHud
        viewProgress.isShowLoaderAnimaiton = showAnimation
        viewProgress.view.tag = Int(123456)
        appDelegate.window?.isUserInteractionEnabled = true
        appDelegate.window?.addSubview(viewProgress.view)
    }
    
//MARK: Remove the progress Window
    func removeProgressInWindow(viewCtrl:UIViewController = UIViewController())
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.viewWithTag(Int(123456))?.removeFromSuperview()
        appDelegate.window?.isUserInteractionEnabled = true
    }
    
//MARK: set teh Animation
    func runSpinAnimation(view: UIView, duration: CGFloat, rotations: CGFloat, repeatcounts : Float) {
        var rotationAnimation: CABasicAnimation?
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotationAnimation!.toValue = Int(.pi * 2.0 * rotations * duration)
        rotationAnimation!.duration = CFTimeInterval(duration)
        rotationAnimation!.isCumulative = true
        rotationAnimation!.repeatCount = repeatcounts
        view.layer.add(rotationAnimation!, forKey: "rotationAnimation")
    }
    //MARK: Make the Animation View
    func makeViewAnimaiton(viewObj:UIView) {
        UIView.animate(withDuration: 0.5, delay: 0.25, options: UIView.AnimationOptions(), animations: { () -> Void in
            viewObj.frame = CGRect(x: 0, y: viewObj.frame.origin.y,width: viewObj.frame.size.width ,height: viewObj.frame.size.height)
        }, completion: { (finished: Bool) -> Void in
        })
    }
    // MARK: Check ithe device
    func isPad() -> Bool
    {
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch (deviceIdiom)
        {
        case .pad:
            return true
        case .phone:
            return false
        default:
            break
        }
        return false
    }
    
// MARK: get the screen size
    func getScreenSize() -> CGRect
    {
        let rect = UIScreen.main.bounds as CGRect
//        let orientation = UIApplication.shared.statusBarOrientation as UIInterfaceOrientation
        if UberSupport().isPad()
        {
//            if(orientation.isLandscape)
//            {
//                rect = CGRect(x: 0, y:0,width: 1024 ,height: 768)
//            }
//            else
//            {
//                rect = CGRect(x: 0, y:0,width: 768 ,height: 1024)
//            }
        }
        return rect
    }
    
// MARK: set the squared borderlayer in button
    func makeSquareBorderLayer(btnLayer:UIButton)
    {
        btnLayer.layer.borderColor = UIColor.darkGray.cgColor
        btnLayer.layer.borderWidth = 1.0
        btnLayer.layer.cornerRadius = 5
    }
    
// MARK: set the squared borderlayer in Label
    func makeSquareBorder(btnLayer:UIButton , color:UIColor , radius:CGFloat)
    {
        btnLayer.layer.borderColor = color.cgColor
        btnLayer.layer.borderWidth = 1.0
        btnLayer.layer.cornerRadius = radius
    }
    
// MARK: show the keyboard
    func keyboardWillShowOrHide(keyboarHeight: CGFloat , btnView : UIButton)
    {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            let rect = self.getScreenSize()
            btnView.frame.origin.y = (rect.size.height) - btnView.frame.size.height - keyboarHeight - 25
        })
    }
    
//MARK: Hide the keyboard
    func keyboardWillShowOrHideForView(keyboarHeight: CGFloat , btnView : UIView)
    {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            let rect = self.getScreenSize()
            btnView.frame.origin.y = (rect.size.height) - btnView.frame.size.height - keyboarHeight
        })
    }
    
//MARK: Set the String size
    
    func getAttributedString(originalText: NSString, arrtributeText: String) -> NSMutableAttributedString
    {
        let mainString: NSMutableAttributedString = NSMutableAttributedString(string: originalText as String)
        let range = originalText.range(of: arrtributeText)
        mainString.addAttribute(NSAttributedString.Key.font, value:  UIFont (name: iApp.GoferFont.light.font, size: 18)!, range: NSRange(location: range.location, length: arrtributeText.count))
        return mainString
    }
    
    func getBigAndNormalString(originalText : NSString ,normalText : NSString, attributeText : NSString , font : UIFont) -> NSMutableAttributedString
    {
        let mainString: NSMutableAttributedString = NSMutableAttributedString(string: originalText as String)
        let range = originalText.range(of: attributeText as String)
        mainString.addAttribute(NSAttributedString.Key.font, value:  UIFont (name: iApp.GoferFont.light.font, size: 18)!, range: NSRange(location: range.location, length: attributeText.length))
        return mainString
    }
    
//MARK: Set the attributed name
    func createAttributUserName(originalText: NSString,normalText: NSString,textColor: UIColor, boldText: NSString , fontSize : CGFloat)->NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: originalText as String, attributes: [NSAttributedString.Key.font:UIFont (name: iApp.GoferFont.light.font, size: fontSize)!])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: NSMakeRange(2, originalText.length - 2))
        
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont (name: iApp.GoferFont.image.font, size: fontSize - 4)!]
        attributedString.addAttributes(boldFontAttribute, range: NSMakeRange(0, 1))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 235.0 / 255.0, green: 195.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0), range: NSMakeRange(0, 1))

        return attributedString
    }
    
//MARK: Set the attributed namestare
    func createAttributUserNameStar(originalText: NSString,normalText: NSString,textColor: UIColor, boldText: NSString , fontSize : CGFloat)->NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: originalText as String, attributes: [NSAttributedString.Key.font:UIFont (name: iApp.GoferFont.medium.font, size: fontSize)!])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: NSMakeRange(0, originalText.length - 1))
        
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont (name: iApp.GoferFont.image.font, size: fontSize - 4)!]
        attributedString.addAttributes(boldFontAttribute, range: NSMakeRange(originalText.length - 1, boldText.length))
        
        return attributedString
    }

//MARK: Set the attributed text color
    
    func makeAttributeTextColor(originalText : NSString ,normalText : NSString, attributeText : NSString , font : UIFont) -> NSMutableAttributedString
    {
        let attributedString = NSMutableAttributedString(string: originalText as String, attributes: [NSAttributedString.Key.font:font])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 41.0 / 255.0, green: 151.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0), range: NSMakeRange(normalText.length, attributeText.length))
        
        return attributedString
    }

//MARK: Set the hostattributed text color
    func makeHostAttributeTextColor(originalText : NSString ,normalText : NSString, attributeText : NSString , font : UIFont) -> NSMutableAttributedString
    {
        let attributedString = NSMutableAttributedString(string: originalText as String, attributes: [NSAttributedString.Key.font:font])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 255.0 / 255.0, green: 180.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0), range: originalText.range(of: attributeText as String))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(attributeText.length,normalText.length))

        return attributedString
    }
//MARK: Set rating color

    func createRatingStar(ratingValue : NSString) -> NSString
    {
        let rangeYours = ratingValue.range(of: ".")
        if rangeYours.location != NSNotFound
        {
            
        }
        if ratingValue == "0"
        {
            return "VVVVV"
        }
        let arrRating = ratingValue.components(separatedBy: ".")
        var strStar = ""
        if arrRating.count == 1
        {
            if arrRating[0] == "1"
            {
                strStar = "UVVVV"
            }
            else if arrRating[0] == "2"
            {
                strStar = "UUVVV"
            }
            else if arrRating[0] == "3"
            {
                strStar = "UUUVV"
            }
            else if arrRating[0] == "4"
            {
                strStar = "UUUUV"
            }
            else if arrRating[0] == "5"
            {
                strStar = "UUUUU"
            }
        }
        else
        {
            if ratingValue == "0.5"
            {
                strStar = "YVVVV"
            }
            else if ratingValue == "1.5"
            {
                strStar = "UYVVV"
            }
            else if ratingValue == "2.5"
            {
                strStar = "UUYVV"
            }
            else if ratingValue == "3.5"
            {
                strStar = "UUUYV"
            }
            else if ratingValue == "4.5"
            {
                strStar = "UUUUV"
            }
        }
        
        return strStar as NSString
    }

   //MERK: set attributed to  text
    func attributedText(originalText: NSString, boldText: String , fontSize : CGFloat)->NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: originalText as String, attributes: [NSAttributedString.Key.font:UIFont (name: iApp.GoferFont.light.font, size: fontSize)!])
        
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont (name: iApp.GoferFont.light.font, size: fontSize)!]
        
        attributedString.addAttributes(boldFontAttribute, range: originalText.range(of: boldText))
        
        return attributedString
    }
//MERK: attributed to converted text
    func attributedConversationText(originalText: NSString,normalText: NSString,textColor: UIColor, boldText: NSString , fontSize : CGFloat)->NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: originalText as String, attributes: [NSAttributedString.Key.font:UIFont (name: iApp.GoferFont.light.font, size: fontSize)!])
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont (name: iApp.GoferFont.light.font, size: fontSize - 4)!]
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor.withAlphaComponent(0.7), range: NSMakeRange(normalText.length+2, boldText.length))
        attributedString.addAttributes(boldFontAttribute, range: NSMakeRange(normalText.length+2, boldText.length))

        return attributedString
    }
//MARK: Set the attributed text bold
    func attributedTextboldText(originalText: NSString, boldText: String , fontSize : CGFloat)->NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: originalText as String, attributes: [NSAttributedString.Key.font:UIFont (name: iApp.GoferFont.light.font, size: fontSize-8)!])
        
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont (name: iApp.GoferFont.light.font, size: fontSize)!]
        
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: originalText.range(of: boldText))
        
        return attributedString
    }

//MARK: Set the GradientColor
    func makeGradientColor(gradientView:UIView)
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        let color1 = UIColor(red: 0.0 / 255.0, green: 163.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0).cgColor as CGColor
        let color2 = UIColor(red: 0.0 / 255.0, green: 124.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0).cgColor as CGColor
        let color3 = UIColor(red: 0.0 / 255.0, green: 124.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0).cgColor as CGColor
        let color4 = UIColor(red: 0.0 / 255.0, green: 124.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0).cgColor as CGColor
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 1.0]
        let radient = (0)/225.0 * .pi / 2
        gradientLayer.transform = CATransform3DMakeRotation(CGFloat(radient), 0, 0, 1)
        gradientView.layer.addSublayer(gradientLayer)
    }
//MARK: On get current color in textfield
    func onGetCurrentTextColor() -> UIColor
    {
        let textColor = userDefaults.integer(forKey: "textcolors")
        var color = UIColor()
        if(textColor==1111)
        {
            color = UIColor(red:(255/255.0), green:(255/255.0), blue:(255/255.0), alpha:1.00);
        }
        else if(textColor==2222)
        {
            color = UIColor(red:(0/255.0), green:(0/255.0), blue:(0/255.0), alpha:1.00);
        }
        return color
    }
//MARK: get the font style
    func onGetFontAndStyle()-> UIFont
    {
        return UIFont(name: onGetCurrentFontStyleName(), size: onGetCurrentTextSize())!
    }
//MERK: get the current text size
    func onGetCurrentTextSize() -> CGFloat
    {
        let textColor = userDefaults.float(forKey: "fontsize")
        return CGFloat(textColor)
    }
//MERK: get the current font style
    func onGetCurrentFontStyleName() -> String
    {
        let fontName = userDefaults.value(forKey: "fontname")
        return fontName as? String ?? String()
    }
//MERK: get the String hight
    func onGetStringHeight(_ width:CGFloat, strContent:NSString, font:UIFont) -> CGFloat
    {
        let sizeOfString = strContent.boundingRect( with: CGSize(width: width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes:[NSAttributedString.Key.font: font], context: nil).size
        return sizeOfString.height
    }    
    
// Return IP address of WiFi interface (en0) as a String, or `nil`
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    
// MARK: Convert Currency Code to Symbol
    func getSymbolForCurrencyCode(code: NSString) -> NSString?
    {
        let locale = NSLocale(localeIdentifier: code as String)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code) as NSString?
    }
    
}
extension UIScrollView {
    //addKeyboard Observer for keyboard show&hide
    func addkeyBoardObserver()
    {
        NotificationCenter.default.addObserver( self, selector: #selector(self.handleKeyboard(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(self.handleKeyboard(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //handle keyboard height dynamically
    @objc func handleKeyboard( note:NSNotification )
    {
        // read the CGRect from the notification (if any)
        if let keyboardFrame = (note.userInfo?[ UIResponder.keyboardFrameEndUserInfoKey ] as? NSValue)?.cgRectValue {
            if self.contentInset.bottom == 0 && keyboardFrame.height != 0 {
                let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
                self.contentInset = edgeInsets
                self.scrollIndicatorInsets = edgeInsets
            }
            else {
                let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self.contentInset = edgeInsets
                self.scrollIndicatorInsets = edgeInsets
            }
        }
    }
}
public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
    
}
extension UIViewController {
    func checkDevice()-> Bool {
        if UIDevice.modelName == "Simulator iPhone X" || UIDevice.modelName == "Simulator iPhone XS" || UIDevice.modelName == "Simulator iPhone XR" || UIDevice.modelName == "Simulator iPhone XS Max" || UIDevice.modelName == "iPhone X" || UIDevice.modelName == "iPhone XS" || UIDevice.modelName == "iPhone XR" || UIDevice.modelName == "iPhone XS Max" {
            return true
        }
        return false
    }
}
