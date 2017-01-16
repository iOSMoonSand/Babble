//
//  DiscoverAnswersCell.swift
//  Babble
//
//  Created by Alexis Schreier on 09/27/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

//MARK:
//MARK: - DiscoverAnswersCellDelegate Class Protocol
//MARK:
protocol DiscoverAnswersCellDelegate: class {
    //MARK:
    //MARK: - DiscoverAnswersCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(_ row: Int)
    func handleLikeButtonTapOn(_ row: Int, cell: DiscoverAnswersCell)
}
//MARK:
//MARK: - AnswerCell Class
//MARK:
class DiscoverAnswersCell: UITableViewCell {
    //MARK:
    //MARK: - Attributes
    //MARK:
    @IBOutlet weak var profilePhotoImageButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeButtonCountLabel: UILabel!
    weak var delegate: DiscoverAnswersCellDelegate?
    var row: Int?
    //MARK:
    //MARK: - Instance Methods
    //MARK:
    func updateViewsWith(_ answer: Answer) {
        let answerText = answer.text
        let defaultProfileImage = UIImage(named: "Profile_avatar_placeholder_large")
        self.answerTextView.text = answerText
        self.profilePhotoImageButton.setImage(nil, for: UIControlState())
        self.profilePhotoImageButton.setImage(defaultProfileImage, for: UIControlState())
    }
    //MARK:
    //MARK: - Button Actions
    //MARK:
    @IBAction func profileImageButtonTapped(_ sender: UIButton) {
        guard let row = self.row else { return }
        delegate?.handleProfileImageButtonTapOn(row)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard let row = self.row else { return }
        delegate?.handleLikeButtonTapOn(row, cell: self)
    }
}






