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
    func handleLikeButtonTapOn(row: Int)
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
    func performWithAnswer(answer: [String : AnyObject]) {
        //unpack local question data
        self.answer = answer
        self.profilePhotoImageButton.setImage(nil, forState: .Normal)
        let answerText = self.answer[Constants.AnswerFields.text] as! String
        //let questionID = self.answer[Constants.AnswerFields.questionID] as! String
        let answerID = self.answer[Constants.AnswerFields.answerID] as! String
        let userID = self.answer[Constants.AnswerFields.userID] as! String
        self.answerTextView.text = answerText
        //retrieve likeCount from Firebase
        FirebaseConfigManager.sharedInstance.ref.child("likeCounts").child(answerID).observeEventType(.Value, withBlock: {(likeCountSnapshot) in
            let likeCountDict = likeCountSnapshot.value as! [String: Int]
            if self.answer[Constants.AnswerFields.answerID] as! String == likeCountSnapshot.key {
                guard let currentLikeCount = likeCountDict[Constants.LikeCountFields.likeCount] else { return }
                self.answer[Constants.QuestionFields.likeCount] = currentLikeCount
                self.likeButtonCountLabel.text = String(currentLikeCount)
            }
        })
        //retrieve or create likeStatus from/in Firebase
        FirebaseConfigManager.sharedInstance.ref.child("likeStatuses").child(answerID).observeEventType(.Value, withBlock: { (likeStatusSnapshot) in
            let likeStatusForUsersDict = likeStatusSnapshot.value as! [String: AnyObject]
            if self.answer[Constants.AnswerFields.answerID] as! String == likeStatusSnapshot.key {
                guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
                for (key, value) in likeStatusForUsersDict {
                    if key == currentUserID {
                        let likeStatusForUser = value
                        let likeStatus = likeStatusForUser[Constants.LikeStatusFields.likeStatus] as? Int
                        if likeStatus == 1 {
                            let fullHeartImage = UIImage(named: "heart-full")
                            self.likeButton.setBackgroundImage(fullHeartImage, forState: .Normal)
                        } else if likeStatus == 0 {
                            let emptyHeartImage = UIImage(named: "heart-empty")
                            self.likeButton.setBackgroundImage(emptyHeartImage, forState: .Normal)
                        }
                    }
                    if likeStatusForUsersDict[currentUserID] == nil {
                        let currentAnswerID = self.answer[Constants.AnswerFields.answerID] as! String
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
            if self.answer[Constants.AnswerFields.userID] as! String == userSnapshot.key {
                let photoURL = user[Constants.UserFields.photoURL] as! String
                let displayName = user[Constants.UserFields.displayName] as! String
                if let photoDownloadURL = user[Constants.UserFields.photoDownloadURL] {
                    self.answer[Constants.AnswerFields.photoDownloadURL] = photoDownloadURL
                }
                self.answer[Constants.AnswerFields.photoUrl] = photoURL
                self.answer[Constants.AnswerFields.displayName] = displayName
                self.displayNameLabel.text = displayName
                
                
                if let photoDownloadURL = self.answer[Constants.AnswerFields.photoDownloadURL] as! String? {
                    let url = NSURL(string: photoDownloadURL)
                    self.profilePhotoImageButton.kf_setImageWithURL(url, forState: .Normal, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"))
                } else if let photoUrl = self.answer[Constants.AnswerFields.photoUrl] {
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
                } else if let photoUrl = self.answer[Constants.AnswerFields.photoUrl], url = NSURL(string:photoUrl as! String), data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    self.profilePhotoImageButton.setImage(image, forState: .Normal)
                    
                } else {
                    let image = UIImage(named: "ic_account_circle")
                    self.profilePhotoImageButton.setImage(image, forState: .Normal)
                }
                self.profilePhotoImageButton.imageView?.contentMode = .ScaleAspectFill
                self.profilePhotoImageButton.layer.borderWidth = 1
                self.profilePhotoImageButton.layer.masksToBounds = false
                self.profilePhotoImageButton.layer.borderColor = UIColor.blackColor().CGColor
                self.profilePhotoImageButton.layer.cornerRadius = self.profilePhotoImageButton.bounds.width/2
                self.profilePhotoImageButton.clipsToBounds = true
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
