//
//  GameViewController.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright (c) 2016 bart games. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var currentScene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chenageViewToGameScene()
    }

    func chenageViewToGameScene() {
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        
        currentScene = GameScene(size: skView.bounds.size)
        currentScene.scaleMode = .AspectFill
        
        skView.presentScene(currentScene)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
