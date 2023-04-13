//
//  indigoTheme.swift
//  short note
//
//  Created by ibrahim uysal on 13.04.2023.
//

import Foundation

extension ThemeManager {
    
    var indigoTheme: ShortNoteTheme {
        return ShortNoteTheme(
            backgroundColor:                  "#7286D3",
            backgroundColorBottom:            "#8EA7E9",
            cellColor:                        "#FFF2F2",
            textColor:                        "#000000",
            statusBarStyle: .dark)
    }
}
