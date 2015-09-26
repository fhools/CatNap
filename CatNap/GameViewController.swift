//
//  GameViewController.swift
//  CatNap
//
//  Created by FRANCIS HUYNH on 7/8/15.
//  Copyright (c) 2015 Big Nerd ranch. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
//    class func unarchiveFromFile(file : String) -> SKNode? {
//        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
//            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
//            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
//            
//            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
//            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
//            archiver.finishDecoding()
//            return scene
//        } else {
//            return nil
//        }
//    }
}

class GameViewController: UIViewController, ImageCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.level(5) {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsPhysics = true
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = false
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            scene.imageCaptureDelegate = self
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
//            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
//        } else {
//            return Int(UIInterfaceOrientationMask.All.rawValue)
//        }
        return UIInterfaceOrientationMask.Landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: ImageCaptureDelegate
    func requestImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
    // MARK: ImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismissViewControllerAnimated(true) {
            let imageTexture = SKTexture(image: image)
            let skView = self.view as! SKView
            let gameScene = skView.scene as! GameScene
            gameScene.changePhotoTexture(imageTexture)
        }
    }
    
}
