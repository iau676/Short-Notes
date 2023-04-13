//
//  pinkTheme.swift
//  short note
//
//  Created by ibrahim uysal on 13.04.2023.
//

import Foundation

extension ThemeManager {
    
    var pinkTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#EA86B6",
            backgroundColorBottom:            "#F3BAD6",
            cellColor:                        "#FCEEF5",
            textColor:                        "#000000",
            statusBarStyle: .dark)
    }
}
