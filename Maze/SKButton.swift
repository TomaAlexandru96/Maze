//
//  SKButton.swift
//  Maze
//
//  Created by Toma Alexandru on 15/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class SKButton: SKNode {
    private static let LABEL_OVERSIZE_OFFSET: CGFloat = 20
    private static let DEFAULT_BACKGROUND_COLOR: UIColor = UIColor.whiteColor()
    private static let DEFAULT_TEXT_COLOR: UIColor = UIColor.blackColor()
    private static let HIGHLIGHT_ALPHA: CGFloat = 0.7
    private static let DEFAULT_ALPHA: CGFloat = 1
    private static let DEFAULT_BUTTON_SIZE: CGSize = CGSize(width: 100, height: 50)
    private static let DEFAULT_BUTTON_ACTION: (sender: SKNode) -> () = {(sender) in fatalError("Function not set in SKButton")}
    
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
    
    override var frame: CGRect {
        get {
            return calculateAccumulatedFrame()
        }
    }
    
    var fontName: String? {
        get {
            return textNode.fontName
        }
        
        set {
            textNode.fontName = newValue
            resizeToFitLabel()
        }
    }
    
    var fontSize: CGFloat {
        get {
            return textNode.fontSize
        }
        
        set {
            textNode.fontSize = newValue
            resizeToFitLabel()
        }
    }
    
    var size: CGSize {
        get {
            return background.size
        }
        
        set {
            background.size = newValue
            resizeToFitLabel()
        }
    }
    
    var text: String? {
        get {
            return textNode.text
        }
        
        set {
            textNode.text = newValue
            resizeToFitLabel()
        }
    }
    
    var textColor: UIColor? {
        get {
            return textNode.fontColor
        }
        
        set {
            textNode.fontColor = newValue
            resizeToFitLabel()
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
            resizeToFitLabel()
        }
    }
    
    var verticalAlignmentMode: SKLabelVerticalAlignmentMode {
        get {
            return textNode.verticalAlignmentMode
        }
        
        set {
            textNode.verticalAlignmentMode = newValue
            resizeToFitLabel()
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
        textColor = SKButton.DEFAULT_TEXT_COLOR
        horizontalAlignmentMode = .Center
        verticalAlignmentMode = .Center
        textNode.zPosition = background.zPosition + 1
        root.addChild(textNode)
    }
    
    private func setBackground() {
        backgroundColor = SKButton.DEFAULT_BACKGROUND_COLOR
        root.addChild(background)
    }
    
    private func resizeToFitLabel() {
        let textFrameSize = textNode.frame.size
        background.size.width = max(textFrameSize.width + SKButton.LABEL_OVERSIZE_OFFSET, background.size.width)
        background.size.height = max(textFrameSize.height + SKButton.LABEL_OVERSIZE_OFFSET, background.size.height)
    }
    
    convenience override init() {
        self.init(texture: nil, size: SKButton.DEFAULT_BUTTON_SIZE, action: SKButton.DEFAULT_BUTTON_ACTION)
    }
    
    convenience init(action: (sender: SKNode) -> ()) {
        self.init(texture: nil, size: SKButton.DEFAULT_BUTTON_SIZE, action: action)
    }
    
    convenience init(size: CGSize) {
        self.init(texture: nil, size: size, action: SKButton.DEFAULT_BUTTON_ACTION)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        root.alpha = SKButton.HIGHLIGHT_ALPHA
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        root.alpha = SKButton.DEFAULT_ALPHA
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