//
//  MazeConfiguration.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class MazeConfiguration {
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
}