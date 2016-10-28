//
//  QuestionCell.swift
//  Babble
//
//  Created by Alexis Schreier on 08/12/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

//MARK:
//MARK: - QuestionCellDelegate Class Protocol
//MARK:
protocol QuestionCellDelegate: class {
    //MARK:
    //MARK: - QuestionCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(cell: QuestionCell)
    func handleLikeButtonTapOn(cell: QuestionCell)
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
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var likeButtonCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    weak var delegate: QuestionCellDelegate?
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
        let currentUserID = AppState.sharedInstance.currentUserID
        let fullHeart = UIImage(named: "Hearts-Filled-50")
        let emptyHeart = UIImage(named: "Hearts-50")
        self.likeButton.setImage(emptyHeart, forState: .Normal)
        if let likeStatusDict = question.likeStatuses {
            for (key, value) in likeStatusDict {
                if key == currentUserID {
                    self.likeButton.setImage(fullHeart, forState: .Normal)
                }
            }
            //WHAT YOU NEED TO DO NOW: WHEN USER LIKES A QUESTION, ADD HIS USERID TO THE LIKESTATUSES DICT OF THE QUESTION
            //REPEAT BOTH STEPS ABOVE FOR ANSWERS!!!!!!!!!
            //CHANGE LIKE BUTTON TITLE TO INCLUDE LIKE COUNT?
        }
    }
    //MARK:
    //MARK: - Button Actions
    //MARK:
    @IBAction func didTapProfilePictureButton(sender: UIButton) {

        delegate?.handleProfileImageButtonTapOn(self)
    }
    
    @IBAction func didTapLikeButton(sender: UIButton) {
        delegate?.handleLikeButtonTapOn(self)
    }
    
    
    }














