//
//  SettingViewModel.swift
//  short note
//
//  Created by ibrahim uysal on 5.04.2023.
//

import UIKit

enum SettingViewModel: Int, CaseIterable {
    case tags
    case themes
    case hidden
    case createPDF
    case noteSettings
    case recentlyDeleted
    
    var description: String {
        switch self {
        case .tags: return "Tags"
        case .themes: return "Themes"
        case .hidden: return "Hidden"
        case .createPDF: return "Create PDF"
        case .noteSettings: return "Note Settings"
        case .recentlyDeleted: return "Recently Deleted"
        }
    }
    
    var iconImage: UIImage? {
        var image: UIImage?
        
        switch self {
        case .tags: image = Images.tagBlack
        case .themes: image = Images.pantoneBlack
        case .hidden: image = Images.hideBlack
        case .createPDF: image = Images.pdf
        case .noteSettings: image = Images.settingsBlack
        case .recentlyDeleted: image = Images.thrashBlack
        }
        
        if #available(iOS 13.0, *) {
            let tintColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor) ?? .black
            return image?.withTintColor(tintColor)
        } else {
            return image
        }
    }
}
