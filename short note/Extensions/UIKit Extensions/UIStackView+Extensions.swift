//
//  UIStackView+Extensions.swift
//  short note
//
//  Created by ibrahim uysal on 24.03.2023.
//

import UIKit
extension UIStackView {
    
    func addBackground(color: UIColor?) {
        let subView = UIView(frame: bounds)
        subView.layer.cornerRadius = 10
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        insertSubview(subView, at: 0)
    }
}
