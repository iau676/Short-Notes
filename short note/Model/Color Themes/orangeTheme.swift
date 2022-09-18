//
//  pinkTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var orangeTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#DF7861",
            backgroundColorBottom:            "#ECB390",
            
            searhcBarColor:                   "#ECDFC8",
            tableViewColor:                   "#ECDFC8",
            cellColor:                        "#ECDFC8",
            segmentedControlColor:            "#ECDFC8",
            
            textColor:                        "#2B2B2E",
            
            statusBarStyle: .dark)
    }
}
