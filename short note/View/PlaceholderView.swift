//
//  TableViewPlaceholderView.swift
//  short note
//
//  Created by ibrahim uysal on 12.04.2023.
//

import UIKit

class PlaceholderView: UIView {
    
    private let imageView: UIImageView = {
        let image = Images.tag
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.placeholderColor
        return imageView
    }()
        
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No tag yet"
        label.font = UIFont(name: Fonts.AvenirNextRegular, size: 25)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = Colors.placeholderColor
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 88)
        ])
    }
}
