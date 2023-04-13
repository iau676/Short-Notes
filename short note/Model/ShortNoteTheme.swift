//
//  ShortNoteTheme.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

enum StatusBarStyle {
    case light
    case dark
}

struct ShortNoteTheme {
    let backgroundColor: String
    let backgroundColorBottom: String
    let cellColor: String
    let textColor: String
    let statusBarStyle: StatusBarStyle
}
