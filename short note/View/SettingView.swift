//
//  SettingView.swift
//  short note
//
//  Created by ibrahim uysal on 9.02.2023.
//

import UIKit

class SettingView: UIView {
    
    //MARK: - Properties
    
    private let darkMode = UDM.getIntValue("darkMode")
    private let textSize = UDM.getCGFloatValue("textSize")
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize)
        label.textColor = darkMode == 1 ? Colors.textLight : UIColor(hex: ThemeManager.shared.currentTheme.textColor)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = darkMode == 1 ? Colors.cellDark : UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        layer.cornerRadius = 10
       
    }
    
    override func layoutSubviews() {
        addSubview(label)
        if frame.height > 90 {
            label.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner,
                                   .layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if frame.height > 50 {
            label.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            label.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
