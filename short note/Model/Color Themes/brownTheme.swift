//
//  brownTheme.swift
//  short note
//
//  Created by ibrahim uysal on 13.04.2023.
//

import Foundation

extension ThemeManager {
    
    var brownTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#AD8B73",
            backgroundColorBottom:            "#CEAB93",
            cellColor:                        "#FFFBE9",
            textColor:                        "#1B262C",
            statusBarStyle: .dark)
    }
}
