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
        switch self {
        case .tags: return Images.tagBlack
        case .themes: return Images.pantoneBlack
        case .hidden: return Images.hideBlack
        case .createPDF: return Images.pdf
        case .noteSettings: return Images.settingsBlack
        case .recentlyDeleted: return Images.thrashBlack
        }
    }
}
