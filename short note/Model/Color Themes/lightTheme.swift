//
//  someTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var lightTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#C4C1E0",
            backgroundColorBottom:            "#FFE9E3",
            
            searhcBarColor:                   "#FAFAFA",
            tableViewColor:                   "#FAFAFA",
            cellColor:                        "#FAFAFA",
            segmentedControlColor:            "#FAFAFA",
            
            textColor:                        "#1C1C1C",
            
            statusBarStyle: .dark)
    }
}
