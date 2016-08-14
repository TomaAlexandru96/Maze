//
//  Wall.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class Wall: Hashable {
    var sprite: SKSpriteNode!
    let tile1: Tile
    let tile2: Tile
    
    var hashValue: Int {
        return tile1.hashValue * 43 + tile2.hashValue * 73
    }
    
    init(tile1: Tile, tile2: Tile) {
        self.tile1 = tile1
        self.tile2 = tile2
    }
}

func ==(lhs: Wall, rhs: Wall) -> Bool {
    return lhs.tile1 == rhs.tile1 && lhs.tile2 == rhs.tile2 ||
            lhs.tile2 == rhs.tile1 && lhs.tile1 == rhs.tile2
}