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

class GameScene: SKScene {
    let gameObjectsLayer: SKNode = SKNode()
    let gameUILayer: SKNode = SKNode()
    let gamePad: SKPad = SKPad(mode: PadMode.Dynamic, touchZone: PAD_TOUCH_ZONE_SIZE)
    var game: Game!
    var gvc: GameViewController!
    var gameConfiguration: MazeConfiguration = MazeConfiguration.defaultConfig
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        setGestures(view)
        setGameObjects()
        setUIObjects()
    }
    
    func setGameObjects() {
        gameObjectsLayer.position = frame.center
        game = Game(configuration: gameConfiguration)
        game.setSprites(gameObjectsLayer)
        
        addChild(gameObjectsLayer)
    }
    
    func setUIObjects() {
        var padPositionOnScreen = CGPoint(x: frame.minX + PAD_OFFSET, y: frame.minY + PAD_OFFSET)
        gameUILayer.position = frame.center
        padPositionOnScreen = gameUILayer.convertPoint(padPositionOnScreen, fromNode: self)
        gamePad.position = padPositionOnScreen
        
        gameUILayer.addChild(gamePad)
        addChild(gameUILayer)
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
    }
}