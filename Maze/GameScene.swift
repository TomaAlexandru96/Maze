//
//  GameScene.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright (c) 2016 bart games. All rights reserved.
//

import SpriteKit
import Darwin

let MAX_ZOOM_OUT: CGFloat = 0.1
let MAX_ZOOM_IN:CGFloat = 4
let BOUNDS_OFFSET: CGFloat = 100
let PAD_OFFSET: CGFloat = 90
let PAD_TOUCH_ZONE_SIZE: CGSize = CGSize(width: 150, height: 150)

class GameScene: SKScene, GameDelegate {
    let gameObjectsLayer: SKNode = SKNode()
    let gameUILayer: SKNode = SKNode()
    let winScreen: SKNode = SKNode()
    let winLabel: SKLabelNode = SKLabelNode()
    let gamePad: SKPad = SKPad(mode: PadMode.Dynamic, touchZone: PAD_TOUCH_ZONE_SIZE)
    var game: Maze!
    var gvc: GameViewController!
    var gameConfiguration: MazeConfiguration = MazeConfiguration.defaultConfig
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        setGestures(view)
        setGameObjects()
        setUIObjects()
        reset(self)
    }
    
    func setGameObjects() {
        gameObjectsLayer.position = frame.center
        game = Maze(configuration: gameConfiguration, gameDelegate: self)
        game.setSprites(gameObjectsLayer)
        
        addChild(gameObjectsLayer)
    }
    
    func setUIObjects() {
        var padPositionOnScreen = CGPoint(x: frame.minX + PAD_OFFSET, y: frame.minY + PAD_OFFSET)
        gameUILayer.position = frame.center
        padPositionOnScreen = gameUILayer.convertPoint(padPositionOnScreen, fromNode: self)
        gamePad.position = padPositionOnScreen
        
        setWinScreen()
        
        gameUILayer.addChild(gamePad)
        addChild(gameUILayer)
    }
    
    func setWinScreen() {
        let background =
            SKSpriteNode(color: UIColor(red: 255, green: 255, blue: 255, alpha: 0.6), size: size)
        
        let winCluster = SKCluster()
        let label1 = SKLabelNode()
        label1.fontName = "Arial-Bold"
        label1.fontSize = 70
        label1.fontColor = UIColor.orangeColor()
        label1.name = "winLabel"
        label1.text = "You reached the exit"
        
        winLabel.fontName = "Arial-Bold"
        winLabel.fontSize = 70
        winLabel.fontColor = UIColor.orangeColor()
        winLabel.name = "winLabel"
        
        let resetButton = SKButton(action: reset)
        resetButton.text = "Play Again"
        resetButton.textColor = UIColor.orangeColor()
        resetButton.fontName = "Arial-Bold"
        resetButton.backgroundColor = UIColor.clearColor()
        resetButton.name = "resetButton"
        
        winCluster.append(label1)
        winCluster.append(winLabel)
        winCluster.append(resetButton)
        winCluster.spacing = 40
        
        winScreen.hidden = true
        
        winScreen.addChild(winCluster)
        winScreen.addChild(background)
        gameUILayer.addChild(winScreen)
    }
    
    func setGestures(view: SKView) {
        let zoomGesture =  UIPinchGestureRecognizer(target: self, action: #selector(GameScene.zoom))
        view.addGestureRecognizer(zoomGesture)
    }
    
    func zoom(sender: UIPinchGestureRecognizer) {
        struct Holder {
            static var gameScale: CGFloat = 1
        }
        
        switch sender.state {
        case .Began:
            Holder.gameScale = gameObjectsLayer.xScale
        case .Changed:
            let scaleFactor = sender.scale * Holder.gameScale
            
            gameObjectsLayer.xScale = Utility.clamp(value: scaleFactor,
                                  min: MAX_ZOOM_OUT, max: MAX_ZOOM_IN)
            gameObjectsLayer.yScale = gameObjectsLayer.xScale
            clampGameObjectsToBounds()
        default:
            return
        }
    }
    
    func clampGameObjectsToBounds() {
        _ = gameObjectsLayer.children.map({ (child) in
            var positionInLayer = gameObjectsLayer.convertPoint(child.position, toNode: self)
            let boundRelativeToSizeX = Utility.clamp(value: BOUNDS_OFFSET * gameObjectsLayer.xScale,
                min: 0,
                max: frame.width / 2)
            let boundRelativeToSizeY = Utility.clamp(value: BOUNDS_OFFSET * gameObjectsLayer.xScale,
                min: 0,
                max: frame.height / 2)
            
            positionInLayer.x = Utility.clamp(value: positionInLayer.x,
                min: frame.minX + boundRelativeToSizeX - child.frame.size.width * gameObjectsLayer.xScale,
                max: frame.maxX - boundRelativeToSizeX)
            positionInLayer.y = Utility.clamp(value: positionInLayer.y,
                min: frame.minY + boundRelativeToSizeY,
                max: frame.maxY - boundRelativeToSizeY + child.frame.size.height * gameObjectsLayer.yScale)
            child.position = gameObjectsLayer.convertPoint(positionInLayer, fromNode: self)
        })
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let firstTouch = touches.first else {
            return
        }
        
        let prev = firstTouch.previousLocationInNode(self)
        let current = firstTouch.locationInNode(self)
        let offset = CGPoint(x: prev.x - current.x, y: prev.y - current.y)
        
        _ = gameObjectsLayer.children.map({ (child) in
            child.position -= offset / gameObjectsLayer.xScale
        })
        
        clampGameObjectsToBounds()
    }
   
    override func update(currentTime: CFTimeInterval) {
        game.update(gamePad.getPadDirection(), intensity: gamePad.getPadIntensity())
    }
    
    func reset(sender: SKNode) {
        game.generateNewMaze()
        winScreen.hidden = true
        game.setSprites(gameObjectsLayer)
        gameObjectsLayer.hidden = false
        gamePad.userInteractionEnabled = true
        scaleMazeToFit()
    }
    
    func scaleMazeToFit() {
        let totalSize = gameConfiguration.getTotalSize()
        var scale: CGFloat = 1
        
        scale = size.height / totalSize.height
        
        gameObjectsLayer.xScale = scale
        gameObjectsLayer.yScale = scale
    }
    
    // delegate functions
    func gameEnded(tileNumber: Int) {
        winScreen.hidden = false
        winLabel.text = "in \(tileNumber) tiles!"
        gameObjectsLayer.hidden = true
        gamePad.userInteractionEnabled = false
    }
}