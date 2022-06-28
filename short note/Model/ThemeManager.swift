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
    var sn = ShortNote()
    
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
        themes = [blueTheme, purpleTheme, pinkTheme, greenTheme, redTheme, yellowTheme, orangeTheme, brownTheme, grayTheme, lightTheme]
    }
    
    
    // MARK: - Save & Restore To Disk
    
    private func restoreSavedThemeIndex() {
        
        savedThemeIndex = 0
        if let previousThemeIndex = UserDefaults.standard.object(forKey: sn.themeIndex) as? Int {
            savedThemeIndex = previousThemeIndex
        }
        savedTheme = themes[savedThemeIndex]
    }
    
    private func saveThemeIndexToDisk() {
        sn.setValue(savedThemeIndex, sn.themeIndex)
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
    
}
