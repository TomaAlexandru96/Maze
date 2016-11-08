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
    case `static` = 0, dynamic
}

enum PadDirection: Int {
    case top = 0, topRight, right, bottomRight, bottom, bottomLeft, left, topLeft, none
    
    // returns a set of possible directions in a 4 directions game ({Top, Bottom, Left, Right})
    func getPossiblePaths() -> Set<PadDirection> {
        var set: Set<PadDirection> = []
        
        switch self {
        case .topRight:
            set.insert(.top)
            set.insert(.right)
        case .topLeft:
            set.insert(.top)
            set.insert(.left)
        case .bottomRight:
            set.insert(.bottom)
            set.insert(.right)
        case .bottomLeft:
            set.insert(.bottom)
            set.insert(.left)
        default:
            set.insert(self)
        }
        
        return set
    }
    
    func getOpposite() -> PadDirection {
        if self == .none {
            return .none
        }
        
        return PadDirection(rawValue: (self.rawValue + 4) % 8)!
    }
}

class SKPad: SKNode {
    fileprivate static let DEFAULT_RADIUS: CGFloat = 50
    fileprivate static let DEFAULT_COLOR: UIColor = UIColor.white
    fileprivate static let PAD_RANGE_RATIO: CGFloat = 0.5
    fileprivate static let RANGE_ALPHA: CGFloat = 0.3
    fileprivate static let PAD_ALPHA: CGFloat = 2
    fileprivate static let NULLZONE_RANGE_RATIO: CGFloat = 0.3
    fileprivate static let TRANSPARENT_COLOR: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    
    fileprivate let padShowAnimation = SKAction.fadeAlpha(to: PAD_ALPHA, duration: 0.1)
    fileprivate let padHideAnimation = SKAction.fadeAlpha(to: 0, duration: 0.1)
    fileprivate let rangeShowAnimation = SKAction.fadeAlpha(to: RANGE_ALPHA, duration: 0.2)
    fileprivate let rangeHideAnimation = SKAction.fadeAlpha(to: 0, duration: 0.2)
    fileprivate let range: SKShapeNode
    fileprivate let pad: SKShapeNode
    fileprivate let touchZone: SKSpriteNode
    fileprivate let root: SKNode = SKNode()
    let rangeRadius: CGFloat
    let mode: PadMode
    
    fileprivate var padShowAnimationActive: Bool = false
    fileprivate var padHideAnimationActive: Bool = false
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
        self.init(radius: SKPad.DEFAULT_RADIUS, mode: PadMode.static, touchZone: CGSize.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setProperties() {
        color = SKPad.DEFAULT_COLOR
        
        setTouchZone()
        setRange()
        setPad()
        
        addChild(root)
        isUserInteractionEnabled = true
    }
    
    fileprivate func setTouchZone() {
        touchZone.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        root.addChild(touchZone)
    }
    
    fileprivate func setRange() {
        range.alpha = SKPad.RANGE_ALPHA
        range.zPosition = touchZone.zPosition + 1
        
        if mode == PadMode.dynamic {
            range.alpha = 0
            range.isHidden = true
        }
        
        touchZone.addChild(range)
    }
    
    fileprivate func setPad() {
        pad.alpha = 0
        pad.zPosition = range.zPosition + 1
        pad.isHidden = true
        
        if mode == PadMode.dynamic {
            pad.alpha = SKPad.PAD_ALPHA
        }
        
        range.addChild(pad)
    }
    
    fileprivate func setPadPosition(_ location: CGPoint) {
        pad.position = location
        
        if !isInRange(pad.position) {
            let direction = getPadDirectionAsVector()
            
            pad.position = CGPoint(x: direction.dx * rangeRadius, y: direction.dy * rangeRadius)
        }
    }
    
    fileprivate func isInRange(_ location: CGPoint) -> Bool {
        let direction = CGVector(dx: location.x, dy: location.y)
        
        return direction.magnitude() <= rangeRadius
    }
    
    fileprivate func getPadDirectionAsVector(_ point: CGPoint) -> CGVector {
        if pad.isHidden || disabled {
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
        
        if direction == CGVector.zero || pad.isHidden || disabled {
            return .none
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
            return .right
        } else if x > cos(angle67_5) && x < cos(angle22_5) &&
                    y < sin(angle67_5) && y > sin(angle22_5) {
            return .topRight
        } else if x > cos(angle112_5) && x < cos(angle67_5) &&
                    y > sin(angle67_5) {
            return .top
        } else if x > cos(angle157_5) && x < cos(angle112_5) &&
                    y > sin(angle157_5) && y < sin(angle112_5){
            return .topLeft
        } else if x < cos(angle157_5) &&
                    y > sin(angle202_5) && y < sin(angle157_5) {
            return .left
        } else if x > cos(angle202_5) && x < cos(angle247_5) &&
                    y > sin(angle247_5) && y < sin(angle202_5) {
            return .bottomLeft
        } else if x > cos(angle247_5) && x < cos(angle292_5) &&
                    y < sin(angle247_5) {
            return .bottom
        } else {
            return .bottomRight
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
    fileprivate func hidePad() {
        guard !padHideAnimationActive else {
            return
        }
        
        if padShowAnimationActive {
            removeAnimations()
        }
        
        padHideAnimationActive = true
        if mode == PadMode.static {
            pad.run(padHideAnimation, completion: {
                self.pad.isHidden = true
                self.padHideAnimationActive = false
            })
        } else {
            range.run(rangeHideAnimation, completion: {
                self.pad.isHidden = true
                self.range.isHidden = true
                self.padHideAnimationActive = false
            })
        }
    }
    
    fileprivate func showPad() {
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
        
        pad.isHidden = false
        if mode == PadMode.static {
            pad.run(padShowAnimation, completion: completition)
        } else {
            range.isHidden = false
            range.run(rangeShowAnimation, completion: completition)
        }
    }
    
    fileprivate func removeAnimations() {
        pad.removeAllActions()
        range.removeAllActions()
        padShowAnimationActive = false
        padHideAnimationActive = false
    }
    
    fileprivate func isInTouchZone(_ location: CGPoint) -> Bool {
        if mode == PadMode.static {
            return true
        }
        
        return location.x > -touchZone.size.width / 2 &&
                location.x < touchZone.size.width / 2 &&
                location.y > -touchZone.size.height / 2 &&
                location.y < touchZone.size.height / 2
    }
    
    fileprivate func placePad(_ location: CGPoint) {
        if mode == PadMode.static {
            showPad()
        } else {
            if isInTouchZone(location) {
                range.position = location
                showPad()
            }
        }
    
        setPadPosition(root.convert(location, to: range))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else {
            return
        }
        
        placePad(firstTouch.location(in: root))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else {
            return
        }
        
        setPadPosition(firstTouch.location(in: range))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else {
            return
        }
        
        hidePad()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        hidePad()
    }
}
