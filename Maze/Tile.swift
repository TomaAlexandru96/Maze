//
//  Tile.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

struct Tile: Hashable, CustomStringConvertible {
    let row: Int
    let column: Int
    
    var hashValue: Int {
        return row * (MazeConfiguration.defaultConfig.columns + 2) + column
    }
    
    var description: String {
        return "(\(row), \(column))"
    }
}

func ==(lhs: Tile, rhs: Tile) -> Bool {
    return lhs.row == rhs.row &&
        lhs.column == rhs.column
}