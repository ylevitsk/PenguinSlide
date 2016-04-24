//
//  GamePlayViewController.swift
//  PenguinSlide
//
//  Created by Moe Wilson on 5/5/15.
//  Copyright (c) 2015 Yuliya Levitskaya. All rights reserved.
//

import AVFoundation
import UIKit
import SceneKit
import GameKit

class GamePlayViewController: UIViewController {
    var timer = NSTimer()
    var counter = 0
    var mySoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("music", ofType: "wav")!)
    var soundPlayer = AVAudioPlayer();
    
    var scnView:SCNView!
    @IBOutlet var countingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Quit", style: UIBarButtonItemStyle.Bordered, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton;
        countingLabel.text = String(counter)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "StopTimerNotication:", name:"StopTimerNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "AlertNotication:", name:"AlertNotification", object: nil)
        
        soundPlayer = AVAudioPlayer(contentsOfURL: mySoundURL , error: nil)
        soundPlayer.play();
        
        scnView = self.view as? SCNView
        let scene = PrimitivesScene()
        scnView.scene = scene
        scnView.allowsCameraControl = false
        


        
    }
    func back(sender: UIBarButtonItem) {
        //scnView.scene.p
        var alert = UIAlertController(title: "", message: "Are you sure you want to quit?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { action in
            switch action.style{
            case .Default:
                self.self.soundPlayer.stop()
                self.navigationController?.popToRootViewControllerAnimated(true)
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))

        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { action in
            switch action.style{
            case .Default:
            
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func StopTimerNotication(notification: NSNotification){ //Put stop timer code here.
        timer.invalidate()
        submitScore(counter - 1)
        saveScore(counter - 1)
        var alert = UIAlertController(title: "", message: "" + countingLabel.text!, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: { action in
            switch action.style{
            case .Default:
                self.counter = 0;
                self.countingLabel.text = String(self.counter)
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
                if let scnView = self.view as? SCNView{
                    let scene = PrimitivesScene()
                    scnView.scene = scene
                    scnView.allowsCameraControl = false
                }
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: "Main Menu", style: UIAlertActionStyle.Default, handler: { action in
            switch action.style{
            case .Default:
                self.navigationController?.popToRootViewControllerAnimated(true)
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func submitScore(score:Int) {
        var leaderboardID = "LeaderboardID"
        var sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(score)
        
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        GKScore.reportScores([sScore], withCompletionHandler: { (error: NSError!) -> Void in
            if error != nil {
                println(error.localizedDescription)
            } else {
                println("Score submitted")
                
            }
        })
    }
    func saveScore(score:Int){
        var firstScore = NSInteger()
        var secondScore = NSInteger()
        var thirdScore = NSInteger()
        var fourthScore = NSInteger()
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as NSString
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
        if let dict = myDict  {
            if(c>1){
                //loading values
                firstScore = dict.objectForKey("first") as Int
                secondScore = dict.objectForKey("second") as Int
                thirdScore = dict.objectForKey("third") as Int
                fourthScore = dict.objectForKey("fourth") as Int
            }
            
        } else {
            println("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
        if score < fourthScore || fourthScore == 0 {
            var dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
            //saving values
            if(score == firstScore || score == secondScore || score == thirdScore || score == fourthScore){
                dict.setObject(fourthScore as AnyObject, forKey: "fourth")
                dict.setObject(thirdScore as AnyObject, forKey: "third")
                dict.setObject(secondScore as AnyObject, forKey: "second")
                dict.setObject(firstScore as AnyObject, forKey: "first")
            }
            else if(score < firstScore || firstScore == 0){
                dict.setObject(thirdScore as AnyObject, forKey: "fourth")
                dict.setObject(secondScore as AnyObject, forKey: "third")
                dict.setObject(firstScore as AnyObject, forKey: "second")
                dict.setObject(score as AnyObject, forKey: "first")
            }
            else if(score < secondScore || secondScore == 0){
                dict.setObject(thirdScore as AnyObject, forKey: "fourth")
                dict.setObject(secondScore as AnyObject, forKey: "third")
                dict.setObject(score as AnyObject, forKey: "second")
                dict.setObject(firstScore as AnyObject, forKey: "first")
            }
            else if(score < thirdScore || thirdScore == 0){
                dict.setObject(thirdScore as AnyObject, forKey: "fourth")
                dict.setObject(score as AnyObject, forKey: "third")
                dict.setObject(secondScore as AnyObject, forKey: "second")
                dict.setObject(firstScore as AnyObject, forKey: "first")
            }
            else{
                dict.setObject(fourthScore as AnyObject, forKey: "fourth")
                dict.setObject(thirdScore as AnyObject, forKey: "third")
                dict.setObject(secondScore as AnyObject, forKey: "second")
                dict.setObject(firstScore as AnyObject, forKey: "first")
            }
            //...
            
            //writing to GameData.plist
            dict.writeToFile(path, atomically: false)
            
            let resultDictionary = NSMutableDictionary(contentsOfFile: path)
            println("Saved GameData.plist file is --> \(resultDictionary?.description)")
        }
    }
    func updateCounter() {
        countingLabel.text = String(counter++)
    }
    
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.PortraitUpsideDown ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
                return false;
        }
        else {
            return true;
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.LandscapeRight.rawValue) | Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue)
    }
}