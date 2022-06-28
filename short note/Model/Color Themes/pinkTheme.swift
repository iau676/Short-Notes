//
//  pinkTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var pinkTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#EA86B6",
            backgroundColorBottom:            "#F3BAD6",
            
            searhcBarColor:                   "#FCEEF5",
            tableViewColor:                   "#FCEEF5",
            cellColor:                        "#FCEEF5",
            segmentedControlColor:            "#FCEEF5",
            
            textColor:                        "#1c1c1c",
            
            statusBarStyle: .dark)
    }
}
