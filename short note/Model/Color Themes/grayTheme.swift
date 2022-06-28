//
//  darkBlueTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var grayTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#AAA492",
            backgroundColorBottom:            "#C7BEA2",
            
            searhcBarColor:                   "#E5DCC3",
            tableViewColor:                   "#E5DCC3",
            cellColor:                        "#E5DCC3",
            segmentedControlColor:            "#E5DCC3",
            
            textColor:                        "#1C1C1C",
            
            statusBarStyle: .dark)
    }
}
