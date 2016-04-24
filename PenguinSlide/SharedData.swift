//
//  ShareData.swift
//  GradebookExample
//
//  Created by Moe Wilson on 5/11/15.
//  Copyright (c) 2015 John Bellardo. All rights reserved.
//

import Foundation


class SharedData {
    class var sharedInstance: SharedData {
        struct Static {
            static var instance: SharedData?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SharedData()
        }
        
        return Static.instance!
    }
    
    var username: String! //Some String
}


