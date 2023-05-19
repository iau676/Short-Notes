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
    case createPDF
    case hidden
    case noteSettings
    case recentlyDeleted
    
    var description: String {
        switch self {
        case .tags: return "Tags"
        case .themes: return "Themes"
        case .createPDF: return "Create PDF"
        case .hidden: return "Hidden"
        case .noteSettings: return "Note Settings"
        case .recentlyDeleted: return "Recently Deleted"
        }
    }
    
    var iconImage: UIImage? {
        var image: UIImage?
        
        switch self {
        case .tags: image = Images.tag
        case .themes: image = Images.pantone
        case .createPDF: image = Images.pdf
        case .hidden: image = Images.hide
        case .noteSettings: image = Images.settings
        case .recentlyDeleted: image = Images.thrash
        }
        return image?.withTintColor(UIColor(hex: ThemeManager.shared.currentTheme.textColor) ?? .black).imageResized(to: CGSize(width: 32, height: 32))
    }
}
