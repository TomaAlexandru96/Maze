//
//  GameScene.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright (c) 2016 bart games. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var game: Game!
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        
        game = Game(root: self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        game.generateNewMaze()
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
