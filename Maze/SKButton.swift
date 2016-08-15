//
//  SKButton.swift
//  Maze
//
//  Created by Toma Alexandru on 15/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

let DEFAULT_BACKGROUND_COLOR: UIColor = UIColor.whiteColor()
let DEFAULT_TEXT_COLOR: UIColor = UIColor.blackColor()
let HIGHLIGHT_ALPHA: CGFloat = 0.7
let DEFAULT_ALPHA: CGFloat = 1
let DEFAULT_BUTTON_SIZE: CGSize = CGSize(width: 100, height: 50)
let DEFAULT_BUTTON_ACTION: (sender: SKNode) -> () = {(sender) in fatalError("Function not set in SKButton")}

class SKButton: SKNode {
    private let root: SKNode = SKNode()
    private let background: SKSpriteNode
    private let textNode: SKLabelNode
    override var position: CGPoint {
        get {
            return root.position
        }
        
        set {
            root.position = newValue
        }
    }
    
    var fontName: String? {
        get {
            return textNode.fontName
        }
        
        set {
            textNode.fontName = newValue
        }
    }
    
    var fontSize: CGFloat {
        get {
            return textNode.fontSize
        }
        
        set {
            textNode.fontSize = newValue
        }
    }
    
    var size: CGSize {
        get {
            return background.size
        }
        
        set {
            background.size = newValue
        }
    }
    
    var text: String? {
        get {
            return textNode.text
        }
        
        set {
            textNode.text = newValue
        }
    }
    
    var textColor: UIColor? {
        get {
            return textNode.fontColor
        }
        
        set {
            textNode.fontColor = newValue
        }
    }
    
    var backgroundColor: UIColor {
        get {
            return background.color
        }
        
        set {
            background.color = newValue
        }
    }
    
    var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode {
        get {
            return textNode.horizontalAlignmentMode
        }
        
        set {
            textNode.horizontalAlignmentMode = newValue
        }
    }
    
    var verticalAlignmentMode: SKLabelVerticalAlignmentMode {
        get {
            return textNode.verticalAlignmentMode
        }
        
        set {
            textNode.verticalAlignmentMode = newValue
        }
    }
    
    var texture: SKTexture? {
        get {
            return background.texture
        }
        
        set {
            background.texture = texture
        }
    }
    
    override var description: String {
        return "\(root)\n \(background)\n \(textNode)"
    }
    
    var action: ((sender: SKNode) -> ())
    
    init(texture: SKTexture?, size: CGSize, action: (sender: SKNode) -> ()) {
        self.background = SKSpriteNode(texture: texture)
        self.textNode = SKLabelNode()
        self.action = action
        super.init()
        self.size = size
        self.userInteractionEnabled = true
        addChild(root)
        setTextNode()
        setBackground()
    }
    
    private func setTextNode() {
        textColor = DEFAULT_TEXT_COLOR
        horizontalAlignmentMode = .Center
        verticalAlignmentMode = .Center
        textNode.zPosition = background.zPosition + 1
        root.addChild(textNode)
    }
    
    private func setBackground() {
        backgroundColor = DEFAULT_BACKGROUND_COLOR
        root.addChild(background)
    }
    
    convenience override init() {
        self.init(texture: nil, size: DEFAULT_BUTTON_SIZE, action: DEFAULT_BUTTON_ACTION)
    }
    
    convenience init(action: (sender: SKNode) -> ()) {
        self.init(texture: nil, size: DEFAULT_BUTTON_SIZE, action: action)
    }
    
    convenience init(size: CGSize) {
        self.init(texture: nil, size: size, action: DEFAULT_BUTTON_ACTION)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        root.alpha = HIGHLIGHT_ALPHA
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        root.alpha = DEFAULT_ALPHA
        for touch in touches {
            for node in nodesAtPoint(touch.locationInNode(self)) {
                if node == background {
                    action(sender: self)
                    return
                }
            }
        }
    }
}