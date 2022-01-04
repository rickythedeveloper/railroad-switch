//
//  CGPoint+.swift
//  railroad-switch
//
//  Created by Rintaro Kawagishi on 02/01/2022.
//

import CoreGraphics

extension CGPoint {
    static func *(lhs: CGPoint, rhs: Double) -> CGPoint { CGPoint(x: lhs.x * rhs, y: lhs.y * rhs) }
    static func *(lhs: Double, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs * rhs.x, y: lhs * rhs.y) }
    static func /(lhs: CGPoint, rhs: Double) -> CGPoint { lhs * (1/rhs) }
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
    
    static func getDistanceBetween(_ point1: CGPoint,_ point2: CGPoint) -> Double {
        let delta = point1 - point2
        return (pow(Double(delta.x), 2) + pow(Double(delta.y), 2)).squareRoot()
    }
    
    static func getMaxMin(points: [CGPoint]) -> (minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        var minX: CGFloat = 0, maxX: CGFloat = 0, minY: CGFloat = 0, maxY: CGFloat = 0
        for p in points {
            if p.x > maxX { maxX = p.x }
            if p.x < minX { minX = p.x }
            if p.y > maxY { maxY = p.y }
            if p.y < minY { minY = p.y }
        }
        return (minX, maxX, minY, maxY)
    }
    
    var angle: Double {
        get {
            if self.x == 0 {
                return (self.y > 0 ? 1 : -1) * Double.pi / 2
            }
            let angle = atan(self.y / self.x)
            return self.x > 0 ? angle : angle + Double.pi
        }
    }
    
    var magnitude: Double {
        get { (pow(self.x, 2) + pow(self.y, 2)).squareRoot() }
    }
}
