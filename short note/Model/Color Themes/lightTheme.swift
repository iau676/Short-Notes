//
//  lightTheme.swift
//  short note
//
//  Created by ibrahim uysal on 13.04.2023.
//

import Foundation

extension ThemeManager {
    
    var lightTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#9E7676",
            backgroundColorBottom:            "#FFF8EA",
            cellColor:                        "#F9F7F7",
            textColor:                        "#000000",
            statusBarStyle: .dark)
    }
}
