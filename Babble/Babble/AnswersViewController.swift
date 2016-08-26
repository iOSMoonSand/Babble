//
//  AnswersViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/21/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

// MARK:
// MARK: - AnswersViewController Class
// MARK:
class AnswersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    // MARK:
    // MARK: - Attributes
    // MARK:
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    private var _refHandle: FIRDatabaseHandle!
    var answersArray = [[String : AnyObject]]()
    var questionRef: String?
    var profilePhotoString: String?
    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        self.configureDatabase()
    }
    
    deinit {
        FirebaseConfigManager.sharedInstance.ref.child("answers").child(questionRef!).removeObserverWithHandle(_refHandle)
    }
    // MARK:
    // MARK: - Firebase Database Configuration
    // MARK:
    func configureDatabase() {
        _refHandle = FirebaseConfigManager.sharedInstance.ref.child("answers").child(questionRef!).observeEventType(.ChildAdded, withBlock: { (answerSnapshot) -> Void in
            let answerID = answerSnapshot.key
            var answer = answerSnapshot.value as! [String: AnyObject]
            answer[Constants.AnswerFields.questionID] = self.questionRef
            answer[Constants.AnswerFields.answerID] = answerID
//            answer[Constants.AnswerFields.photoUrl] = photoURL
            answer[Constants.AnswerFields.displayName] = ""
            let userID = answer[Constants.AnswerFields.userID] as! String
            //AppState.sharedInstance.likeCountAnswerID = answerID
            
            //Observer Like
            self.configureLikeObserver(answer)
            
            self.answersArray.append(answer)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.answersArray.count-1, inSection: 0)], withRowAnimation: .Automatic)
            
            let usersRef = FirebaseConfigManager.sharedInstance.ref.child("users")
            usersRef.child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
                var user = userSnapshot.value as! [String: AnyObject]
                let photoURL = user[Constants.UserFields.photoUrl] as! String
                let displayName = user[Constants.UserFields.displayName] as! String
                answer[Constants.AnswerFields.photoUrl] = photoURL
                answer[Constants.AnswerFields.displayName] = displayName
                
                self.updatePhotoUrlForAnswer(photoURL, answer: answer)
                })
            { (error) in
                print(error.localizedDescription)
            }
        })
    }
    func configureLikeObserver(answer : [String: AnyObject]) {
        var answer = answer
        FirebaseConfigManager.sharedInstance.ref.child("likeCounts").child("blah").observeEventType(.ChildChanged, withBlock: {(likeCountSnapshot) in
            let likeCount = likeCountSnapshot.value as! Int
            answer[Constants.AnswerFields.likeCount] = likeCount
            for (index, var dict) in self.answersArray.enumerate() {
                guard let dictQuestionId = dict[Constants.AnswerFields.questionID] as? String else { continue }
                guard let newQuestionId = answer[Constants.AnswerFields.questionID] as? String else { continue }
                guard let dictAnswerId = dict[Constants.AnswerFields.answerID] as? String else { continue }
                guard let newAnswerId = answer[Constants.AnswerFields.answerID] as? String else { continue }
                if (dictQuestionId == newQuestionId) && (dictAnswerId == newAnswerId) {
                    self.answersArray[index][Constants.AnswerFields.likeCount] = likeCount
                }
            }
            self.answersArray.sortInPlace {
                (($0 as [String: AnyObject])["likeCount"] as? Int) > (($1 as [String: AnyObject])["likeCount"] as? Int)
            }
            self.tableView.reloadData()
        })
    }
    func updatePhotoUrlForAnswer(photoURL: String, answer : [String: AnyObject]) {
        var indexesToReload = [NSIndexPath]()
        for (index, var dict) in self.answersArray.enumerate() {
            guard let dictAnswerID = dict[Constants.AnswerFields.answerID] as? String else { continue }
            guard let newAnswerID = answer[Constants.AnswerFields.answerID] as? String else { continue }
            if dictAnswerID == newAnswerID {
                self.answersArray[index][Constants.AnswerFields.photoUrl] = photoURL
                indexesToReload.append(NSIndexPath(forRow: index, inSection: 0))
            }
        }
        if indexesToReload.count > 0 {
            self.tableView.reloadRowsAtIndexPaths(indexesToReload, withRowAnimation: .None)
        }
    }
    // MARK:
    // MARK: - UITableViewDataSource & UITableViewDelegate methods
    // MARK:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.answersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerCell
        
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: "tapFiredLikeButton:", forControlEvents: .TouchUpInside)
        
        //unpack answer from local dict
        let answer: [String : AnyObject] = self.answersArray[indexPath.row]
        
        let answerText = answer[Constants.QuestionFields.text] as! String
        let displayName = answer[Constants.QuestionFields.displayName] as! String
        let likeCount = answer[Constants.AnswerFields.likeCount] as! Int
        cell.answerTextLabel.text = answerText
        cell.displayNameLabel.text = displayName
        cell.likeButtonCountLabel.text = String(likeCount)
        if let photoUrl = answer[Constants.QuestionFields.photoUrl] {
            FIRStorage.storage().referenceForURL(photoUrl as! String).dataWithMaxSize(INT64_MAX) { (data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                } else {
                    cell.profilePhotoImageView.image = UIImage(data: data!)
                }
            }
        } else if let photoUrl = answer[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl as! String), data = NSData(contentsOfURL: url) {
            cell.profilePhotoImageView.image = UIImage(data: data)
        } else {
            cell.profilePhotoImageView.image = UIImage(named: "ic_account_circle")
        }
        return cell
    }
    
    @IBAction func tapFiredLikeButton(sender: UIButton) {
        
        print("tap fired for like button")
        var answer: [String : AnyObject] = self.answersArray[sender.tag]
        let likeCount = answer[Constants.AnswerFields.likeCount] as! Int
        answer[Constants.AnswerFields.likeCount] = likeCount + 1
        let incrementedLikeCount = answer[Constants.AnswerFields.likeCount] as! Int
        let questionID = answer[Constants.AnswerFields.questionID] as! String
        let answerID = answer[Constants.AnswerFields.answerID] as! String
        FirebaseConfigManager.sharedInstance.ref.child("likeCounts/\(answerID)/likeCount").setValue(incrementedLikeCount)
        FirebaseConfigManager.sharedInstance.ref.child("answers/\(questionID)/\(answerID)/likeCount").setValue(incrementedLikeCount)
        //AppState.sharedInstance.likeCountAnswerID = answerID
    }
    
    // MARK:
    // MARK: - IBAction: Send Messages
    // MARK:
    @IBAction func didTapSendButton(sender: UIButton) {
        textFieldShouldReturn(textField)
    }
    
    // MARK:
    // MARK: - UITextFieldDelegate Methods
    // MARK:
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let data = [Constants.AnswerFields.text: textField.text! as String]
        sendAnswer(data)
        return true
    }
    
    // MARK:
    // MARK: - Set Firebase Data
    // MARK:
    func sendAnswer(data: [String: String]) {
        var answerDataDict = data
        guard let currentUserID = FirebaseConfigManager.sharedInstance.currentUser?.uid else { return }
        answerDataDict[Constants.QuestionFields.userID] = currentUserID
        FirebaseConfigManager.sharedInstance.ref.child("answers").child(questionRef!).childByAutoId().setValue(answerDataDict)
    }
    
}






















