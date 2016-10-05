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
    var user: User?
    var row: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerForNotifications()
    }
    
    //MARK:
    //MARK: - Instance Methods
    //MARK:
    func performWithQuestion(question: Question) {
        
        self.questionTextView.contentInset = UIEdgeInsetsMake(self.questionTextView.contentInset.top, -5, self.questionTextView.contentInset.bottom, self.questionTextView.contentInset.right)
        //unpack local question data
        let userID = question.userID
        let userIdDict = ["userID": userID]
        self.postUserIDNotificationWith(userIdDict)
        self.profilePhotoImageButton.setImage(nil, forState: .Normal)
        let questionText = question.text
        let questionID = question.questionID
        let likeCount = question.likeCount
        
        self.questionTextView.text = questionText
        self.likeButtonCountLabel.text = String(likeCount)
        let emptyHeartImage = UIImage(named: "heart-empty")
        self.likeButton.setImage(emptyHeartImage, forState: .Normal)
        
        FirebaseMgr.shared.retrieveUsers()
        
//        //retrieve likeCount from Firebase
//        FirebaseConfigManager.sharedInstance.ref.child("likeCounts").child(questionID).observeEventType(.Value, withBlock: {(likeCountSnapshot) in
//            let likeCountDict = likeCountSnapshot.value as! [String: Int]
//            if self.question[Constants.QuestionFields.questionID] as! String == likeCountSnapshot.key {
//                guard let currentLikeCount = likeCountDict[Constants.LikeCountFields.likeCount] else { return }
//                self.question[Constants.QuestionFields.likeCount] = currentLikeCount
//                self.likeButtonCountLabel.text = String(currentLikeCount)
//                FirebaseConfigManager.sharedInstance.ref.child("questions/\(questionID)/likeCount").setValue(currentLikeCount)
//            }
//        })
        
//        //retrieve or create likeStatus from/in Firebase
//        FirebaseConfigManager.sharedInstance.ref.child("likeStatuses").child(questionID).observeEventType(.Value, withBlock: { (likeStatusSnapshot) in
//            let likeStatusForUsersDict = likeStatusSnapshot.value as! [String: [String: Int]]
//            if self.question[Constants.QuestionFields.questionID] as! String == likeStatusSnapshot.key {
//                guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
//                for (key, value) in likeStatusForUsersDict {
//                    if key == FIRAuth.auth()?.currentUser?.uid {
//                        let likeStatusForUser = value
//                        let likeStatus = likeStatusForUser[Constants.LikeStatusFields.likeStatus]
//                        if likeStatus == 1 {
//                            let fullHeartImage = UIImage(named: "heart-full")
//                            self.likeButton.setBackgroundImage(fullHeartImage, forState: .Normal)
//                        } else if likeStatus == 0 {
//                            let emptyHeartImage = UIImage(named: "heart-empty")
//                            self.likeButton.setBackgroundImage(emptyHeartImage, forState: .Normal)
//                        }
//                    }
//                    if likeStatusForUsersDict[currentUserID] == nil {
//                        let currentAnswerID = self.question[Constants.QuestionFields.questionID] as! String
//                        FirebaseConfigManager.sharedInstance.ref.child("likeStatuses/\(currentAnswerID)/\(currentUserID)/likeStatus").setValue(0)
//                        let emptyHeartImage = UIImage(named: "heart-empty")
//                        self.likeButton.setBackgroundImage(emptyHeartImage, forState: .Normal)
//                    }
//                }
//            }
//        })
        
    }
    //MARK:
    //MARK: - Notification Registration Methods
    //MARK:
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateCellWithUserData), name: Constants.NotifKeys.UserRetrieved, object: nil)
    }
    
    func updateCellWithUserData() {
        print("update cell here")
        self.user = FirebaseMgr.shared.user
        self.displayNameLabel.text = self.user?.displayName
    }
    //MARK:
    //MARK: - Notification Posting Methods
    //MARK:
    func postUserIDNotificationWith(userIdDict: [String: String]) {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotifKeys.SendUserID, object: self, userInfo: userIdDict)
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
