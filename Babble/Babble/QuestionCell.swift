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
    func handleProfileImageButtonTapOn(_ cell: QuestionCell)
    func handleLikeButtonTapOn(_ cell: QuestionCell)
}
//MARK:
//MARK: - QuestionCell Class
//MARK:
class QuestionCell: UITableViewCell {
    //MARK:
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var profilePhotoImageButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var likeButtonCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    weak var delegate: QuestionCellDelegate?
    var row: Int?
    //MARK:
    //MARK: - Instance Methods
    //MARK:
    func updateViewsWith(_ question: Question) {
        let questionText = question.text
        let likeCount = question.likeCount
        let defaultProfileImage = UIImage(named: "Profile_avatar_placeholder_large")
        self.questionTextLabel.text = questionText
        self.profilePhotoImageButton.setImage(nil, for: UIControlState())
        self.profilePhotoImageButton.setImage(defaultProfileImage, for: UIControlState())
        self.likeButtonCountLabel.text = String(likeCount)
        let currentUserID = AppState.sharedInstance.currentUserID
        let fullHeart = UIImage(named: "Hearts-Filled-50")
        let emptyHeart = UIImage(named: "Hearts-50")
        self.likeButton.setImage(emptyHeart, for: UIControlState())
        if let likeStatusDict = question.likeStatuses {
            for (key, value) in likeStatusDict {
                if key == currentUserID {
                    self.likeButton.setImage(fullHeart, for: UIControlState())
                }
            }
        }
    }
    //MARK:
    //MARK: - Button Actions
    //MARK:
    @IBAction func didTapProfilePictureButton(_ sender: UIButton) {
        
        delegate?.handleProfileImageButtonTapOn(self)
    }
    
    @IBAction func didTapLikeButton(_ sender: UIButton) {
        delegate?.handleLikeButtonTapOn(self)
    }
}














