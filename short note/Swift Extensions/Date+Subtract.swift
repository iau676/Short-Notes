//
//  Date+Subtract.swift
//  short note
//
//  Created by ibrahim uysal on 18.06.2022.
//

import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
