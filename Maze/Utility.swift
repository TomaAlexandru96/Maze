//
//  Utility.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

func -=(lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs - rhs
}
func +=(lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs + rhs
}
func *=(lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs * rhs
}
func /=(lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs / rhs
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}
func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}
func /(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
}

func -=(lhs: inout CGPoint, rhs: CGFloat) {
    lhs = lhs - rhs
}
func +=(lhs: inout CGPoint, rhs: CGFloat) {
    lhs = lhs + rhs
}
func *=(lhs: inout CGPoint, rhs: CGFloat) {
    lhs = lhs * rhs
}
func /=(lhs: inout CGPoint, rhs: CGFloat) {
    lhs = lhs / rhs
}

func -(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x - rhs, y: lhs.y - rhs)
}
func +(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x + rhs, y: lhs.y + rhs)
}
func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}
func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

extension CGVector {
    func magnitude() -> CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
    
    func normalise() -> CGVector {
        let m = magnitude()
        
        return CGVector(dx: dx / m, dy: dy / m)
    }
}

class Utility {
    static func max(value1: CGFloat, value2: CGFloat) -> CGFloat {
        return value1 > value2 ? value1 : value2
    }
    
    static func min(value1: CGFloat, value2: CGFloat) -> CGFloat {
        return value1 < value2 ? value1 : value2
    }
    
    static func clamp(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        var result = value
        
        result = Utility.max(value1: result, value2: min)
        result = Utility.min(value1: result, value2: max)
        
        return result
    }
}
