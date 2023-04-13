//
//  ThemeManager.swift
//  short note
//
//  Created by ibrahim uysal on 28.06.2022.
//

import Foundation

class ThemeManager {
    
    // MARK: - Singleton
    
    static let shared = ThemeManager()
    
    // MARK: - Themes
    
    private var savedThemeIndex = 0
    private(set) var themes: [ShortNoteTheme] = []
    private var savedTheme: ShortNoteTheme?
    var currentTheme: ShortNoteTheme {
        guard let savedTheme = savedTheme else {
            return themes.first ?? purpleTheme
        }
        
        return savedTheme
    }
    
    // MARK: - Lifecycle
    
    init() {
        populateArrayOfThemes()
        restoreSavedThemeIndex()
    }
    
    private func populateArrayOfThemes() {
        themes = [blueTheme, indigoTheme, purpleTheme, redTheme, pinkTheme,
                  greenTheme, greenTheme2, yellowTheme, orangeTheme, brownTheme,
                  grayTheme, grayTheme2, grayTheme3, grayTheme4, grayTheme5,
                  dimTheme, darkTheme, lightTheme, lightTheme2, lightTheme3,
                  lightTheme4, lightTheme5, lightTheme6, lightTheme7, lightTheme8,
                  lightTheme9, lightTheme10, lightTheme11, lightTheme12, lightTheme13]
    }
    
    
    // MARK: - Save & Restore To Disk
    
    private func restoreSavedThemeIndex() {
        savedThemeIndex = UDM.themeIndex.getInt()
        savedTheme = themes[savedThemeIndex]
    }
    
    private func saveThemeIndexToDisk() {
        UDM.themeIndex.set(savedThemeIndex)
    }
    
    // MARK: - Next Theme
    
    func moveToNextTheme() {
        
        savedThemeIndex = savedThemeIndex + 1
        if savedThemeIndex > themes.count - 1 {
            savedThemeIndex = 0
        }
        
        savedTheme = themes[savedThemeIndex]
        saveThemeIndexToDisk()
    }
    
    func updateTheme(withIndex index: Int) {
        savedThemeIndex = index
        savedTheme = themes[savedThemeIndex]
        saveThemeIndexToDisk()
    }
    
}
