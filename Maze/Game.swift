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
    
    init(root: SKNode) {
        maze = Maze(root: root)
    }
    
    func generateNewMaze() {
        maze.generateNewMaze()
    }
}