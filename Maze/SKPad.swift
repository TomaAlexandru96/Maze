//
//  SKPad.swift
//  Maze
//
//  Created by Toma Alexandru on 16/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit
import Darwin

enum PadMode: Int {
    case Static = 0, Dynamic
}

enum PadDirection: Int {
    case Top = 0, TopRight, Right, BottomRight, Bottom, BottomLeft, Left, TopLeft, None
    
    // returns a set of possible directions in a 4 directions game ({Top, Bottom, Left, Right})
    func getPossiblePaths() -> Set<PadDirection> {
        var set: Set<PadDirection> = []
        
        switch self {
        case .TopRight:
            set.insert(.Top)
            set.insert(.Right)
        case .TopLeft:
            set.insert(.Top)
            set.insert(.Left)
        case .BottomRight:
            set.insert(.Bottom)
            set.insert(.Right)
        case .BottomLeft:
            set.insert(.Bottom)
            set.insert(.Left)
        default:
            set.insert(self)
        }
        
        return set
    }
    
    func getOpposite() -> PadDirection {
        if self == .None {
            return .None
        }
        
        return PadDirection(rawValue: (self.rawValue + 4) % 8)!
    }
}

class SKPad: SKNode {
    private static let DEFAULT_RADIUS: CGFloat = 50
    private static let DEFAULT_COLOR: UIColor = UIColor.whiteColor()
    private static let PAD_RANGE_RATIO: CGFloat = 0.5
    private static let RANGE_ALPHA: CGFloat = 0.3
    private static let PAD_ALPHA: CGFloat = 2
    private static let NULLZONE_RANGE_RATIO: CGFloat = 0.3
    private static let TRANSPARENT_COLOR: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    
    private let padShowAnimation = SKAction.fadeAlphaTo(PAD_ALPHA, duration: 0.1)
    private let padHideAnimation = SKAction.fadeAlphaTo(0, duration: 0.1)
    private let rangeShowAnimation = SKAction.fadeAlphaTo(RANGE_ALPHA, duration: 0.2)
    private let rangeHideAnimation = SKAction.fadeAlphaTo(0, duration: 0.2)
    private let range: SKShapeNode
    private let pad: SKShapeNode
    private let touchZone: SKSpriteNode
    private let root: SKNode = SKNode()
    let rangeRadius: CGFloat
    let mode: PadMode
    
    private var padShowAnimationActive: Bool = false
    private var padHideAnimationActive: Bool = false
    var disabled: Bool = false
    
    override var position: CGPoint {
        get {
            return root.position
        }
        
        set {
            root.position = newValue
        }
    }
    
    var color: UIColor {
        get {
            return range.fillColor
        }
        
        set {
            range.fillColor = newValue
            pad.fillColor = newValue
        }
    }
    
    init(radius: CGFloat, mode: PadMode, touchZone: CGSize) {
        self.rangeRadius = radius
        range = SKShapeNode(circleOfRadius: radius)
        pad = SKShapeNode(circleOfRadius: radius * SKPad.PAD_RANGE_RATIO)
        self.mode = mode
        self.touchZone = SKSpriteNode(color: SKPad.TRANSPARENT_COLOR, size: touchZone)
        super.init()
        setProperties()
    }
    
    convenience init(mode: PadMode, touchZone: CGSize) {
        self.init(radius: SKPad.DEFAULT_RADIUS, mode: mode, touchZone: touchZone)
    }
    
    convenience override init() {
        self.init(radius: SKPad.DEFAULT_RADIUS, mode: PadMode.Static, touchZone: CGSize.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setProperties() {
        color = SKPad.DEFAULT_COLOR
        
        setTouchZone()
        setRange()
        setPad()
        
        addChild(root)
        userInteractionEnabled = true
    }
    
    private func setTouchZone() {
        touchZone.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        root.addChild(touchZone)
    }
    
    private func setRange() {
        range.alpha = SKPad.RANGE_ALPHA
        range.zPosition = touchZone.zPosition + 1
        
        if mode == PadMode.Dynamic {
            range.alpha = 0
            range.hidden = true
        }
        
        touchZone.addChild(range)
    }
    
    private func setPad() {
        pad.alpha = 0
        pad.zPosition = range.zPosition + 1
        pad.hidden = true
        
        if mode == PadMode.Dynamic {
            pad.alpha = SKPad.PAD_ALPHA
        }
        
        range.addChild(pad)
    }
    
    private func setPadPosition(location: CGPoint) {
        pad.position = location
        
        if !isInRange(pad.position) {
            let direction = getPadDirectionAsVector()
            
            pad.position = CGPoint(x: direction.dx * rangeRadius, y: direction.dy * rangeRadius)
        }
    }
    
    private func isInRange(location: CGPoint) -> Bool {
        let direction = CGVector(dx: location.x, dy: location.y)
        
        return direction.magnitude() <= rangeRadius
    }
    
    private func getPadDirectionAsVector(point: CGPoint) -> CGVector {
        if pad.hidden || disabled {
            return CGVector.zero
        }
        
        let direction = CGVector(dx: point.x, dy: point.y)
        if direction.magnitude() > rangeRadius * SKPad.NULLZONE_RANGE_RATIO {
            return direction.normalise()
        } else {
            return CGVector.zero
        }
    }
    
    func getPadDirectionAsVector() -> CGVector {
        return getPadDirectionAsVector(pad.position)
    }
    
    func getPadDirection() -> PadDirection {
        let direction = getPadDirectionAsVector()
        
        if direction == CGVector.zero || pad.hidden || disabled {
            return .None
        }
        
        let x: Double = Double(direction.dx)
        let y: Double = Double(direction.dy)
        
        let angle22_5 = M_PI / 8
        let angle67_5 = 3 * M_PI / 8
        let angle112_5 = 5 * M_PI / 8
        let angle157_5 = 7 * M_PI / 8
        let angle202_5 = 9 * M_PI / 8
        let angle247_5 = 11 * M_PI / 8
        let angle292_5 = 13 * M_PI / 8
        let angle337_5 = 15 * M_PI / 8
        
        if x > cos(angle22_5) &&
            y < sin(angle22_5) && y > sin(angle337_5) {
            return .Right
        } else if x > cos(angle67_5) && x < cos(angle22_5) &&
                    y < sin(angle67_5) && y > sin(angle22_5) {
            return .TopRight
        } else if x > cos(angle112_5) && x < cos(angle67_5) &&
                    y > sin(angle67_5) {
            return .Top
        } else if x > cos(angle157_5) && x < cos(angle112_5) &&
                    y > sin(angle157_5) && y < sin(angle112_5){
            return .TopLeft
        } else if x < cos(angle157_5) &&
                    y > sin(angle202_5) && y < sin(angle157_5) {
            return .Left
        } else if x > cos(angle202_5) && x < cos(angle247_5) &&
                    y > sin(angle247_5) && y < sin(angle202_5) {
            return .BottomLeft
        } else if x > cos(angle247_5) && x < cos(angle292_5) &&
                    y < sin(angle247_5) {
            return .Bottom
        } else {
            return .BottomRight
        }
    }
    
    // gets distance from null zone to range as a value between (0, 1)
    func getPadIntensity() -> CGFloat {
        let nullRadius = rangeRadius * SKPad.NULLZONE_RANGE_RATIO
        let padVector = CGVector(dx: pad.position.x, dy: pad.position.y)
        let padRange = padVector.magnitude() < nullRadius ? 0 : padVector.magnitude() - nullRadius
        
        return padRange / (rangeRadius - nullRadius)
    }
    
    // animations and user interaction
    private func hidePad() {
        guard !padHideAnimationActive else {
            return
        }
        
        if padShowAnimationActive {
            removeAnimations()
        }
        
        padHideAnimationActive = true
        if mode == PadMode.Static {
            pad.runAction(padHideAnimation, completion: {
                self.pad.hidden = true
                self.padHideAnimationActive = false
            })
        } else {
            range.runAction(rangeHideAnimation, completion: {
                self.pad.hidden = true
                self.range.hidden = true
                self.padHideAnimationActive = false
            })
        }
    }
    
    private func showPad() {
        guard !padShowAnimationActive else {
            return
        }
        
        if padHideAnimationActive {
            removeAnimations()
        }
        
        padShowAnimationActive = true
        let completition = {
            self.padShowAnimationActive = false
        }
        
        pad.hidden = false
        if mode == PadMode.Static {
            pad.runAction(padShowAnimation, completion: completition)
        } else {
            range.hidden = false
            range.runAction(rangeShowAnimation, completion: completition)
        }
    }
    
    private func removeAnimations() {
        pad.removeAllActions()
        range.removeAllActions()
        padShowAnimationActive = false
        padHideAnimationActive = false
    }
    
    private func isInTouchZone(location: CGPoint) -> Bool {
        if mode == PadMode.Static {
            return true
        }
        
        return location.x > -touchZone.size.width / 2 &&
                location.x < touchZone.size.width / 2 &&
                location.y > -touchZone.size.height / 2 &&
                location.y < touchZone.size.height / 2
    }
    
    private func placePad(location: CGPoint) {
        if mode == PadMode.Static {
            showPad()
        } else {
            if isInTouchZone(location) {
                range.position = location
                showPad()
            }
        }
    
        setPadPosition(root.convertPoint(location, toNode: range))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let firstTouch = touches.first else {
            return
        }
        
        placePad(firstTouch.locationInNode(root))
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let firstTouch = touches.first else {
            return
        }
        
        setPadPosition(firstTouch.locationInNode(range))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let _ = touches.first else {
            return
        }
        
        hidePad()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        hidePad()
    }
}