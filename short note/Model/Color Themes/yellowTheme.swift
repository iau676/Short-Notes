//
//  someTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var yellowTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#E2C275",
            backgroundColorBottom:            "#EADCA6",
            
            searhcBarColor:                   "#F4F4F4",
            tableViewColor:                   "#F4F4F4",
            cellColor:                        "#F4F4F4",
            segmentedControlColor:            "#F4F4F4",
            
            textColor:                        "#1C1C1C",
            
            statusBarStyle: .dark)
    }
}
