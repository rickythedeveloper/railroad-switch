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
}
