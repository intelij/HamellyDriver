//
//  iTunesConfig.swift
//  GoferDriver
//
//  Created by trioangle on 25/05/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation

protocol iTunesData {
    var appName : String{get}
    var appStoreDisplayName : String{get}
    var appID : String{get}
    var appStoreLink : URL?{get}
}
extension iTunesData{
    var appStoreLink : URL?{
        return URL(string: "https://itunes.apple.com/us/app/\(appStoreDisplayName)/\(appID)?mt=8")
        
    }
}
