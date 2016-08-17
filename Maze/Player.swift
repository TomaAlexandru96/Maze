//
//  Player.swift
//  Maze
//
//  Created by Toma Alexandru on 16/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class Player {
    private static let DEFAULT_COLOR: UIColor = UIColor.redColor()
    private static let MAX_MOVE_SPEED: CGFloat = 1
    private let gameDelegate: GameDelegate
    let mazeConfiguration: MazeConfiguration
    
    private var nextTile: Tile? = nil
    private var nextTileDirection: PadDirection = PadDirection.None
    private var position: Tile
    private var tileCount = 0
    var sprite: SKSpriteNode!
    var name: String!
    var maze: [Tile : Set<Tile>] = [:]
    
    init(mazeConfiguration: MazeConfiguration, name: String, gameDelegate: GameDelegate) {
        self.position = mazeConfiguration.playerStartTile
        self.mazeConfiguration = mazeConfiguration
        self.name = name
        self.gameDelegate = gameDelegate
    }
    
    func setSprite(root: SKNode) {
        sprite = SKSpriteNode()
        sprite.color = Player.DEFAULT_COLOR
        sprite.position = mazeConfiguration.getTilePosition(position)
        sprite.size = mazeConfiguration.blockSize
        sprite.anchorPoint = CGPoint(x: 0, y: 1)
        
        root.addChild(sprite)
    }
    
    private func hasPassedTile(pos: CGPoint, tile: Tile, direction: PadDirection) -> Bool {
        let tilePosition = mazeConfiguration.getTilePosition(tile)
        
        switch direction {
        case .Top where pos.y > tilePosition.y: return true
        case .Right where pos.x > tilePosition.x : return true
        case .Bottom where pos.y < tilePosition.y: return true
        case .Left where pos.x < tilePosition.x: return true
        default: return false
        }
    }
    
    private func gameEnded() -> Bool {
        return mazeConfiguration.exitTile == position
    }
    
    func moveSprite(direction: PadDirection, intensity: CGFloat) {
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
        case .Top:    velocity.dy = 1
        case .Right:  velocity.dx = 1
        case .Bottom: velocity.dy = -1
        case .Left:   velocity.dx = -1
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
    
    func movePlayer(direction: PadDirection, intensity: CGFloat) {
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
            
            if let path = possiblePaths.first where possiblePaths.count == 1 {
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
                
                if let path = possiblePaths.first where possiblePaths.count == 1 {
                    // there is only one path available
                    self.nextTile = getTileFromDirection(path)
                    self.nextTileDirection = path
                }
            }
        }
    }
    
    // checks if paths exist for direction
    private func checkPath(direction: PadDirection) -> Bool {
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
    private func getTileFromDirection(direction: PadDirection) -> Tile {
        let vectorMovement: [(row: Int, column: Int)] = [(-1, 0), (0, 1), (1, 0), (0, -1), (0, 0)]
        var vectorIndex: Int
        
        switch direction {
        case .Top:    vectorIndex = 0
        case .Right:  vectorIndex = 1
        case .Bottom: vectorIndex = 2
        case .Left:   vectorIndex = 3
        default:   vectorIndex = 4
        }
        
        let nextPosition = Tile(row: position.row + vectorMovement[vectorIndex].row,
                                column: position.column + vectorMovement[vectorIndex].column)
        return nextPosition
    }
}