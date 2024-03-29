//
//  NoteCell.swift
//  short note
//
//  Created by ibrahim uysal on 9.02.2023.
//

import UIKit

class NoteCell: UITableViewCell {
    
    //MARK: - Properties
    
    var note: Note? {
        didSet { configure() }
    }
    
    private let noteLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: Fonts.AvenirNextRegular, size: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: Fonts.AvenirNextRegular, size: 15)
        label.textColor = .darkGray
        return label
    }()
    
    private let tagLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: Fonts.AvenirNextRegular, size: 15)
        label.textColor = .darkGray
        return label
    }()
    
    let dayLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: Fonts.AvenirNextRegular, size: 11)
        label.textColor = .white
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        addSubview(noteLabel)
        noteLabel.anchor(top: topAnchor, left: leftAnchor,
                         bottom: bottomAnchor, right: rightAnchor,
                         paddingTop: 16, paddingLeft: 16,
                         paddingBottom: 16, paddingRight: 16)
        
        addSubview(dateLabel)
        dateLabel.anchor(top: topAnchor, right: rightAnchor,
                         paddingTop: 3, paddingRight: 16)
        
        addSubview(tagLabel)
        tagLabel.anchor(top: topAnchor, left: leftAnchor,
                        paddingTop: 4, paddingLeft: 16)
        
        addSubview(dayLabel)
        dayLabel.anchor(left: leftAnchor, bottom: bottomAnchor,
                        paddingLeft: 16, paddingBottom: 3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configure() {
        guard let note = note else { return }
        let viewModel = NoteViewModel(note: note)
        
        noteLabel.text = note.note
        dateLabel.text = viewModel.dateString
        dayLabel.text = viewModel.dayString
        tagLabel.text = viewModel.tagString
        
        noteLabel.textColor = viewModel.textColor
        backgroundColor = viewModel.viewColor
        
        noteLabel.font = tagLabel.font.withSize(viewModel.textSize)
        dateLabel.font = dateLabel.font.withSize(viewModel.textSize-4)
        tagLabel.font = tagLabel.font.withSize(viewModel.tagSize)
    }
}
