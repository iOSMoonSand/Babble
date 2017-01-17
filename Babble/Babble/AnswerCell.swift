//
//  AnswerCell.swift
//  Babble
//
//  Created by Alexis Schreier on 08/12/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

//MARK:
//MARK: - AnswerCellDelegate Class Protocol
//MARK:
protocol AnswerCellDelegate: class {
    //MARK:
    //MARK: - AnswerCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(_ cell: AnswerCell)
}
//MARK:
//MARK: - AnswerCell Class
//MARK:
class AnswerCell: UITableViewCell {
    //MARK:
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var profilePhotoImageButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var answerTextLabel: UILabel!
    weak var delegate: AnswerCellDelegate?
    var answer = [String: AnyObject]()
    var row: Int?
    //MARK:
    //MARK: - Instance Methods
    //MARK:
    func updateViewsWith(_ answer: Answer) {
        let answerText = answer.text
        let defaultProfileImage = UIImage(named: "Profile_avatar_placeholder_large")
        self.answerTextLabel.text = answerText
        self.profilePhotoImageButton.setImage(nil, for: UIControlState())
        self.profilePhotoImageButton.setImage(defaultProfileImage, for: UIControlState())
    }
    //MARK:
    //MARK: - Button Actions
    //MARK:
    @IBAction func profileImageButtonTapped(_ sender: UIButton) {
        delegate?.handleProfileImageButtonTapOn(self)
    }
}






















