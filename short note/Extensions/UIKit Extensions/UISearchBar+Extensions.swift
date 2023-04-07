//
//  UISearchBar+Extensions.swift
//  short note
//
//  Created by ibrahim uysal on 7.04.2023.
//

import UIKit

extension UISearchBar {
    func updateTextField() {
        let textFieldInsideUISearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor)
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(UDM.textSize.getCGFloat())
    }
}
