//
//  purpleTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var purpleTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#A278B5",
            backgroundColorBottom:            "#F6C3E5",
            
            searhcBarColor:                   "#FBDFF0",
            tableViewColor:                   "#FBDFF0",
            cellColor:                        "#FBDFF0",
            segmentedControlColor:            "#FBDFF0",
            
            textColor:                        "#1c1c1c",
            
            statusBarStyle: .dark)
    }
}
