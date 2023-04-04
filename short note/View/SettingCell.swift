//
//  SettingCell.swift
//  short note
//
//  Created by ibrahim uysal on 5.04.2023.
//

import UIKit

class SettingCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: SettingViewModel? {
        didSet { configure() }
    }
    
    private lazy var iconView: UIView = {
       let view = UIView()
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.centerY(inView: view)
        
        view.backgroundColor = .clear
        view.setDimensions(height: 32, width: 32)
        view.layer.cornerRadius = 32 / 2
        return view
    }()
    
    private let iconImage: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.setDimensions(height: 18, width: 18)
        iv.tintColor = .white
        return iv
    }()

    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.spacing = 8
        stack.axis = .horizontal
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        iconImage.image = viewModel.iconImage
        titleLabel.text = viewModel.description
    }
}
