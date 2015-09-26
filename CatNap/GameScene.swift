//
//  GameScene.swift
//  CatNap
//
//  Created by FRANCIS HUYNH on 7/8/15.
//  Copyright (c) 2015 Big Nerd ranch. All rights reserved.
//

import SpriteKit

protocol ImageCaptureDelegate {
    func requestImagePicker()
}

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let None: UInt32  =  0
        static let Cat: UInt32   =  0b1
        static let Block: UInt32 =  0b10
        static let Bed: UInt32   =  0b100
        static let Edge: UInt32 =   0b1000
        static let Label: UInt32 =  0b10000
        static let Spring: UInt32 = 0b100000
        static let Hook: UInt32 =   0b1000000
    }
    
    var imageCaptureDelegate : ImageCaptureDelegate?
    var photoChanged: Bool = false
    var bedNode: SKSpriteNode!
    var catNode: SKSpriteNode!
    var label: SKLabelNode!
    var currentLevel: Int = 0
    
    var hookBaseNode: SKSpriteNode!
    var hookNode: SKSpriteNode!
    var hookJoint: SKPhysicsJoint!
    var ropeNode: SKSpriteNode!
    
    
    func addHook() {
        hookBaseNode = childNodeWithName("hookBase") as? SKSpriteNode
        if hookBaseNode == nil {
            return
        }
        
        let ceilingFix = SKPhysicsJointFixed.jointWithBodyA(hookBaseNode.physicsBody!, bodyB: physicsBody!, anchor: CGPointZero)
        physicsWorld.addJoint(ceilingFix)
        
        ropeNode = SKSpriteNode(imageNamed: "rope")
        ropeNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        //ropeNode.zRotation = CGFloat(270).degreesToRadians()
        ropeNode.position = hookBaseNode.position
        addChild(ropeNode)
        
        hookNode = SKSpriteNode(imageNamed: "hook")
        //hookNode.position = CGPoint(x: hookBaseNode.position.x, y: hookBaseNode.position.y - 100)
        hookNode.position = CGPoint(x: hookBaseNode.position.x, y: hookBaseNode.position.y - ropeNode.size.width)
        
        hookNode.physicsBody = SKPhysicsBody(circleOfRadius: hookNode.size.width/2)
        hookNode.physicsBody!.categoryBitMask = PhysicsCategory.Hook
        hookNode.physicsBody!.contactTestBitMask = PhysicsCategory.Cat
        hookNode.physicsBody!.collisionBitMask = PhysicsCategory.None
        
        addChild(hookNode)
        
        let ropeJoint = SKPhysicsJointSpring.jointWithBodyA(hookBaseNode.physicsBody!, bodyB: hookNode.physicsBody!, anchorA: hookBaseNode.position, anchorB: CGPoint(x: hookNode.position.x, y: hookNode.position.y + hookNode.size.height/2))
        physicsWorld.addJoint(ropeJoint)
        
        //range = SKRange(lowerLimit: 0.0, upperLimit: 0.0)
        //let ropeOrientConstraint = SKConstraint.orientToNode(hookNode, offset: range)
        //ropeNode.constraints = [ropeOrientConstraint]
        
        hookNode.physicsBody!.applyImpulse(CGVector(dx: 50, dy: 0))
        
    }
    
    func addSeeSaw() {
        let seesawBaseNode = childNodeWithName("seesawBase") as? SKSpriteNode
        if seesawBaseNode == nil {
            print("Could find seesaw base");
            return
        }
        
        let seesawNode = childNodeWithName("seesaw") as? SKSpriteNode
        if seesawNode == nil {
            print("Could not find seesaw")
            return
        }
        
        let seesawPin = SKPhysicsJointPin.jointWithBodyA((seesawBaseNode?.physicsBody)!, bodyB: (seesawNode?.physicsBody)!, anchor: seesawBaseNode!.position)
        physicsWorld.addJoint(seesawPin)
        
    }
    
    
    // parameter photoFrame should be a node that is named: photoframe
    // this function will crob a image named picture into
    // the photoframe and set it's physics body 
    
    func addPhotoToFrame(photoFrame: SKSpriteNode) {
        let pictureNode = SKSpriteNode(imageNamed: "picture")
        pictureNode.name = "picture"
        
        let maskNode = SKSpriteNode(imageNamed: "picture-frame-mask")
        maskNode.name =  "mask"
        
        let cropNode = SKCropNode()
        cropNode.addChild(pictureNode)
        cropNode.maskNode = maskNode
        photoFrame.addChild(cropNode)
        
        photoFrame.physicsBody = SKPhysicsBody(circleOfRadius: ((photoFrame.size.width * 0.975) / 2.0))
        photoFrame.physicsBody?.categoryBitMask = PhysicsCategory.Block
        photoFrame.physicsBody?.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Cat | PhysicsCategory.Edge
        
    }
    func addPhotoFrameAtPosition(position: CGPoint) {
        let photoFrame = SKSpriteNode(imageNamed: "picture-frame")
        photoFrame.name = "photoframe"
        photoFrame.position = position
        
        let pictureNode = SKSpriteNode(imageNamed: "picture")
        pictureNode.name = "picture"
        
        let maskNode = SKSpriteNode(imageNamed: "picture-frame-mask")
        maskNode.name = "mask"
        
        let cropNode = SKCropNode()
        cropNode.addChild(pictureNode)
        cropNode.maskNode = maskNode
        
        photoFrame.addChild(cropNode)
        
        photoFrame.physicsBody = SKPhysicsBody(circleOfRadius: ((photoFrame.size.width * 0.975) / 2.0))
        photoFrame.physicsBody!.categoryBitMask = PhysicsCategory.Block
        photoFrame.physicsBody!.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Cat | PhysicsCategory.Edge
        addChild(photoFrame)
        
        
        
    }
    
    
    func changePhotoTexture(texture: SKTexture) {
        let photoNode = childNodeWithName("//picture") as! SKSpriteNode
        photoNode.texture = texture
        photoChanged = true
    }
    
    override func didMoveToView(view: SKView) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let maxAspectRatioHeight = size.width/maxAspectRatio
        let playableMargin: CGFloat = (size.height - maxAspectRatioHeight)/2
        let playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: size.height - playableMargin*2)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
        
        bedNode = childNodeWithName("bed") as! SKSpriteNode
        catNode = childNodeWithName("cat") as! SKSpriteNode
    
        // Turn off physis for cat bed
        let bedBodySize = CGSize(width: 40, height: 30)
        bedNode.physicsBody = SKPhysicsBody(rectangleOfSize: bedBodySize)
        bedNode.physicsBody!.dynamic = false
        bedNode.physicsBody!.categoryBitMask = PhysicsCategory.Bed
        bedNode.physicsBody!.collisionBitMask = PhysicsCategory.None
        
        
        // Set the physics body for cat
        let catBodyTexture = SKTexture(imageNamed: "cat_body")
        catNode.physicsBody = SKPhysicsBody(texture: catBodyTexture, size: catNode.size)
        catNode.physicsBody!.categoryBitMask = PhysicsCategory.Cat
        catNode.physicsBody!.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Edge | PhysicsCategory.Spring
        catNode.physicsBody!.contactTestBitMask = PhysicsCategory.Bed | PhysicsCategory.Edge
        // Play background music
        SKTAudio.sharedInstance.playBackgroundMusic("backgroundMusic.mp3")
        
        //Setup PhysicsContactDelegate
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        addHook()
        
        makeCompoundNode()
        
        addSeeSaw()
        
        enumerateChildNodesWithName("photoframe") { node, _ in
            self.addPhotoToFrame(node as! SKSpriteNode)
        }
        
        let backgroundDesat = SKSpriteNode(imageNamed: "background-desat")
        let label = SKLabelNode(fontNamed: "Zapfino")
        label.text = "Cat Nap"
        label.fontSize = 296
        
        let cropNode = SKCropNode()
        cropNode.addChild(backgroundDesat)
        cropNode.maskNode = label
        
        if let background = childNodeWithName("Background") {
            background.addChild(cropNode)
        }
    }
    
    func inGameMessage(text: String) {
        label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        label.text = text
        label.fontSize = 128.0
        label.color = SKColor.whiteColor()
        
        label.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        label.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        label.physicsBody!.collisionBitMask = PhysicsCategory.Edge
        label.physicsBody!.categoryBitMask = PhysicsCategory.Label
        label.physicsBody!.contactTestBitMask = PhysicsCategory.Edge
        label.physicsBody!.restitution = 0.7
        addChild(label)

        
//        runAction(SKAction.sequence([
//            SKAction.waitForDuration(3),
//            SKAction.removeFromParent()]))
    }
    
    class func level(levelNum: Int) -> GameScene? {
        let scene = GameScene(fileNamed: "Level\(levelNum)")
        scene!.currentLevel = levelNum
        scene!.scaleMode = .AspectFill
        return scene
    }
    
    func lose() {
        
        if currentLevel > 1 {
            //currentLevel--
        }
        catNode.physicsBody!.contactTestBitMask = PhysicsCategory.None
        catNode.texture = SKTexture(imageNamed: "cat_awake")
        
        SKTAudio.sharedInstance.pauseBackgroundMusic()
        runAction(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        inGameMessage("Try again...")
        runAction(SKAction.sequence([
            SKAction.waitForDuration(5),
            SKAction.runBlock(newGame)]))
        
    }
    
    func makeCompoundNode() {
        let compoundNode = SKNode()
        compoundNode.name = "compoundNode"
        
        var bodies: [SKPhysicsBody] = [SKPhysicsBody]()
        
        enumerateChildNodesWithName("stone") { node, _ in
            node.removeFromParent()
            compoundNode.addChild(node)
            let body = SKPhysicsBody(rectangleOfSize: node.frame.size, center: node.position)
            bodies.append(body)
        }
        
        compoundNode.physicsBody = SKPhysicsBody(bodies: bodies)
        compoundNode.physicsBody!.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Cat | PhysicsCategory.Block
        compoundNode.zPosition = -1
        addChild(compoundNode)
    }
    
    func newGame() {
        if let scene = GameScene.level(currentLevel) {
            scene.scaleMode = scaleMode
            scene.imageCaptureDelegate = imageCaptureDelegate
            view!.presentScene(GameScene.level(currentLevel))
        }
    }
    
    func sceneTouched(location: CGPoint) {
        let targetNode = self.nodeAtPoint(location)
        
        let nodes = self.nodesAtPoint(location)
        for node in nodes {
            if let nodeName = node.name {
                if nodeName == "photoframe" {
                    if !photoChanged {
                        imageCaptureDelegate?.requestImagePicker()
                        return
                        
                    }
                }
            }
        }
        
        if targetNode.parent?.name == "compoundNode" {
            targetNode.parent!.removeFromParent()
        }
        if targetNode.physicsBody == nil {
            return
        }
        
        
        if targetNode.physicsBody!.categoryBitMask == PhysicsCategory.Block {
            targetNode.removeFromParent()
            runAction(SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false))
            return
        }
        
        if targetNode.physicsBody!.categoryBitMask == PhysicsCategory.Spring {
            let spring = targetNode as! SKSpriteNode
            spring.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 190), atPoint: CGPoint(x: spring.size.width/2, y: spring.size.height))
            targetNode.runAction(SKAction.sequence([
                SKAction.waitForDuration(1),
                SKAction.removeFromParent()]))
            return
        }
        
        if targetNode.physicsBody!.categoryBitMask == PhysicsCategory.Cat  && hookJoint != nil {
            releaseHook()
        }
    }
   
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        let touch = touches.first
        sceneTouched(touch!.locationInNode(self))
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func releaseHook() {
        catNode.zRotation = 0
        hookNode.physicsBody!.contactTestBitMask = PhysicsCategory.None
        physicsWorld.removeJoint(hookJoint)
        hookJoint = nil
    }
    
    func win() {
        
        if (currentLevel < 5) {
            currentLevel++
        }
        catNode.physicsBody = nil
        
        let curlY = bedNode.position.y + catNode.size.height/3
        let curlPoint = CGPoint(x: bedNode.position.x, y: curlY)
        catNode.runAction(SKAction.group([
            SKAction.moveTo(curlPoint, duration: 0.66),
            SKAction.rotateToAngle(0, duration: 0.5)]))
        inGameMessage("You win")
        runAction(SKAction.sequence([
            SKAction.waitForDuration(5),
            SKAction.runBlock(newGame)]))
        catNode.runAction(SKAction.animateWithTextures([
            SKTexture(imageNamed: "cat_curlup1"),
            SKTexture(imageNamed: "cat_curlup2"),
            SKTexture(imageNamed: "cat_curlup3")], timePerFrame: 0.25))
        SKTAudio.sharedInstance.pauseBackgroundMusic()
        runAction(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
    }
    
    // MARK: PhysicsContactDelegate
    func didBeginContact(contact: SKPhysicsContact) {
        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.Cat | PhysicsCategory.Bed {
            win()
        } else if collision == PhysicsCategory.Cat | PhysicsCategory.Edge {
            lose()
        } else if collision == PhysicsCategory.Label | PhysicsCategory.Edge {
            var label: SKLabelNode
            if contact.bodyA.node == self.label {
                label = contact.bodyA.node as! SKLabelNode
            } else {
                label = contact.bodyB.node as! SKLabelNode
            }
            if label.userData == nil {
                label.userData = NSMutableDictionary(object: 1 as Int, forKey: "bounceCount")
            } else {
                let bounceCount = label.userData!["bounceCount"] as! NSNumber
                let bc = Int(bounceCount.intValue + 1)
                if bc == 4 {
                    label.removeFromParent()
                } else {
                    label.userData?.setValue(bc, forKeyPath: "bounceCount")
                }
            }
        }
        
        if collision == PhysicsCategory.Cat | PhysicsCategory.Hook {
            catNode.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            catNode.physicsBody!.angularVelocity = 0
            
            let pinPoint = CGPoint(x: hookNode.position.x, y: hookNode.position.y + hookNode.size.height/2)
            
            hookJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor: pinPoint)
            physicsWorld.addJoint(hookJoint)
        }
        
    }
    
    // MARK: Physics
    override func didSimulatePhysics() {
        if let body = catNode.physicsBody {
            if body.contactTestBitMask != PhysicsCategory.None &&
                fabs(catNode.zRotation) > CGFloat(45).degreesToRadians() {
                    if hookJoint == nil {
                        lose();
                    }
            }
        }
    }
}
