//
//  QuestionCell.swift
//  Babble
//
//  Created by Alexis Schreier on 08/12/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
protocol QuestionCellDelegate: class {
    func handleButtonTapOn(row: Int)
}
//MARK:
//MARK: - QuestionCell Class
//MARK:
class QuestionCell: UITableViewCell {
    //MARK:
    //MARK: - Attributes
    //MARK:
    @IBOutlet weak var profilePhotoImageButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var likeButtonCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    weak var delegate: QuestionCellDelegate?
    var row: Int?
    
    @IBAction func buttonTapped(sender: UIButton) {
        guard let row = row else { return }
        delegate?.handleButtonTapOn(row)
    }
    
}
