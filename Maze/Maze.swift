//
//  Maze.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

let DEFAULT_ROWS: Int = 20
let DEFAULT_COLUMNS: Int = 20
let DEFAULT_BLOCK_SIZE: CGFloat = 10
let DEFAULT_WALL_THICKNESS: CGFloat = 5

class Maze {
    let configuration: MazeConfiguration
    var root: SKNode
    var sprite: SKSpriteNode = SKSpriteNode()
    var maze: [Tile : Set<Tile>] = [:]
    
    init(root: SKNode) {
        self.root = root
        self.configuration = MazeConfiguration(rows: DEFAULT_ROWS, columns: DEFAULT_COLUMNS,
                            blockSize: DEFAULT_BLOCK_SIZE, wallThickness: DEFAULT_WALL_THICKNESS)
        generateNewMaze()
    }
    
    func generateNewMaze() {
        maze = MazeGenerator.generateNewMaze(configuration: configuration)
        
        setSprite(root)
    }
    
    func setSprite(root: SKNode) {
        sprite = MazeGenerator.getMazeSprite(configuration: configuration, maze: maze, root: root)
        root.removeAllChildren()
        root.addChild(sprite)
    }
}