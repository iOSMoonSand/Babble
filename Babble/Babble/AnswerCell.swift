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
    func handleProfileImageButtonTapOn(row: Int)
    func handleLikeButtonTapOn(row: Int, cell: AnswerCell)
}
//MARK:
//MARK: - AnswerCell Class
//MARK:
class AnswerCell: UITableViewCell {
    //MARK:
    //MARK: - Attributes
    //MARK:
    @IBOutlet weak var profilePhotoImageButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeButtonCountLabel: UILabel!
    weak var delegate: AnswerCellDelegate?
    var answer = [String: AnyObject]()
    var row: Int?
    //MARK:
    //MARK: - Instance Methods
    //MARK:
    func updateViewsWith(answer: Answer) {
        let answerText = answer.text
        let likeCount = answer.likeCount
        let defaultProfileImage = UIImage(named: "Profile_avatar_placeholder_large")
        self.answerTextView.text = answerText
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
