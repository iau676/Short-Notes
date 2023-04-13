//
//  redTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var redTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#C86B85",
            backgroundColorBottom:            "#E6A4B4",
            cellColor:                        "#F5EEE6",
            textColor:                        "#2B2B2E",
            statusBarStyle: .dark)
    }
}
