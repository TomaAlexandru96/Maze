//
//  SKCluster.swift
//  Maze
//
//  Created by Toma Alexandru on 16/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

enum ClusterOrientation: Int {
    case vertical = 0, horizontal
}

class SKCluster: SKNode {
    fileprivate static let DEFAULT_CLUSTER_ORIENTATION = ClusterOrientation.vertical
    fileprivate static let DEFAULT_SPACING: CGFloat = 20
    
    let root: SKNode
    var orientation: ClusterOrientation {
        didSet {
            placeCluster()
        }
    }
    var spacing: CGFloat {
        didSet {
            placeCluster()
        }
    }
    fileprivate var elements: [SKNode]
    
    override var position: CGPoint {
        get {
            return root.position
        }
        
        set {
            root.position = newValue
        }
    }
    
    init(orientation: ClusterOrientation, spacing: CGFloat, elements: [SKNode]) {
        self.orientation = orientation
        self.spacing = spacing
        self.elements = elements
        self.root = SKNode()
        super.init()
        placeCluster()
        addChild(root)
    }
    
    convenience init(orientation: ClusterOrientation) {
        self.init(orientation: orientation, spacing: SKCluster.DEFAULT_SPACING, elements: [])
    }
    
    convenience override init() {
        self.init(orientation: SKCluster.DEFAULT_CLUSTER_ORIENTATION, spacing: SKCluster.DEFAULT_SPACING, elements: [])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func append(_ node: SKNode) {
        elements.append(node)
        placeCluster()
    }
    
    fileprivate func placeCluster() {
        let totalSize = getTotalOrientationSize()
        root.removeAllChildren()
        
        if orientation == ClusterOrientation.vertical {
            var nextPositionY = totalSize / 2
            for element in elements {
                let elementFrameHeight = element.calculateAccumulatedFrame().height
                element.position = CGPoint(x: 0, y: nextPositionY - elementFrameHeight / 2)
                nextPositionY -= (spacing + elementFrameHeight)
                root.addChild(element)
            }
        } else {
            var nextPositionX = -(totalSize / 2)
            
            for element in elements {
                let elementFrameWidth = element.calculateAccumulatedFrame().width
                element.position = CGPoint(x: nextPositionX + elementFrameWidth / 2, y: 0)
                nextPositionX += spacing + elementFrameWidth
                root.addChild(element)
            }
        }
    }
    
    fileprivate func getTotalOrientationSize() -> CGFloat {
        var totalOrientation: CGFloat = 0
        if orientation == ClusterOrientation.horizontal {
            for element in elements {
                totalOrientation += element.calculateAccumulatedFrame().width
            }
        } else {
            for element in elements {
                totalOrientation += element.calculateAccumulatedFrame().height
            }
        }
        
        totalOrientation += elements.count - 1 < 0 ? 0 : CGFloat(elements.count - 1) * spacing
        return totalOrientation
    }
}
