//
//  CGPoint+.swift
//  railroad-switch
//
//  Created by Rintaro Kawagishi on 02/01/2022.
//

import CoreGraphics

extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
}
