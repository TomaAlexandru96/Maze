//
//  MazeConfiguration.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class MazeConfiguration {
    fileprivate static let DEFAULT_ROWS: Int = 20
    fileprivate static let DEFAULT_COLUMNS: Int = 20
    fileprivate static let DEFAULT_BLOCK_SIZE: CGSize = CGSize(width: 5, height: 5)
    fileprivate static let DEFAULT_WALL_THICKNESS: CGFloat = 2.5
    fileprivate static let DEFAULT_PLAYER_START_TILE: Tile = Tile(row: 1, column: 1)
    fileprivate static let DEFAULT_EXIT_TILE: Tile = Tile(row: MazeConfiguration.DEFAULT_ROWS,
                                                      column: MazeConfiguration.DEFAULT_COLUMNS)
    static let defaultConfig: MazeConfiguration =
                    MazeConfiguration(rows: DEFAULT_ROWS,
                                      columns: DEFAULT_COLUMNS,
                                      blockSize: DEFAULT_BLOCK_SIZE,
                                      wallThickness: DEFAULT_WALL_THICKNESS,
                                      playerStartTile: DEFAULT_PLAYER_START_TILE,
                                      exitTile: MazeConfiguration.DEFAULT_EXIT_TILE)
    let blockSize: CGSize
    let wallThickness: CGFloat
    let rows: Int
    let columns: Int
    let playerStartTile: Tile
    let exitTile: Tile
    
    init(rows: Int, columns: Int, blockSize: CGSize,
                wallThickness: CGFloat, playerStartTile: Tile, exitTile: Tile) {
        self.rows = rows
        self.columns = columns
        self.blockSize = blockSize
        self.wallThickness = wallThickness
        self.playerStartTile = playerStartTile
        self.exitTile = exitTile
    }
    
    convenience init (rows: Int, columns: Int) {
        self.init(rows: rows, columns: columns,
                  blockSize: MazeConfiguration.DEFAULT_BLOCK_SIZE,
                  wallThickness: MazeConfiguration.DEFAULT_WALL_THICKNESS,
                  playerStartTile: MazeConfiguration.DEFAULT_PLAYER_START_TILE,
                  exitTile: MazeConfiguration.DEFAULT_EXIT_TILE)
    }
    
    func getTilePosition(_ tile: Tile) -> CGPoint {
        var result = CGPoint.zero
        
        result.x = wallThickness + CGFloat(tile.column - 1) * (blockSize.width + wallThickness)
        result.y = -(wallThickness + CGFloat(tile.row - 1) * (blockSize.height + wallThickness))
        
        return result
    }
    
    func getTotalSize() -> CGSize {
        return CGSize(width: CGFloat(columns) * (blockSize.width + wallThickness) + wallThickness,
                      height: CGFloat(rows) * (blockSize.height + wallThickness) + wallThickness)
    }
}
