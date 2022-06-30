//
//  blueTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var blueTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#83a9d3",
            backgroundColorBottom:            "#b1cfe6",
            
            searhcBarColor:                   "#F9F7F7",
            tableViewColor:                   "#F9F7F7",
            cellColor:                        "#F9F7F7",
            segmentedControlColor:            "#F9F7F7",
            
            textColor:                        "#1C1C1C",
            
            statusBarStyle: .dark)
    }
}
