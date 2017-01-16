//
//  DiscoverQuestionCell.swift
//  Babble
//
//  Created by Alexis Schreier on 09/27/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

//MARK:
//MARK: - DiscoverQuestionCellDelegate Class Protocol
//MARK:
protocol DiscoverQuestionCellDelegate: class {
    //MARK:
    //MARK: - DiscoverQuestionCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(_ row: Int)
    func handleLikeButtonTapOn(_ row: Int, cell: DiscoverQuestionCell)
}
//MARK:
//MARK: - DiscoverQuestionCell Class
//MARK:
class DiscoverQuestionCell: UITableViewCell {
    //MARK:
    //MARK: - Attributes
    //MARK:
    @IBOutlet weak var profilePhotoImageButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var likeButtonCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    weak var delegate: DiscoverQuestionCellDelegate?
    var row: Int?
    //MARK:
    //MARK: - Instance Methods
    //MARK:
    func updateViewsWith(_ question: Question) {
        let questionText = question.text
        let likeCount = question.likeCount
        let defaultProfileImage = UIImage(named: "Profile_avatar_placeholder_large")
        self.questionTextView.text = questionText
        self.profilePhotoImageButton.setImage(nil, for: UIControlState())
        self.profilePhotoImageButton.setImage(defaultProfileImage, for: UIControlState())
        self.likeButtonCountLabel.text = String(likeCount)
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
