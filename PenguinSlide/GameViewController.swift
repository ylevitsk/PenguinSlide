//
//  GameViewController.swift
//  PenguinSlide
//
//  Created by Moe Wilson on 4/28/15.
//  Copyright (c) 2015 Yuliya Levitskaya. All rights reserved.
//

import UIKit
import SceneKit
import FBSDKLoginKit
import FBSDKCoreKit
import GameKit

class GameViewController: UIViewController, SCNSceneRendererDelegate,FBSDKLoginButtonDelegate, GKGameCenterControllerDelegate {

    
   // @IBOutlet var sceneView: SCNView! = SCNView()
    @IBOutlet var overlayView: UIView!
    @IBOutlet var startButton : UIButton!
    @IBOutlet var leaderboardButton : UIButton!
    @IBOutlet var instrButton : UIButton!
    @IBOutlet var highScoreButton : UIButton!
    
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    var gameCenterEnabled = Bool()
    var leaderboardIdentifier: NSString!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 242.0/255.0, green: 190.0/255.0, blue: 99.0/255.0, alpha: 1)
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
        }
        else
        {
            self.view.addSubview(loginView)
            loginView.center = CGPointMake(self.view.frame.width * 3 / 4, self.view.frame.height - 30)
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
        authenticateLocalPlayer()
    }
    func authenticateLocalPlayer() {
        var localPlayer = GKLocalPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
            if viewController != nil {
                self.presentViewController(viewController, animated: true, completion: nil)
            } else if localPlayer.authenticated {
                    self.gameCenterEnabled = true
    
                    localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier : String!, error : NSError!) -> Void in
                        if error != nil {
                            println(error.localizedDescription)
                        } else {
                            println(leaderboardIdentifier)
                            self.leaderboardIdentifier = leaderboardIdentifier
                        }
                    })
    
                } else {
                    self.gameCenterEnabled = false
                }
        }
    }
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
           /* if result.grantedPermissions.contains("email")
            {
                // Do work
            }*/
        }
    }
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                println("Error: \(error)")
            }
            else
            {
                println("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as NSString
                println("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as NSString
                println("User Email is: \(userEmail)")
            }
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    @IBAction func leaderboardTapped(sender : AnyObject){
        var gcVC:GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.Leaderboards
        gcVC.leaderboardIdentifier = "LeaderboardID"
        self.presentViewController(gcVC, animated: true, completion: nil)
   }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    override func shouldAutorotate() -> Bool{
        return false
    }

}
