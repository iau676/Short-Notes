//
//  Factories.swift
//  short note
//
//  Created by ibrahim uysal on 24.03.2023.
//

import UIKit

//MARK: - Label

func makePaddingLabel(withText text: String, backgroundColor: UIColor? = .lightGray,
                      cornerRadius: CGFloat? = 8, textColor: UIColor? = .white) -> UILabel {
    let label = UILabelPadding()
    label.translatesAutoresizingMaskIntoConstraints = false // important!
    label.textAlignment = .left
    label.numberOfLines = 0
    label.text = text
    label.font = UIFont.systemFont(ofSize: 17)
    label.textColor = textColor
    label.backgroundColor = backgroundColor
    label.layer.masksToBounds = true
    label.layer.cornerRadius = cornerRadius ?? 8
    
    return label
}

fileprivate class UILabelPadding: UILabel {
    let padding = UIEdgeInsets(top: 2, left: 16, bottom: 2, right: 8)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
}


//MARK: - Switch

func makeSwitch(isOn: Bool) -> UISwitch {
    let theSwitch = UISwitch()
    theSwitch.isOn = isOn

    return theSwitch
}
