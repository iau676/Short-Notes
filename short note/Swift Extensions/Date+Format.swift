//
//  Swift+Extensions.swift
//  short note
//
//  Created by ibrahim uysal on 11.06.2022.
//

import Foundation

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
