//
//  CGPoint+.swift
//  railroad-switch
//
//  Created by Rintaro Kawagishi on 02/01/2022.
//

import CoreGraphics

extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
    
    static func getDistanceBetween(_ point1: CGPoint,_ point2: CGPoint) -> Double {
        let delta = point1 - point2
        return (pow(Double(delta.x), 2) + pow(Double(delta.y), 2)).squareRoot()
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
}
