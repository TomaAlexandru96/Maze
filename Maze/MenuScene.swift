//
//  MenuScene.swift
//  Maze
//
//  Created by Toma Alexandru on 15/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    var gvc: GameViewController!
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        
        let menuCluster = SKCluster(orientation: ClusterOrientation.Vertical)
        menuCluster.position = frame.center
        
        let playButton = SKButton(action: changeSceneToGameScene)
        playButton.text = "Play"
        
        menuCluster.append(playButton)
        
        addChild(menuCluster)
    }
    
    func changeSceneToGameScene(sender: SKNode) {
        gvc.chenageViewToGameScene(MazeConfiguration.defaultConfig)
    }
}