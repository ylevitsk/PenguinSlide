//
//  HighScoresViewController.swift
//  PenguinSlide
//
//  Created by Moe Wilson on 6/2/15.
//  Copyright (c) 2015 Yuliya Levitskaya. All rights reserved.
//

import Foundation
import SpriteKit

class HighScoresViewController:UIViewController {
    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var thirdLabel: UILabel!
    @IBOutlet var fourthLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func loadData(){
        // getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as String
        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        
        let fileManager = NSFileManager.defaultManager()
        
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("GameData", ofType: "plist") {
                
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                println("Bundle GameData.plist file is --> \(resultDictionary?.description)")
                
                fileManager.copyItemAtPath(bundlePath, toPath: path, error: nil)
                println("copy")
            } else {
                println("GameData.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
            println("GameData.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        println("Loaded GameData.plist file is --> \(resultDictionary?.description)")
        
        var myDict = NSDictionary(contentsOfFile: path)
        let c = myDict?.count;
        if let dict = myDict {
            //loading values
            if(c>1){
                firstLabel.text = String(dict.objectForKey("first") as Int)
                secondLabel.text = String(dict.objectForKey("second") as Int)
                thirdLabel.text = String(dict.objectForKey("third") as Int)
                fourthLabel.text = String(dict.objectForKey("fourth") as Int)
            }
            //...
        } else {
            println("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
    }
}