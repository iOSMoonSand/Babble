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
    func handleProfileImageButtonTapOn(row: Int)
    func handleLikeButtonTapOn(row: Int, cell: DiscoverQuestionCell)
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
    var question = [String : AnyObject]()
    var row: Int?
    //MARK:
    //MARK: - Instance Methods
    //MARK:
    func updateViewsWith(question: Question) {
        let questionText = question.text
        let likeCount = question.likeCount
        let defaultProfileImage = UIImage(named: "Profile_avatar_placeholder_large")
        self.questionTextView.text = questionText
        self.profilePhotoImageButton.setImage(nil, forState: .Normal)
        self.profilePhotoImageButton.setImage(defaultProfileImage, forState: .Normal)
        self.likeButtonCountLabel.text = String(likeCount)
    }
    //MARK:
    //MARK: - Button Actions
    //MARK:
    @IBAction func profileImageButtonTapped(sender: UIButton) {
        guard let row = self.row else { return }
        delegate?.handleProfileImageButtonTapOn(row)
    }
    
    @IBAction func likeButtonTapped(sender: UIButton) {
        guard let row = self.row else { return }
        delegate?.handleLikeButtonTapOn(row, cell: self)
    }
}
