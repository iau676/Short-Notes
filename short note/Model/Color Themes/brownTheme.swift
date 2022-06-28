//
//  brownTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

extension ThemeManager {
    
    var brownTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#C19277",
            backgroundColorBottom:            "#E1BC91",
            
            searhcBarColor:                   "#E3D0B9",
            tableViewColor:                   "#E3D0B9",
            cellColor:                        "#E3D0B9",
            segmentedControlColor:            "#E3D0B9",
            
            textColor:                        "#2B2B2E",
            
            statusBarStyle: .dark)
    }
}
