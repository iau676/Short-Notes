//
//  UIButton+Extensions.swift
//  short note
//
//  Created by ibrahim uysal on 18.06.2022.
//

import UIKit


extension UIButton {
    func moveImageLeftTextCenter(imagePadding: CGFloat = 32.0){
        guard let imageViewWidth = self.imageView?.frame.width else{return}
        guard let titleLabelWidth = self.titleLabel?.intrinsicContentSize.width else{return}
        self.contentHorizontalAlignment = .left
        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: imagePadding - imageViewWidth / 2, bottom: 0.0, right: 0.0)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: (bounds.width - titleLabelWidth) / 2 - imageViewWidth, bottom: 0.0, right: 0.0)
    }
    
    func setImage(image: UIImage?, width: CGFloat, height: CGFloat){
        self.setImage(UIGraphicsImageRenderer(size: CGSize(width: width, height: height)).image { _ in
            image?.draw(in: CGRect(x: 0, y: 0, width: width, height: height)) }, for: .normal)
    }
}
