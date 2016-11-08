//
//  Player.swift
//  Maze
//
//  Created by Toma Alexandru on 16/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class Player {
    fileprivate static let DEFAULT_COLOR: UIColor = UIColor.red
    fileprivate static let MAX_MOVE_SPEED: CGFloat = 1
    fileprivate let gameDelegate: GameDelegate
    let mazeConfiguration: MazeConfiguration
    
    fileprivate var nextTile: Tile? = nil
    fileprivate var nextTileDirection: PadDirection = PadDirection.none
    fileprivate var position: Tile
    fileprivate var tileCount = 0
    var sprite: SKSpriteNode!
    var name: String!
    var maze: [Tile : Set<Tile>] = [:]
    
    init(mazeConfiguration: MazeConfiguration, name: String, gameDelegate: GameDelegate) {
        self.position = mazeConfiguration.playerStartTile
        self.mazeConfiguration = mazeConfiguration
        self.name = name
        self.gameDelegate = gameDelegate
    }
    
    func setSprite(_ root: SKNode) {
        sprite = SKSpriteNode()
        sprite.color = Player.DEFAULT_COLOR
        sprite.position = mazeConfiguration.getTilePosition(position)
        sprite.size = mazeConfiguration.blockSize
        sprite.anchorPoint = CGPoint(x: 0, y: 1)
        
        root.addChild(sprite)
    }
    
    fileprivate func hasPassedTile(_ pos: CGPoint, tile: Tile, direction: PadDirection) -> Bool {
        let tilePosition = mazeConfiguration.getTilePosition(tile)
        
        switch direction {
        case .top where pos.y > tilePosition.y: return true
        case .right where pos.x > tilePosition.x : return true
        case .bottom where pos.y < tilePosition.y: return true
        case .left where pos.x < tilePosition.x: return true
        default: return false
        }
    }
    
    fileprivate func gameEnded() -> Bool {
        return mazeConfiguration.exitTile == position
    }
    
    func moveSprite(_ direction: PadDirection, intensity: CGFloat) {
        var possiblePaths = direction.getPossiblePaths()
        
        for path in possiblePaths {
            if path != nextTileDirection.getOpposite() {
                possiblePaths.remove(path)
            }
        }
        
        if possiblePaths.count == 1 {
            // cancel movement and revert
            
            // swap tiles
            let aux = nextTile!
            nextTile = position
            position = aux
            nextTileDirection = nextTileDirection.getOpposite()
            
            return
        }
        
        // continue movement
        guard let nextTile = nextTile else {
            return
        }
        
        var velocity = CGVector.zero
        
        switch nextTileDirection {
        case .top:    velocity.dy = 1
        case .right:  velocity.dx = 1
        case .bottom: velocity.dy = -1
        case .left:   velocity.dx = -1
        default: fatalError("movePlayer in Player: not supposed to get here")
        }
        
        let scale = Player.MAX_MOVE_SPEED * intensity
        
        velocity = CGVector(dx: velocity.dx * scale,
                            dy: velocity.dy * scale)
        let newPosition = CGPoint(x: sprite.position.x + velocity.dx,
                                  y: sprite.position.y + velocity.dy)
        
        if hasPassedTile(newPosition, tile: nextTile, direction: nextTileDirection) {
            // has reached tile
            tileCount += 1
            self.nextTile = nil
            position = nextTile
            sprite.position = mazeConfiguration.getTilePosition(position)
        } else {
            sprite.position = newPosition
        }
    }
    
    func movePlayer(_ direction: PadDirection, intensity: CGFloat) {
        if gameEnded() {
            gameDelegate.gameEnded(tileCount)
            return
        }
        
        if nextTile != nil {
            moveSprite(direction, intensity: intensity)
        } else {
            // no movement
            var possiblePaths = direction.getPossiblePaths()
            
            for path in possiblePaths {
                if !checkPath(path) {
                    possiblePaths.remove(path)
                }
            }
            
            if let path = possiblePaths.first , possiblePaths.count == 1 {
                // there is only one path available
                self.nextTile = getTileFromDirection(path)
                self.nextTileDirection = path
            }
            
            if possiblePaths.count == 2 {
                // assume player instinct
                for path in possiblePaths {
                    if path == nextTileDirection {
                        possiblePaths.remove(nextTileDirection)
                    }
                }
                
                if let path = possiblePaths.first , possiblePaths.count == 1 {
                    // there is only one path available
                    self.nextTile = getTileFromDirection(path)
                    self.nextTileDirection = path
                }
            }
        }
    }
    
    // checks if paths exist for direction
    fileprivate func checkPath(_ direction: PadDirection) -> Bool {
        let nextTile = getTileFromDirection(direction)
        
        guard let values = maze[position] else {
            return false
        }
        
        for value in values {
            if value == nextTile {
                return true
            }
        }
        
        return false
    }
    
    // gets position from direction wrt player position
    fileprivate func getTileFromDirection(_ direction: PadDirection) -> Tile {
        let vectorMovement: [(row: Int, column: Int)] = [(-1, 0), (0, 1), (1, 0), (0, -1), (0, 0)]
        var vectorIndex: Int
        
        switch direction {
        case .top:    vectorIndex = 0
        case .right:  vectorIndex = 1
        case .bottom: vectorIndex = 2
        case .left:   vectorIndex = 3
        default:   vectorIndex = 4
        }
        
        let nextPosition = Tile(row: position.row + vectorMovement[vectorIndex].row,
                                column: position.column + vectorMovement[vectorIndex].column)
        return nextPosition
    }
}
