//
//  grayTheme2.swift
//  short note
//
//  Created by ibrahim uysal on 13.04.2023.
//

import Foundation

extension ThemeManager {
    
    var grayTheme2: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#888888",
            backgroundColorBottom:            "#F0F0F0",
            cellColor:                        "#FFFFFF",
            textColor:                        "#000000",
            statusBarStyle: .dark)
    }
}
