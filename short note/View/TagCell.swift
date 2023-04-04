//
//  TagCell.swift
//  short note
//
//  Created by ibrahim uysal on 4.04.2023.
//

import UIKit

final class TagCell: UICollectionViewCell {
    
    //MARK: - Properties

    lazy var emojiLabel = UILabel()
    
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Fonts.AvenirNextRegular, size: UDM.textSize.getCGFloat())
        label.textColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor)
        label.textAlignment = .center
        return label
    }()
    
    private let borderView: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: ThemeManager.shared.currentTheme.backgroundColor)?.cgColor
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.backgroundColor = .clear
        
        let stack = UIStackView(arrangedSubviews: [emojiLabel, countLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        contentView.addSubview(stack)
        stack.centerX(inView: contentView)
        stack.centerY(inView: contentView)
        
        contentView.addSubview(borderView)
        borderView.anchor(top: topAnchor, left: leftAnchor,
                          bottom: bottomAnchor, right: rightAnchor,
                          paddingTop: 8, paddingLeft: 8,
                          paddingBottom: 8, paddingRight: 8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
