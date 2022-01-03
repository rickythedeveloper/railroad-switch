//
//  Date+.swift
//  railroad-switch
//
//  Created by Rintaro Kawagishi on 03/01/2022.
//

import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
