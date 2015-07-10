//
//  GameScene.swift
//  CatNap
//
//  Created by FRANCIS HUYNH on 7/8/15.
//  Copyright (c) 2015 Big Nerd ranch. All rights reserved.
//

import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let None: UInt32  = 0
        static let Cat: UInt32   = 0b1
        static let Block: UInt32 = 0b10
        static let Bed: UInt32   = 0b100
        static let Edge: UInt32 = 0b1000
        static let Label: UInt32 = 0b10000
    }
    
    var bedNode: SKSpriteNode!
    var catNode: SKSpriteNode!
    var label: SKLabelNode!
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
        catNode.physicsBody!.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Edge
        catNode.physicsBody!.contactTestBitMask = PhysicsCategory.Bed | PhysicsCategory.Edge
        // Play background music
        SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
        
        //Setup PhysicsContactDelegate
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
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
    
    func lose() {
        catNode.physicsBody!.contactTestBitMask = PhysicsCategory.None
        catNode.texture = SKTexture(imageNamed: "cat_awake")
        
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        runAction(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        inGameMessage("Try again...")
        runAction(SKAction.sequence([
            SKAction.waitForDuration(5),
            SKAction.runBlock(newGame)]))
        
    }
    
    func newGame() {
        let scene = GameScene(fileNamed: "GameScene")
        scene.scaleMode = .AspectFill
        view!.presentScene(scene)
    }
    
    func sceneTouched(location: CGPoint) {
        let targetNode = self.nodeAtPoint(location)
        
        if targetNode.physicsBody == nil {
            return
        }
        
        if targetNode.physicsBody!.categoryBitMask == PhysicsCategory.Block {
            targetNode.removeFromParent()
            runAction(SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false))
            return
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch = touches.first as! UITouch
        sceneTouched(touch.locationInNode(self))
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func win() {
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
        SKTAudio.sharedInstance().pauseBackgroundMusic()
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
                var bounceCount = label.userData!["bounceCount"] as! NSNumber
                let bc = Int(bounceCount.intValue + 1)
                if bc == 4 {
                    label.removeFromParent()
                } else {
                    label.userData?.setValue(bc, forKeyPath: "bounceCount")
                }
            }
        }
        
    }
}
