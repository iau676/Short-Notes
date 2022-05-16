//
//  NoteCell.swift
//  short note
//
//  Created by ibrahim uysal on 20.02.2022.
//

import UIKit

class NoteCell: UITableViewCell {
    
    @IBOutlet weak var engView: UIView!
    @IBOutlet weak var engLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet var sView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

