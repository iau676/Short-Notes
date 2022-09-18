//
//  bloodOrangeTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var greenTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#91C788",
            backgroundColorBottom:            "#DDFFBC",
            
            searhcBarColor:                   "#FEFFDE",
            tableViewColor:                   "#FEFFDE",
            cellColor:                        "#FEFFDE",
            segmentedControlColor:            "#FEFFDE",
            
            textColor:                        "#1c1c1c",
            
            statusBarStyle: .dark)
    }
}
