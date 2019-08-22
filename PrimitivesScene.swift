//
//  PrimitivesScene.swift
//  PenguinSlide
//
//  Created by Moe Wilson on 4/28/15.
//  Copyright (c) 2015 Yuliya Levitskaya. All rights reserved.
//
import AVFoundation
import UIKit
import SceneKit
import SpriteKit
import CoreMotion


class PrimitivesScene: SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    let motionQueue = NSOperationQueue();
    let motionManager = CMMotionManager();
    let gravity = UIGravityBehavior();
    var cameraNode : SCNNode!
    var playerNode: SCNNode!
    var particlesNode:SCNNode!
    var skyNode: SCNNode!
    var treeNode:SCNNode!
    var snowmenNode:SCNNode!
    var floorNode : SCNNode!
    var move: SCNAction!
    
    var mySoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("rocket", ofType: "wav")!)
    var soundPlayer = AVAudioPlayer();
        
    var mySoundURL3 = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("swoosh", ofType: "wav")!)
    var soundPlayer3 = AVAudioPlayer();
    
    var mapNode: SCNNode!
    var finish: SCNNode!
    var map:Map!
    let playerCategory: Int = 1 << 4
    let treeCategory: Int = 1 << 5
    let finishCategory: Int = 1 << 6
    let floorCategory: Int = 1 << 7
    let snowmanCategory: Int = 1 << 8
    
    override init() {
        super.init()
        initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initialize(){
        map = Map(image: UIImage(named: "treemap")!)
        //player
        /*let playerGeom = SCNSphere(radius:1.0)
        playerGeom.firstMaterial?.diffuse.contents = UIColor.redColor()
        let playerNode = SCNNode()
        playerNode.geometry = playerGeom
        playerNode.position = SCNVector3(x: 0, y: 1, z: -5)
        self.rootNode.addChildNode(playerNode)*/
        
        var sky = SCNBox(width: CGFloat(map.width), height: CGFloat(map.height)/3, length: 0.50, chamferRadius: 0.0)
        skyNode = SCNNode(geometry: sky);
        skyNode.position = SCNVector3(x: Float(map.width/2), y: 1, z: 2480)
        skyNode.physicsBody?.velocityFactor = SCNVector3Zero
        self.rootNode.addChildNode(skyNode)
    
        self.physicsWorld.contactDelegate = self
        //self.physicsWorld.gravity = SCNVector3Zero
        
        
        //sound
        // Load
        soundPlayer = AVAudioPlayer(contentsOfURL: mySoundURL , error: nil)
        soundPlayer3 = AVAudioPlayer(contentsOfURL: mySoundURL3 , error: nil)
        
        //add entities
        for entity in map.entities {
            switch entity.type {
            case .Player:
                playerNode = SCNNode()
                let playerScene = SCNScene(named: "PenguinTurning.dae")
                var playerNodeArray = playerScene!.rootNode.childNodes
                
                let playerMaterial = SCNMaterial();
                playerMaterial.litPerPixel = false
                playerMaterial.diffuse.contents = UIImage(named:"penguin.bmp")
                playerMaterial.specular.contents = UIImage(named:"penguin.bmp")
                playerMaterial.diffuse.wrapS = SCNWrapMode.Repeat
                playerMaterial.diffuse.wrapT = SCNWrapMode.Repeat
                
                playerNodeArray[0].geometry??.materials = [playerMaterial]
                playerNodeArray[2].geometry??.materials = [playerMaterial]
                
                playerNode.addChildNode(playerNodeArray[0] as SCNNode);
                playerNode.addChildNode(playerNodeArray[2] as SCNNode);
                
                //playerNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(-M_PI_2))
                //playerNode.position = SCNVector3(x: 0, y: 0.75, z: -3)
                playerNode.scale = SCNVector3Make(0.85, 0.85, 0.85)
                playerNode.position = SCNVector3(x: entity.x, y: 0.5, z: entity.y)
                playerNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(node: playerNode, options: nil))
                playerNode.physicsBody?.mass = 0
                playerNode.physicsBody?.categoryBitMask = playerCategory
                playerNode.physicsBody?.collisionBitMask = finishCategory | treeCategory | snowmanCategory
               self.rootNode.addChildNode(playerNode)
                break;
            case .Finish:
                var rec = SCNBox(width: CGFloat(map.width * 2), height: 1.0, length: 1.0, chamferRadius: 1.0)
                finish = SCNNode(geometry: rec)
                let boxMatrial = SCNMaterial();
                boxMatrial.diffuse.contents = UIColor.redColor()
                rec.materials = [boxMatrial]
                
                finish.position = SCNVector3(x: Float(map.width), y: 2, z: 1700) //z: 2500)// )
                
                finish.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: rec, options: nil))
                finish.physicsBody?.velocityFactor = SCNVector3Zero
                
                finish.physicsBody?.categoryBitMask = finishCategory
                //finish.physicsBody?.collisionBitMask = playerCategory
            
                self.rootNode.addChildNode(finish)
                break;
            default:
                break;
            }
        }
        
        //camera
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        //cameraNode.camera?.xFov = 50
        //cameraNode.camera?.yFov = 50
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 100.0
        //cameraNode.camera?.zFar = Double(max(map.width, map.height))
        cameraNode.position = SCNVector3(x: 0, y: 3.5, z:10)
        playerNode.addChildNode(cameraNode)
        
        mapNode = SCNNode()
        
        //ground
        setupFloor()
        //add floor
        let floorNode = SCNNode()
        let floorMaterial = SCNMaterial()
        floorMaterial.litPerPixel = false
        floorMaterial.diffuse.contents = UIImage(named:"snow.bmp")
        floorMaterial.diffuse.wrapS = SCNWrapMode.Repeat
        floorMaterial.diffuse.wrapT = SCNWrapMode.Repeat
        
        floorNode.geometry?.materials = [floorMaterial]
        floorNode.geometry = SCNPlane(width: CGFloat(map.width), height: CGFloat(map.height))
        floorNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(-M_PI_2))
        floorNode.position = SCNVector3(x: Float(map.width)/2, y: 0.5, z: Float(map.height)/2)
        floorNode.physicsBody?.categoryBitMask = floorCategory
        floorNode.physicsBody?.collisionBitMask = floorCategory
        mapNode.addChildNode(floorNode)
        //self.rootNode.addChildNode(mapNode)
        self.motionManager.deviceMotionUpdateInterval = 5.0/60.0
        
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrameXArbitraryZVertical, toQueue: self.motionQueue) { (motion, error) -> Void in
            let x = motion.gravity.x
            let y = motion.gravity.y
            let z = motion.gravity.z
            
            self.playerNode.position.x += Float(y) //self.cameraNode.position.x
            self.skyNode.position.x  += Float(y)
           // self.finish.position.x  += Float(y)
            
            if(self.playerNode.position.x >= Float(self.map.width)){
                self.playerNode.position.x = Float(self.map.width)
                self.skyNode.position.x  = Float(self.map.width)
             //   self.finish.position.x  = Float(self.map.width)
            }
            else if(self.playerNode.position.x <= 0){
                self.playerNode.position.x = 0
                self.skyNode.position.x  = 0
               // self.finish.position.x  = 0
            }
            
        }

        //fog
        self.fogColor = UIColor.grayColor()
        self.fogDensityExponent = 0.8
        self.fogStartDistance = CGFloat(30)
        self.fogEndDistance = CGFloat(100)
        
        //snow
        let particles = SCNParticleSystem(named: "MyParticleSystem.scnp", inDirectory: "")
        particles.affectedByPhysicsFields =  false
        particles.birthRate = 5000
        particlesNode = SCNNode()
        particlesNode.addParticleSystem(particles)
        particlesNode.position = SCNVector3Make(0, 4, -25)
        particlesNode.physicsBody?.applyForce(SCNVector3Make(0, 9.8, 0), impulse: false)
        playerNode.addChildNode(particlesNode)
        
  
        //Sliding
        move = SCNAction.repeatActionForever(SCNAction.moveBy(SCNVector3(x: 0, y: 0, z: -10.8), duration: 1))
        playerNode.runAction(move, forKey: "movePlayer")
        skyNode.runAction(move, forKey: "moveSky")
    
        //Spawn Trees
        treeNode = SCNNode();
        self.rootNode.addChildNode(treeNode)
        let spawn = SCNAction.runBlock({(node) -> Void in self.spawnTrees()})
        let delay = SCNAction.waitForDuration(NSTimeInterval(1.0))
        let spawnThenDelay = SCNAction.sequence([spawn, spawn, spawn, delay])
        let spawnThenDelayForever = SCNAction.repeatActionForever(spawnThenDelay)
        treeNode.runAction(spawnThenDelayForever)
        
        //delete trees
        let delete = SCNAction.runBlock({(node) -> Void in self.deleteTrees()})
        let deleteThenDelay = SCNAction.sequence([delete, delay])
        let deleteForever = SCNAction.repeatActionForever(deleteThenDelay)
        treeNode.runAction(deleteForever)
        //spawnTrees()

        
        //Spawn Snowmen
        snowmenNode = SCNNode();
        self.rootNode.addChildNode(snowmenNode)
        let spawn2 = SCNAction.runBlock({(node) -> Void in self.spawnSnowmen()})
        let delay2 = SCNAction.waitForDuration(NSTimeInterval(1.0))
        let spawnThenDelay2 = SCNAction.sequence([spawn2, delay2])
        let spawnThenDelayForever2 = SCNAction.repeatActionForever(spawnThenDelay2)
        snowmenNode.runAction(spawnThenDelayForever2)
        //spawnSnowmen();
        
        //delete snowmen
        let delete2 = SCNAction.runBlock({(node) -> Void in self.deleteSnowmen()})
        let deleteThenDelay2 = SCNAction.sequence([delete2, delay2])
        let deleteForever2 = SCNAction.repeatActionForever(deleteThenDelay2)
        snowmenNode.runAction(deleteForever2)
        
    }
    func spawnTrees(){
        let width:UInt32 = UInt32(map.width)
        let x:Float = Float(arc4random() % (width))
        
        var tree = SCNNode()
        let scene = SCNScene(named: "TreeShake.dae")
        var nodeArray = scene!.rootNode.childNodes
        
        let treeMaterial = SCNMaterial();
        treeMaterial.litPerPixel = false
        treeMaterial.diffuse.contents = UIImage(named:"pine.bmp")
        treeMaterial.specular.contents = UIImage(named:"pine.bmp")
        treeMaterial.diffuse.wrapS = SCNWrapMode.Repeat
        treeMaterial.diffuse.wrapT = SCNWrapMode.Repeat
        
        for childNode in nodeArray{
            childNode.geometry??.materials = [treeMaterial]
            childNode.physicsBody??.categoryBitMask = treeCategory
            //childNode.physicsBody??.collisionBitMask = playerCategory
            tree.addChildNode(childNode as SCNNode)
        }
        tree.scale = SCNVector3Make(0.5, 0.5, 0.5)
        tree.position = SCNVector3(x: x, y: 0, z: playerNode.position.z - 150)
        
        tree.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(node: tree, options: nil))
        //tree.physicsBody?.velocityFactor = SCNVector3Zero
        tree.physicsBody?.categoryBitMask = treeCategory
        //tree.physicsBody?.collisionBitMask = playerCategory
        tree.paused = true
        treeNode.addChildNode(tree);
        tree.paused = true
        
    }
    func spawnSnowmen(){
        let width:UInt32 = UInt32(map.width)
        let x:Float = Float(arc4random() % (width))
        
        let snowman = SCNNode();
        let bottomSphere = SCNSphere(radius:  1.0)
        let middleSphere = SCNSphere(radius: 0.6)
        let topSphere = SCNSphere(radius: 0.4)
        bottomSphere.firstMaterial?.diffuse.contents = UIColor.whiteColor()
        middleSphere.firstMaterial?.diffuse.contents = UIColor.whiteColor()
        topSphere.firstMaterial?.diffuse.contents = UIColor.whiteColor()
        
        let snowmanBottom = SCNNode(geometry: bottomSphere)
        let snowmanMiddle = SCNNode(geometry: middleSphere)
        let snowmanTop = SCNNode(geometry: topSphere)
        snowmanBottom.position = SCNVector3(x: x, y: 0.9, z: playerNode.position.z - 150)
        snowmanMiddle.position = SCNVector3(x: x, y: 2.3, z: playerNode.position.z - 150 )
        snowmanTop.position = SCNVector3(x:x, y: 3.2, z: playerNode.position.z - 150)
        snowman.addChildNode(snowmanBottom)
        snowman.addChildNode(snowmanMiddle)
        snowman.addChildNode(snowmanTop)
        
        snowman.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(node: snowman, options: nil))
        snowman.physicsBody?.categoryBitMask = snowmanCategory
        snowmenNode.addChildNode(snowman)
    }
    func deleteTrees(){
        for node in treeNode.childNodes{
            let pos = node as SCNNode
            if pos.position.z > playerNode.position.z {
                pos.removeFromParentNode()
            }
        }
    }
    func deleteSnowmen(){
        for node in snowmenNode.childNodes{
            let pos = node as SCNNode
            if pos.position.z > playerNode.position.z {
                pos.removeFromParentNode()
            }
        }
    }
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        let t = contact.nodeA.physicsBody?.categoryBitMask
        let s = contact.nodeB.physicsBody?.categoryBitMask
        if( (t! & finishCategory == finishCategory) || (s! & finishCategory == finishCategory)){
            if((t! & playerCategory == playerCategory) || (s! & playerCategory == playerCategory)){
                playerNode.removeAllActions()
                treeNode.removeFromParentNode()
                finish.removeFromParentNode()
                skyNode.removeAllActions()
                NSNotificationCenter.defaultCenter().postNotificationName("StopTimerNotification", object: nil)
            }
        }
        if( (t! & treeCategory == treeCategory) || (s! & treeCategory == treeCategory)){
            if((t! & playerCategory == playerCategory) || (s! & playerCategory == playerCategory)){
                playerNode.runAction(SCNAction.moveBy(SCNVector3(x: 0, y: 0, z:15), duration: 1))
                skyNode.runAction(SCNAction.moveBy(SCNVector3(x: 0, y: 0, z:15), duration: 1))
                // Play sound
                soundPlayer.play()
            }
        }
        if( (t! & snowmanCategory  == snowmanCategory) || (s! & snowmanCategory == snowmanCategory)){
            if((t! & playerCategory == playerCategory) || (s! & playerCategory == playerCategory)){
                soundPlayer3.play()
                playerNode.runAction(SCNAction.moveBy(SCNVector3(x: 0, y: 0, z:-20), duration: 1))
                skyNode.runAction(SCNAction.moveBy(SCNVector3(x: 0, y: 0, z:-20), duration: 1))
                
            }
        }
    }
    
    func setupFloor() {
        let floorMaterial = SCNMaterial()
        floorMaterial.litPerPixel = false
        floorMaterial.diffuse.contents = UIImage(named:"snow.bmp")
        floorMaterial.diffuse.wrapS = SCNWrapMode.Repeat
        floorMaterial.diffuse.wrapT = SCNWrapMode.Repeat
        
        let floor = SCNFloor()
        floor.materials = [floorMaterial]
        floor.reflectivity = 0.1
        
        floorNode = SCNNode()
        floorNode.geometry = floor
        floorNode.physicsBody = SCNPhysicsBody.staticBody()
        floorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        self.rootNode.addChildNode(floorNode)
    }
    
}
