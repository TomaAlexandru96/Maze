//
//  Game.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class Game {
    let maze: Maze
    
    init(configuration: MazeConfiguration) {
        maze = Maze(configuration: configuration)
    }
    
    func generateNewMaze() {
        maze.generateNewMaze()
    }
    
    func setSprites(root: SKNode) {
        maze.setSprite(root)
    }
}