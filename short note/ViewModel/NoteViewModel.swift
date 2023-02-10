//
//  NoteViewModel.swift
//  short note
//
//  Created by ibrahim uysal on 9.02.2023.
//

import UIKit

struct NoteViewModel {
    
    private let note: Note
    
    private let darkMode = UDM.getIntValue("darkMode")

    var viewColor: UIColor? {
        return darkMode == 1 ? Colors.cellDark : UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
    }
    
    var textColor: UIColor? {
        return darkMode == 1 ? Colors.textLight : UIColor(hex: ThemeManager.shared.currentTheme.textColor)
    }
    
    var textSize: CGFloat {
        return UDM.getCGFloatValue("textSize")
    }
    
    var tagSize: CGFloat {
        return UDM.getCGFloatValue("tagSize")
    }
    
    var shouldShowTag: Bool {
        return UDM.getIntValue("switchShowLabel") == 1
    }
    
    var dateString: String? {
        return note.date?.getFormattedDate(format: UDM.getStringValue(UDM.selectedTimeFormat))
    }

    init(note: Note) {
        self.note = note
    }    
}
