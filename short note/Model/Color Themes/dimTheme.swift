//
//  pinkTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var dimTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#15202b",
            backgroundColorBottom:            "#15202b",
            
            searhcBarColor:                   "#1c2732",
            tableViewColor:                   "#1c2732",
            cellColor:                        "#1c2732",
            segmentedControlColor:            "#1c2732",
            
            textColor:                        "#ffffff",
            
            statusBarStyle: .light)
    }
}
