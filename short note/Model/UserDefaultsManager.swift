//
//  UserDefaultsManager.swift
//  short note
//
//  Created by ibrahim uysal on 9.02.2023.
//

import UIKit

struct UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    let tagSize = "tagSize"
    let textSize = "textSize"
    let segmentAt1 = "segmentAt1"
    let segmentAt2 = "segmentAt2"
    let segmentAt3 = "segmentAt3"
    let segmentAt4 = "segmentAt4"
    let segmentAt5 = "segmentAt5"
    
    let showHour = "showHour"
    let switchShowLabel = "switchShowLabel"
    let switchShowDate = "switchShowDate"
    let switchNote = "switchNote"
    
    let segmentIndexForDate = "segmentIndexForDate"
    let segmentIndexForHour = "segmentIndexForHour"
    let selectedDateFormat = "selectedDateFormat"
    let selectedHourFormat = "selectedHourFormat"
    let selectedTimeFormat = "selectedTimeFormat"
    let isDefault = "isDefault"
    
    let lastBgColor = "lastBgColor"
    
    let textEdit = "textEdit"
    let lastNote = "lastNote"
    
    let selectedSegmentIndex = "selectedSegmentIndex"
    
    let themeIndex = "com.ibrahimuysal.short-note.ThemeManager.ThemeIndex"
    
    func getCGFloatValue(_ key: String) -> CGFloat {
       return CGFloat(UserDefaults.standard.integer(forKey: key))
    }
    
    func getIntValue(_ key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func getStringValue(_ key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    func setValue( _ value: Any, _ key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
