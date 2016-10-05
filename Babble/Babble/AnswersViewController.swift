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
class AnswersViewController: UIViewController {
    // MARK:
    // MARK: - Attributes
    // MARK:
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    var selectedQuestionIdDict: [String: String]?
    var selectedIndexRow: Int?
    var tapOutsideTextView = UITapGestureRecognizer()
    var answersArray = [Answer]() {
        didSet{
            if oldValue.count == 0 {
                self.tableView.reloadData()
            } else {
                let rowDifference = self.answersArray.count - oldValue.count
                changeRowsForDifference(rowDifference, inSection: 0)
            }
        }
    }
    
    private func changeRowsForDifference(difference: Int, inSection section: Int){
        var indexPaths: [NSIndexPath] = []
        
        let rowOffSet = section == 0 ? self.answersArray.count-1 : self.answersArray.count-1
        
        for i in 0..<abs(difference) {
            indexPaths.append(NSIndexPath(forRow: i + rowOffSet, inSection: section))
        }
        
        if difference > 0 {
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        } else {
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
    }
    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.textField.delegate = self
        self.registerForNotifications()
        self.postNotifications()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        FirebaseMgr.shared.retrieveAnswers()
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//        if segue.identifier == Constants.Segues.AnswersToProfiles {
//            guard let selectedIndexRow = selectedIndexRow else { return }
//            var answer: [String : AnyObject] = self.answersArray[selectedIndexRow]
//            let userID = answer[Constants.QuestionFields.userID]
//            guard let destinationVC = segue.destinationViewController as? AnswersToProfilesViewController else { return }
//            destinationVC.userIDRef = userID as? String
//        }
//    }
    // MARK:
    // MARK: - Notification Registration Methods
    // MARK:
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateAnswersArray), name: Constants.NotifKeys.AnswersRetrieved, object: nil)
    }
    
    func updateAnswersArray() {
        self.answersArray = FirebaseMgr.shared.answersArray
    }
    // MARK:
    // MARK: - Notification Post Methods
    // MARK:
    func postNotifications() {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotifKeys.SendQuestionID, object: self, userInfo: self.selectedQuestionIdDict)
    }
    // MARK:
    // MARK: - Firebase Database Retrieval
    // MARK:
//    func retrieveAnswerData() {
//        _refHandle = self.ref.child("answers").child(questionRef!).observeEventType(.Value, withBlock: { (answerSnapshot) in
//            self.answersArray = [[String: AnyObject]]()//make new clean array
//            if answerSnapshot.value is NSNull {
//            } else {
//                let answers = answerSnapshot.value as! [String: [String:AnyObject]]
//                for (key, value) in answers {
//                    var answer = value
//                    answer[Constants.AnswerFields.questionID] = self.questionRef! as String
//                    answer[Constants.AnswerFields.answerID] = key as String
//                    //answer object includes: text, userID, questionID, answerID
//                    self.answersArray.append(answer)
//                }
//            }
//            self.answersArray.sortInPlace {
//                (($0 as [String: AnyObject])["likeCount"] as? Int) > (($1 as [String: AnyObject])["likeCount"] as? Int)
//            }
//            self.tableView.reloadData()
//        })
//    }
//    // MARK:
//    // MARK: - Button Actions
//    // MARK:
//    @IBAction func didTapSendAnswerButton(sender: UIButton) {
//        textFieldShouldReturn(self.textField)
//    }
//    // MARK:
//    // MARK: - Unwind Segues
//    // MARK:
//    @IBAction func didTapBackProfilesToAnswers(segue:UIStoryboardSegue) {
//        //From UserProfiles to Answers
//    }
}
    
// MARK:
// MARK: - UITableViewDataSource & UITableViewDelegate Protocols
// MARK:
extension AnswersViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK:
    // MARK: - UITableViewDataSource & UITableViewDelegate Methods
    // MARK:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.answersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerCell
        cell.delegate = self
        cell.row = indexPath.row
        let answer: Answer = self.answersArray[indexPath.row]
        cell.performWithAnswer(answer)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
//// MARK:
//// MARK: - UITextFieldDelegate Protocol
//// MARK:
//extension AnswersViewController: UITextFieldDelegate {
//    // MARK:
//    // MARK: - UITextFieldDelegate Methods
//    // MARK:
//    func textFieldDidBeginEditing(textField: UITextField) {
//        print("textFieldDidBeginEditing")
//        self.tableView.allowsSelection = false
//        self.tapOutsideTextView = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutsideTextViewWhenEditing))
//        self.view.addGestureRecognizer(tapOutsideTextView)
//    }
//    
//    func didTapOutsideTextViewWhenEditing() {
//        self.view.endEditing(true)
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField) {
//        print("textFieldDidEndEditing")
//        self.tableView.allowsSelection = true
//        self.view.removeGestureRecognizer(tapOutsideTextView)
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        let data = [Constants.AnswerFields.text: textField.text! as String]
//        sendAnswer(data)
//        textField.resignFirstResponder()
//        self.tableView.allowsSelection = true
//        self.view.removeGestureRecognizer(tapOutsideTextView)
//        return true
//    }
//    
//    func sendAnswer(data: [String: String]) {
//        var answerDataDict = data
//        let currentUserID = FIRAuth.auth()?.currentUser?.uid
//        answerDataDict[Constants.AnswerFields.userID] = currentUserID
//        let key = self.ref.child("answers").child(questionRef!).childByAutoId().key
//        let childUpdates = ["answers/\(questionRef!)/\(key)": answerDataDict,
//                            "likeCounts/\(key)/likeCount": 0,
//                            "likeStatuses/\(key)/likeStatus": 1]
//        self.ref.updateChildValues(childUpdates as! [String : AnyObject])
//    }
//}
// MARK:
// MARK: - AnswerCellDelegate Protocol
// MARK:
extension AnswersViewController: AnswerCellDelegate {
    //MARK:
    //MARK: - AnswerCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(row: Int) {
//        self.selectedIndexRow = row
//        performSegueWithIdentifier(Constants.Segues.AnswersToProfiles, sender: self)
    }
//
    func handleLikeButtonTapOn(row: Int) {
//        let answer = self.answersArray[row]
//        let answerID = answer[Constants.AnswerFields.answerID] as! String
//        //increment question likeCount
//        self.ref.child("likeCounts").child(answerID).observeSingleEventOfType(.Value, withBlock: { (likeCountSnapshot) in
//            let likeCountDict = likeCountSnapshot.value as! [String: AnyObject]
//            guard let currentLikeCount = likeCountDict[Constants.LikeCountFields.likeCount] as! Int? else { return }
//            guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
//            self.ref.child("likeStatuses").child(answerID).child(currentUserID).observeSingleEventOfType(.Value, withBlock: {
//                (likeStatusSnapshot) in
//                let likeStatusDict = likeStatusSnapshot.value as! [String: Int]
//                guard let likeStatus = likeStatusDict[Constants.LikeStatusFields.likeStatus] else { return }
//                if likeStatus == 0 {
//                    let incrementedLikeCount = (currentLikeCount) + 1
//                    self.ref.child("likeCounts/\(answerID)/likeCount").setValue(incrementedLikeCount)
//                    self.ref.child("likeStatuses/\(answerID)/\(currentUserID)/likeStatus").setValue(1)
//                } else if likeStatus == 1 {
//                    let decrementedLikeCount = (currentLikeCount) - 1
//                    self.ref.child("likeCounts/\(answerID)/likeCount").setValue(decrementedLikeCount)
//                    self.ref.child("likeStatuses/\(answerID)/\(currentUserID)/likeStatus").setValue(0)
//                }
//            })
//        })
    }
}






















