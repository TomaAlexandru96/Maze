//
//  MazeConfiguration.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

let DEFAULT_ROWS: Int = 20
let DEFAULT_COLUMNS: Int = 20
let DEFAULT_BLOCK_SIZE: CGFloat = 5
let DEFAULT_WALL_THICKNESS: CGFloat = 2.5

class MazeConfiguration {
    static let defaultConfig: MazeConfiguration =
                    MazeConfiguration(rows: DEFAULT_ROWS, columns: DEFAULT_COLUMNS,
                    blockSize: DEFAULT_BLOCK_SIZE, wallThickness: DEFAULT_BLOCK_SIZE)
    let blockSize: CGFloat
    let wallThickness: CGFloat
    let rows: Int
    let columns: Int
    
    init(rows: Int, columns: Int, blockSize: CGFloat, wallThickness: CGFloat) {
        self.rows = rows
        self.columns = columns
        self.blockSize = blockSize
        self.wallThickness = wallThickness
    }
    
    convenience init (rows: Int, columns: Int) {
        self.init(rows: rows, columns: columns,
                  blockSize: DEFAULT_BLOCK_SIZE, wallThickness: DEFAULT_WALL_THICKNESS)
    }
}