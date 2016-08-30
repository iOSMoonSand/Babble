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
    private var _refHandle: FIRDatabaseHandle!
    var answersArray = [[String : AnyObject]]()
    var questionRef: String?
    var selectedIndexRow: Int?
    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        self.retrieveAnswerData()
    }
    
    deinit {
        FirebaseConfigManager.sharedInstance.ref.child("answers").child(questionRef!).removeObserverWithHandle(_refHandle)
    }
    // MARK:
    // MARK: - Firebase Database Retrieval
    // MARK:
    func retrieveAnswerData() {
        _refHandle = FirebaseConfigManager.sharedInstance.ref.child("answers").child(questionRef!).observeEventType(.Value, withBlock: { (answerSnapshot) in
            self.answersArray = [[String: AnyObject]]()//make new clean array
            if answerSnapshot == [self.questionRef: null] {
                
            }
            let answers = answerSnapshot.value as! [String: [String: AnyObject]?]
            if answers[self.questionRef!] != nil {
                for (key, value) in answers {
                    guard var answer = value else { return }
                    answer[Constants.AnswerFields.questionID] = self.questionRef
                    answer[Constants.AnswerFields.answerID] = key
                    //answer object includes: text, userID, questionID, answerID
                    self.answersArray.append(answer)
            }
                self.answersArray.sortInPlace {
                    (($0 as [String: AnyObject])["likeCount"] as? Int) > (($1 as [String: AnyObject])["likeCount"] as? Int)
                }
                self.tableView.reloadData()
            }
            
        })
    }
    // MARK:
    // MARK: - Button Actions
    // MARK:
    @IBAction func didTapSendAnswerButton(sender: UIButton) {
        textFieldShouldReturn(self.textField)
    }
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
            return cell
    }
}
// MARK:
// MARK: - UITextFieldDelegate Protocol
// MARK:
extension AnswersViewController: UITextFieldDelegate {
    // MARK:
    // MARK: - UITextFieldDelegate Methods
    // MARK:
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let data = [Constants.AnswerFields.text: textField.text! as String]
        sendAnswer(data)
        return true
    }
    
    func sendAnswer(data: [String: String]) {
        var answerDataDict = data
        let currentUserID = FirebaseConfigManager.sharedInstance.currentUser?.uid
        answerDataDict[Constants.AnswerFields.userID] = currentUserID
        let key = FirebaseConfigManager.sharedInstance.ref.child("answers").child(questionRef!).childByAutoId().key
        let childUpdates = ["questions/\(key)": answerDataDict,
                            "likeCounts/\(key)/likeCount": 0,
                            "likeCounts/\(key)/likeStatus": 1]
        FirebaseConfigManager.sharedInstance.ref.updateChildValues(childUpdates as! [String : AnyObject])
    }

}





















