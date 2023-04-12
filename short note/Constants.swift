//
//  Constants.swift
//  short note
//
//  Created by ibrahim uysal on 18.09.2022.
//

import UIKit

enum NoteType: Int {
    case new
    case edit
    case previous
}

enum Colors {
    static let darkBackground            = UIColor(white: 0.1, alpha: 0.4)
    static let blue                      = UIColor(hex: "#759ECC")
    static let cellDark                  = UIColor(hex: "#2B2B2E")
    static let cellLight                 = UIColor(hex: "#F5F5F5")
    static let d6d6d6                    = UIColor(hex: "#D6D6D6")
    static let e5e5e5                    = UIColor(hex: "#E5E5EA")
    static let gray                      = UIColor(hex: "#9E9E9E")
    static let green                     = UIColor(hex: "#66C28C")
    static let purple                    = UIColor(hex: "#9C73AB")
    static let textDark                  = UIColor(hex: "#1C1C1C")
    static let textLight                 = UIColor(hex: "#D1D4DB")
    static let yellow                    = UIColor(hex: "#FFC261")
    static let red                       = UIColor(hex: "#DA7F8F")
    static let placeholderColor          = UIColor(hex: "#626266")
}

enum Images {
    static let menu                      = UIImage(named: "menu")
    static let plus                      = UIImage(named: "plus")
    
    static let checkGreen                = UIImage(named: "checkGreen")
    static let thrash                    = UIImage(named: "thrash")
    static let tag                       = UIImage(named: "tag")
    static let pantone                   = UIImage(named: "pantone")
    static let hide                      = UIImage(named: "hide")
    static let unhide                    = UIImage(named: "unhide")
    static let copy                      = UIImage(named: "copy")
    static let returN                    = UIImage(named: "return")
    static let recover                   = UIImage(named: "recover")
    static let edit                      = UIImage(named: "edit")
    
    static let pdf                       = UIImage(named: "pdf")
    static let share                     = UIImage(named: "share")
    static let tagBlack                  = UIImage(named: "tagBlack")
    static let pantoneBlack              = UIImage(named: "pantoneBlack")
    static let hideBlack                 = UIImage(named: "hideBlack")
    static let thrashBlack               = UIImage(named: "thrashBlack")
    static let settings                  = UIImage(named: "settings")
    static let settingsBlack             = UIImage(named: "settingsBlack")
}

enum Fonts {
    static let AvenirNextRegular         = "AvenirNext-Regular"
    static var AvenirNextDemiBold        = "AvenirNext-DemiBold"
}

enum UDM {
    static let tagSize                   = UserDefaultsManager(key: "tagSize")
    static let textSize                  = UserDefaultsManager(key: "textSize")
    static let segmentAt1                = UserDefaultsManager(key: "segmentAt1")
    static let segmentAt2                = UserDefaultsManager(key: "segmentAt2")
    static let segmentAt3                = UserDefaultsManager(key: "segmentAt3")
    static let segmentAt4                = UserDefaultsManager(key: "segmentAt4")
    static let segmentAt5                = UserDefaultsManager(key: "segmentAt5")
    
    static let showHour                  = UserDefaultsManager(key: "showHour")
    static let switchShowLabel           = UserDefaultsManager(key: "switchShowLabel")
    static let switchShowDate            = UserDefaultsManager(key: "switchShowDate")
    static let switchNote                = UserDefaultsManager(key: "switchNote")
    static let switchDoubleClick         = UserDefaultsManager(key: "switchDoubleClick")

    static let segmentIndexForDate       = UserDefaultsManager(key: "segmentIndexForDate")
    static let segmentIndexForHour       = UserDefaultsManager(key: "segmentIndexForHour")
    static let selectedDateFormat        = UserDefaultsManager(key: "selectedDateFormat")
    static let selectedHourFormat        = UserDefaultsManager(key: "selectedHourFormat")
    static let selectedTimeFormat        = UserDefaultsManager(key: "selectedTimeFormat")
    static let isDefault                 = UserDefaultsManager(key: "isDefault")
    
    static let textEdit                  = UserDefaultsManager(key: "textEdit")
    static let lastNote                  = UserDefaultsManager(key: "lastNote")
    
    static let selectedSegmentIndex      = UserDefaultsManager(key: "selectedSegmentIndex")
    
    static let themeIndex = UserDefaultsManager(key: "com.ibrahimuysal.short-note.ThemeManager.ThemeIndex")
}

