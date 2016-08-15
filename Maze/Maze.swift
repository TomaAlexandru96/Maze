//
//  Maze.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class Maze {
    let configuration: MazeConfiguration
    var sprite: SKSpriteNode = SKSpriteNode()
    var maze: [Tile : Set<Tile>] = [:]
    
    convenience init() {
        self.init(configuration: MazeConfiguration.defaultConfig)
    }
    
    init(configuration: MazeConfiguration) {
        self.configuration = configuration
        generateNewMaze()
    }
    
    func generateNewMaze() {
        maze = MazeGenerator.generateNewMaze(configuration: configuration)
    }
    
    func setSprite(root: SKNode) {
        sprite.removeAllChildren()
        sprite = MazeGenerator.getMazeSprite(configuration: configuration, maze: maze)
        root.addChild(sprite)
    }
}