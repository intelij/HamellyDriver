/**
* ProfileImageModel.swift
*
* @package UberDiver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/


import Foundation
import UIKit

class ProfileImageModel : NSObject {
    
    //MARK Properties
    var large_image_url : String = ""
    var normal_image_url : String = ""
    var small_image_url : String = ""

    //MARK: Inits
    func initiateProfileImageData(responseDict: NSDictionary) -> Any
    {
        large_image_url = UberSupport().checkParamTypes(params: responseDict, keys:"large_image_url") as String
        normal_image_url = UberSupport().checkParamTypes(params: responseDict, keys:"normal_image_url") as String
        small_image_url = UberSupport().checkParamTypes(params: responseDict, keys:"small_image_url") as String
        return self
    }
    
    
}
