//
//  Maze.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

protocol GameDelegate {
    func gameEnded(tileNumber: Int)
}

class Maze {
    private let gameDelegate: GameDelegate
    let configuration: MazeConfiguration
    var sprite: SKSpriteNode
    var player: Player
    var exitTile: ExitTile
    
    convenience init(gameDelegate: GameDelegate) {
        self.init(configuration: MazeConfiguration.defaultConfig, gameDelegate: gameDelegate)
    }
    
    init(configuration: MazeConfiguration, gameDelegate: GameDelegate) {
        self.gameDelegate = gameDelegate
        self.player = Player(mazeConfiguration: configuration, name: "Player", gameDelegate: gameDelegate)
        self.exitTile = ExitTile(mazeConfiguration: configuration)
        self.sprite = SKSpriteNode()
        self.configuration = configuration
        generateNewMaze()
    }
    
    func generateNewMaze() {
        player = Player(mazeConfiguration: configuration, name: "Player", gameDelegate: gameDelegate)
        exitTile = ExitTile(mazeConfiguration: configuration)
        player.maze = MazeGenerator.generateNewMaze(configuration: configuration)
    }
    
    func setSprites(root: SKNode) {
        root.removeChildrenInArray([sprite])
        sprite.removeAllChildren()
        sprite = MazeGenerator.getMazeSprite(configuration: configuration, maze: player.maze)
        player.setSprite(sprite)
        exitTile.setSprite(sprite)
        
        root.addChild(sprite)
    }
    
    func update(direction: PadDirection, intensity: CGFloat) {
        player.movePlayer(direction, intensity: intensity)
    }
}