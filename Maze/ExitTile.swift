//
//  ExitTile.swift
//  Maze
//
//  Created by Toma Alexandru on 16/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class ExitTile {
    private static let DEFAULT_COLOR: UIColor = UIColor.greenColor()
    let mazeConfiguration: MazeConfiguration
    let position: Tile
    var sprite: SKSpriteNode!
    
    init(mazeConfiguration: MazeConfiguration) {
        self.mazeConfiguration = mazeConfiguration
        self.position = mazeConfiguration.exitTile
    }
    
    func setSprite(root: SKNode) {
        sprite = SKSpriteNode()
        sprite.position = mazeConfiguration.getTilePosition(mazeConfiguration.exitTile)
        sprite.color = ExitTile.DEFAULT_COLOR
        sprite.size = mazeConfiguration.blockSize
        sprite.anchorPoint = CGPoint(x: 0, y: 1)
        
        root.addChild(sprite)
    }
}