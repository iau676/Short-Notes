//
//  UIImage+Extensions.swift
//  short note
//
//  Created by ibrahim uysal on 19.05.2023.
//

import UIKit

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
