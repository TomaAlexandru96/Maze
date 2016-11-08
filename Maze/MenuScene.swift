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
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.black
        
        let menuCluster = SKCluster(orientation: ClusterOrientation.vertical)
        menuCluster.position = frame.center
        
        let playButton = SKButton(action: changeSceneToGameScene)
        playButton.text = "Play"
        
        menuCluster.append(playButton)
        
        addChild(menuCluster)
    }
    
    func changeSceneToGameScene(_ sender: SKNode) {
        gvc.chenageViewToGameScene(MazeConfiguration.defaultConfig)
    }
}
