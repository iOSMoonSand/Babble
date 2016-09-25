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
    //@IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var likeButtonCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    weak var delegate: QuestionCellDelegate?
    var question = [String : AnyObject]()
    var row: Int?
    //MARK:
    //MARK: - Instance Methods
    //MARK:
    func performWithQuestion(question: [String : AnyObject]) {
        
        self.questionTextView.contentInset = UIEdgeInsetsMake(self.questionTextView.contentInset.top, -5, self.questionTextView.contentInset.bottom, self.questionTextView.contentInset.right)
        
        //unpack local question data
        self.question = question
        self.profilePhotoImageButton.setImage(nil, forState: .Normal)
        let questionText = self.question[Constants.QuestionFields.text] as! String
        let questionID = self.question[Constants.QuestionFields.questionID] as! String
        let userID = self.question[Constants.QuestionFields.userID] as! String
        self.questionTextView.text = questionText
        //retrieve likeCount from Firebase
        FirebaseConfigManager.sharedInstance.ref.child("likeCounts").child(questionID).observeEventType(.Value, withBlock: {(likeCountSnapshot) in
            let likeCountDict = likeCountSnapshot.value as! [String: Int]
            if self.question[Constants.QuestionFields.questionID] as! String == likeCountSnapshot.key {
                guard let currentLikeCount = likeCountDict[Constants.LikeCountFields.likeCount] else { return }
                self.question[Constants.QuestionFields.likeCount] = currentLikeCount
                self.likeButtonCountLabel.text = String(currentLikeCount)
                FirebaseConfigManager.sharedInstance.ref.child("questions/\(questionID)/likeCount").setValue(currentLikeCount)
            }
        })
        //retrieve or create likeStatus from/in Firebase
        FirebaseConfigManager.sharedInstance.ref.child("likeStatuses").child(questionID).observeEventType(.Value, withBlock: { (likeStatusSnapshot) in
            let likeStatusForUsersDict = likeStatusSnapshot.value as! [String: [String: Int]]
            if self.question[Constants.QuestionFields.questionID] as! String == likeStatusSnapshot.key {
                guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
                for (key, value) in likeStatusForUsersDict {
                    if key == FIRAuth.auth()?.currentUser?.uid {
                        let likeStatusForUser = value
                        let likeStatus = likeStatusForUser[Constants.LikeStatusFields.likeStatus]
                        if likeStatus == 1 {
                            let fullHeartImage = UIImage(named: "heart-full")
                            self.likeButton.setBackgroundImage(fullHeartImage, forState: .Normal)
                        } else if likeStatus == 0 {
                            let emptyHeartImage = UIImage(named: "heart-empty")
                            self.likeButton.setBackgroundImage(emptyHeartImage, forState: .Normal)
                        }
                    }
                    if likeStatusForUsersDict[currentUserID] == nil {
                        let currentAnswerID = self.question[Constants.QuestionFields.questionID] as! String
                        FirebaseConfigManager.sharedInstance.ref.child("likeStatuses/\(currentAnswerID)/\(currentUserID)/likeStatus").setValue(0)
                        let emptyHeartImage = UIImage(named: "heart-empty")
                        self.likeButton.setBackgroundImage(emptyHeartImage, forState: .Normal)
                    }
                }
            }
        })
        //retrieve photoURL and displayName from Firebase
        FirebaseConfigManager.sharedInstance.ref.child("users").child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
            var user = userSnapshot.value as! [String: AnyObject]
            if self.question[Constants.QuestionFields.userID] as! String == userSnapshot.key {
                let photoURL = user[Constants.UserFields.photoURL] as! String
                let displayName = user[Constants.UserFields.displayName] as! String
                if let photoDownloadURL = user[Constants.UserFields.photoDownloadURL] {
                    self.question[Constants.QuestionFields.photoDownloadURL] = photoDownloadURL
                }
                self.question[Constants.QuestionFields.photoUrl] = photoURL
                self.question[Constants.QuestionFields.displayName] = displayName
                self.displayNameLabel.text = displayName
                
                if let photoDownloadURL = self.question[Constants.QuestionFields.photoDownloadURL] as! String? {
                    let url = NSURL(string: photoDownloadURL)
                    self.profilePhotoImageButton.kf_setImageWithURL(url, forState: .Normal, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"))
                } else if let photoUrl = self.question[Constants.QuestionFields.photoUrl] {
                    let image = UIImage(named: "Profile_avatar_placeholder_large")
                    self.profilePhotoImageButton.setImage(image, forState: .Normal)
                } else if let photoUrl = self.question[Constants.QuestionFields.photoUrl] {
                    FIRStorage.storage().referenceForURL(photoUrl as! String).dataWithMaxSize(INT64_MAX) { (data, error) in
                        self.profilePhotoImageButton.setImage(nil, forState: .Normal)
                        if error != nil {
                            print("Error downloading: \(error)")
                            return
                        } else {
                            let image = UIImage(data: data!)
                            self.profilePhotoImageButton.setImage(image, forState: .Normal)
                        }
                    }
                }
                
            } else if let photoUrl = self.question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl as! String), data = NSData(contentsOfURL: url) {
                let image = UIImage(data: data)
                self.profilePhotoImageButton.setImage(image, forState: .Normal)
                
            }
            self.profilePhotoImageButton.imageView?.contentMode = .ScaleAspectFill
            self.profilePhotoImageButton.layer.borderWidth = 1
            self.profilePhotoImageButton.layer.masksToBounds = false
            self.profilePhotoImageButton.layer.borderColor = UIColor.blackColor().CGColor
            self.profilePhotoImageButton.layer.cornerRadius = self.profilePhotoImageButton.bounds.width/2
            self.profilePhotoImageButton.clipsToBounds = true
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
