//
//  DiscoverAnswersViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 09/27/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

// MARK:
// MARK: - AnswersViewController Class
// MARK:
class DiscoverAnswersViewController: UIViewController {
    // MARK:
    // MARK: - Attributes
    // MARK:
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    private var _refHandle: FIRDatabaseHandle!
    var answersArray = [[String : AnyObject]]()
    var questionRef: String?
    var selectedIndexRow: Int?
    var tapOutsideTextView = UITapGestureRecognizer()
    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func viewDidLoad() {
        textField.delegate = self
        super.viewDidLoad()
        registerForKeyboardNotifications()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        self.retrieveAnswerData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == Constants.Segues.AnswersToProfiles {
            guard let selectedIndexRow = selectedIndexRow else { return }
            var answer: [String : AnyObject] = self.answersArray[selectedIndexRow]
            let userID = answer[Constants.QuestionFields.userID]
            guard let destinationVC = segue.destinationViewController as? AnswersToProfilesViewController else { return }
            destinationVC.userIDRef = userID as? String
        }
    }
    
    
    deinit {
        unregisterForKeyboardNotifications()
        FirebaseConfigManager.sharedInstance.ref.child("answers").child(questionRef!).removeObserverWithHandle(_refHandle)
    }
    // MARK:
    // MARK: - Firebase Database Retrieval
    // MARK:
    func retrieveAnswerData() {
        _refHandle = FirebaseConfigManager.sharedInstance.ref.child("answers").child(questionRef!).observeEventType(.Value, withBlock: { (answerSnapshot) in
            self.answersArray = [[String: AnyObject]]()//make new clean array
            if answerSnapshot.value is NSNull {
            } else {
                let answers = answerSnapshot.value as! [String: [String:AnyObject]]
                for (key, value) in answers {
                    var answer = value
                    answer[Constants.AnswerFields.questionID] = self.questionRef! as String
                    answer[Constants.AnswerFields.answerID] = key as String
                    //answer object includes: text, userID, questionID, answerID
                    self.answersArray.append(answer)
                }
            }
            self.answersArray.sortInPlace {
                (($0 as [String: AnyObject])["likeCount"] as? Int) > (($1 as [String: AnyObject])["likeCount"] as? Int)
            }
            self.tableView.reloadData()
        })
    }
    // MARK:
    // MARK: - Button Actions
    // MARK:
    @IBAction func didTapSendAnswerButton(sender: UIButton) {
        textFieldShouldReturn(self.textField)
    }
    // MARK:
    // MARK: - Unwind Segues
    // MARK:
    @IBAction func didTapBackProfilesToAnswers(segue:UIStoryboardSegue) {
        //From UserProfiles to Answers
    }
    //MARK:
    //MARK: - NSNotification Methods
    //MARK:
    var kbHeight: CGFloat!
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIKeyboardDidHideNotification, object:nil)
    }
    
    func unregisterForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object:nil)}
    
    func keyboardDidShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    func animateTextField(up: Bool) {
        let movement = (up ? -kbHeight : kbHeight)
        UIView.animateWithDuration(0.1, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }
}
// MARK:
// MARK: - UITableViewDataSource & UITableViewDelegate Protocols
// MARK:
extension DiscoverAnswersViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK:
    // MARK: - UITableViewDataSource & UITableViewDelegate Methods
    // MARK:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.answersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("DiscoverAnswersCell", forIndexPath: indexPath) as! DiscoverAnswersCell
        cell.delegate = self
        cell.row = indexPath.row
        let answer: [String: AnyObject] = self.answersArray[indexPath.row]
        cell.performWithAnswer(answer)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
// MARK:
// MARK: - UITextFieldDelegate Protocol
// MARK:
extension DiscoverAnswersViewController: UITextFieldDelegate {
    // MARK:
    // MARK: - UITextFieldDelegate Methods
    // MARK:
    func textFieldDidBeginEditing(textField: UITextField) {
        print("textFieldDidBeginEditing")
        self.tableView.allowsSelection = false
        self.tapOutsideTextView = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutsideTextViewWhenEditing))
        self.view.addGestureRecognizer(tapOutsideTextView)
    }
    
    func didTapOutsideTextViewWhenEditing() {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("textFieldDidEndEditing")
        self.tableView.allowsSelection = true
        self.view.removeGestureRecognizer(tapOutsideTextView)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let data = [Constants.AnswerFields.text: textField.text! as String]
        sendAnswer(data)
        textField.resignFirstResponder()
        self.tableView.allowsSelection = true
        self.view.removeGestureRecognizer(tapOutsideTextView)
        return true
    }
    
    func sendAnswer(data: [String: String]) {
        var answerDataDict = data
        let currentUserID = FIRAuth.auth()?.currentUser?.uid
        answerDataDict[Constants.AnswerFields.userID] = currentUserID
        let key = FirebaseConfigManager.sharedInstance.ref.child("answers").child(questionRef!).childByAutoId().key
        let childUpdates = ["answers/\(questionRef!)/\(key)": answerDataDict,
                            "likeCounts/\(key)/likeCount": 0,
                            "likeStatuses/\(key)/likeStatus": 1]
        FirebaseConfigManager.sharedInstance.ref.updateChildValues(childUpdates as! [String : AnyObject])
    }
}
// MARK:
// MARK: - AnswerCellDelegate Protocol
// MARK:
extension DiscoverAnswersViewController: DiscoverAnswersCellDelegate {
    //MARK:
    //MARK: - AnswerCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(row: Int) {
        self.selectedIndexRow = row
        performSegueWithIdentifier(Constants.Segues.AnswersToProfiles, sender: self)
    }
    
    func handleLikeButtonTapOn(row: Int) {
        let answer = self.answersArray[row]
        let answerID = answer[Constants.AnswerFields.answerID] as! String
        //increment question likeCount
        FirebaseConfigManager.sharedInstance.ref.child("likeCounts").child(answerID).observeSingleEventOfType(.Value, withBlock: { (likeCountSnapshot) in
            let likeCountDict = likeCountSnapshot.value as! [String: AnyObject]
            guard let currentLikeCount = likeCountDict[Constants.LikeCountFields.likeCount] as! Int? else { return }
            guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
            FirebaseConfigManager.sharedInstance.ref.child("likeStatuses").child(answerID).child(currentUserID).observeSingleEventOfType(.Value, withBlock: {
                (likeStatusSnapshot) in
                let likeStatusDict = likeStatusSnapshot.value as! [String: Int]
                guard let likeStatus = likeStatusDict[Constants.LikeStatusFields.likeStatus] else { return }
                if likeStatus == 0 {
                    let incrementedLikeCount = (currentLikeCount) + 1
                    FirebaseConfigManager.sharedInstance.ref.child("likeCounts/\(answerID)/likeCount").setValue(incrementedLikeCount)
                    FirebaseConfigManager.sharedInstance.ref.child("likeStatuses/\(answerID)/\(currentUserID)/likeStatus").setValue(1)
                } else if likeStatus == 1 {
                    let decrementedLikeCount = (currentLikeCount) - 1
                    FirebaseConfigManager.sharedInstance.ref.child("likeCounts/\(answerID)/likeCount").setValue(decrementedLikeCount)
                    FirebaseConfigManager.sharedInstance.ref.child("likeStatuses/\(answerID)/\(currentUserID)/likeStatus").setValue(0)
                }
            })
        })
    }
}
















