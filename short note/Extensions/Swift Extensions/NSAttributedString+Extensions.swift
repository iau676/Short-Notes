//
//  NSAttributedString+Extensions.swift
//  short note
//
//  Created by ibrahim uysal on 6.04.2023.
//

import UIKit

extension NSAttributedString {

    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
    
        return ceil(boundingBox.height)
    }
}
