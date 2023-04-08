//
//  NoteViewModel.swift
//  short note
//
//  Created by ibrahim uysal on 9.02.2023.
//

import UIKit

struct NoteViewModel {
    
    private let note: Note

    var viewColor: UIColor? {
        return UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
    }
    
    var textColor: UIColor? {
        return UIColor(hex: ThemeManager.shared.currentTheme.textColor)
    }
    
    var textSize: CGFloat {
        return UDM.textSize.getCGFloat()
    }
    
    var tagSize: CGFloat {
        return UDM.tagSize.getCGFloat()
    }
    
    var shouldShowTag: Bool {
        return UDM.switchShowLabel.getInt() == 1
    }
    
    var tagString: String? {
        return shouldShowTag ? note.label : ""
    }
    
    var dateString: String? {
        return note.date?.getFormattedDate(format: UDM.selectedTimeFormat.getString())
    }
    
    var dayString: String {
        if note.isDeletedd == 1 {
            if let deleteDate = note.deleteDate {
                let dateComponents = Calendar.current.dateComponents([.day],
                                                                     from: deleteDate,
                                                                     to: Date())
                if let daysCount = dateComponents.day {
                    let days = 30 - daysCount
                    return (days > 1 ? "\(days) days" : "\(days) day")
                }
            }
        }
        return ""
    }

    init(note: Note) {
        self.note = note
    }    
}
