//
//  brownTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var darkTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#1C1C1C",
            backgroundColorBottom:            "#1C1C1C",
            
            searhcBarColor:                   "#2B2B2E",
            tableViewColor:                   "#2B2B2E",
            cellColor:                        "#2B2B2E",
            segmentedControlColor:            "#2B2B2E",
            
            textColor:                        "#ffffff",
            
            statusBarStyle: .light)
    }
}
