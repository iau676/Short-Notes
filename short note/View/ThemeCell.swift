//
//  ThemeCell.swift
//  short note
//
//  Created by ibrahim uysal on 4.04.2023.
//

import UIKit

final class ThemeCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var theme: Theme? {
        didSet { configure() }
    }
    
    private let borderView: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor)?.cgColor
        return view
    }()
    
    private let backgroundColorView = UIView()
    private let backgroundColorBottomView = UIView()
    private let tableViewColorView = UIView()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.addSubview(borderView)
        borderView.anchor(top: topAnchor, left: leftAnchor,
                          bottom: bottomAnchor, right: rightAnchor,
                          paddingTop: 8, paddingLeft: 8,
                          paddingBottom: 8, paddingRight: 8)
        
        let stack = UIStackView(arrangedSubviews: [backgroundColorView, backgroundColorBottomView,
                                                   tableViewColorView])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        
        contentView.addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor,
                     bottom: bottomAnchor, right: rightAnchor,
                     paddingTop: 11, paddingLeft: 11,
                     paddingBottom: 11, paddingRight: 11)
        
        tableViewColorView.layer.cornerRadius = 12
        tableViewColorView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        backgroundColorView.layer.cornerRadius = 12
        backgroundColorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let theme = theme else { return }
        
        backgroundColorView.backgroundColor = UIColor(hex: theme.backgroundColorHex)
        backgroundColorBottomView.backgroundColor = UIColor(hex: theme.backgroundColorBottomHex)
        tableViewColorView.backgroundColor = UIColor(hex: theme.tableViewColorHex)
        borderView.isHidden = UDM.themeIndex.getInt() != theme.index
    }
}
