//
//  QuestionCell.swift
//  Babble
//
//  Created by Alexis Schreier on 08/12/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

//MARK:
//MARK: - QuestionCellDelegate Class Protocol
//MARK:
protocol QuestionCellDelegate: class {
    //MARK:
    //MARK: - QuestionCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(row: Int)
    func handleLikeButtonTapOn(row: Int)
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
    var question = [String : AnyObject]()
    var row: Int?
    //MARK:
    //MARK: - Instance Methods
    //MARK:
    func performWithQuestion(question: [String : AnyObject]) {
        //unpack local question data
        self.question = question
        self.profilePhotoImageButton.setBackgroundImage(nil, forState: .Normal)
        let questionText = self.question[Constants.QuestionFields.text] as! String
        let questionID = self.question[Constants.QuestionFields.questionID] as! String
        let userID = self.question[Constants.QuestionFields.userID] as! String
        self.questionTextLabel.text = questionText
        //retrieve likeCount from Firebase
        FirebaseConfigManager.sharedInstance.ref.child("likeCounts").child(questionID).observeEventType(.Value, withBlock: {(likeCountSnapshot) in
            let likeCountDict = likeCountSnapshot.value as! [String: AnyObject]
            if self.question[Constants.QuestionFields.questionID] as! String == likeCountSnapshot.key {
                guard let likeCount = likeCountDict[Constants.LikeCountFields.likeCount] else { return }
                guard let likeStatus = likeCountDict[Constants.LikeCountFields.likeStatus] as! Int? else { return }
                if likeStatus == 0 {
                    let fullHeartImage = UIImage(named: "heart-full")
                    self.likeButton.setBackgroundImage(fullHeartImage, forState: .Normal)
                } else if likeStatus == 1 {
                    let emptyHeartImage = UIImage(named: "heart-empty")
                    self.likeButton.setBackgroundImage(emptyHeartImage, forState: .Normal)
                }
                self.question[Constants.QuestionFields.likeCount] = likeCount
                self.likeButtonCountLabel.text = String(likeCount)
            }
        })
        //retrieve photoURL and displayName from Firebase
        FirebaseConfigManager.sharedInstance.ref.child("users").child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
            var user = userSnapshot.value as! [String: AnyObject]
            if self.question[Constants.QuestionFields.userID] as! String == userSnapshot.key {
                let photoURL = user[Constants.UserFields.photoUrl] as! String
                let displayName = user[Constants.UserFields.displayName] as! String
                self.question[Constants.QuestionFields.photoUrl] = photoURL
                self.question[Constants.QuestionFields.displayName] = displayName
                self.displayNameLabel.text = displayName
                if let photoUrl = self.question[Constants.QuestionFields.photoUrl] {
                    FIRStorage.storage().referenceForURL(photoUrl as! String).dataWithMaxSize(INT64_MAX) { (data, error) in
                        self.profilePhotoImageButton.setBackgroundImage(nil, forState: .Normal)
                        if error != nil {
                            print("Error downloading: \(error)")
                            return
                        } else {
                            let image = UIImage(data: data!)
                            self.profilePhotoImageButton.setBackgroundImage(image, forState: .Normal)
                        }
                    }
                } else if let photoUrl = self.question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl as! String), data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    self.profilePhotoImageButton.setBackgroundImage(image, forState: .Normal)
                    
                } else {
                    let image = UIImage(named: "ic_account_circle")
                    self.profilePhotoImageButton.setBackgroundImage(image, forState: .Normal)
                }
            }
        })
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
        delegate?.handleLikeButtonTapOn(row)
    }
}
