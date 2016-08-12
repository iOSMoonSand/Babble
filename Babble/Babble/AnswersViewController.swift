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
    // MARK: - Properties
    // MARK:
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    var answersArray: [Dictionary<String, String>]! = []
    var questionRef: String?
    var storageRef: FIRStorageReference!
    var profilePhotoString: String?
    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        self.configureDatabase()
        self.configureStorage()
    }
    
    deinit {
        self.ref.child("answers").child(questionRef!).removeObserverWithHandle(_refHandle)
    }
    // MARK:
    // MARK: - Firebase Database Configuration
    // MARK:
    func configureDatabase() {
        self.ref = FIRDatabase.database().reference()
        _refHandle = self.ref.child("answers").child(questionRef!).observeEventType(.ChildAdded, withBlock: { (answerSnapshot) -> Void in
            var answer = answerSnapshot.value as! Dictionary<String, String>
            let userID = answer[Constants.AnswerFields.userID] as String!
            
            
            
            let usersRef = self.ref.child("users")
            usersRef.child(userID).observeSingleEventOfType(.Value, withBlock: { (userSnapshot) in
                print("userSnapshot value:\(userSnapshot.value!)")
                
                var user = userSnapshot.value as! Dictionary<String, String>
                let photoURL = user[Constants.UserFields.photoUrl] as String!
                
                answer[Constants.AnswerFields.photoUrl] = photoURL
                
                self.answersArray.append(answer)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.answersArray.count-1, inSection: 0)], withRowAnimation: .Automatic)
                })
            { (error) in
                print(error.localizedDescription)
            }
        })
    }
    // MARK:
    // MARK: - Firebase StorageConfiguration
    // MARK:
    func configureStorage() {
        storageRef = FIRStorage.storage().referenceForURL("gs://babble-8b668.appspot.com/")
    }
    // MARK:
    // MARK: - UITableViewDataSource & UITableViewDelegate methods
    // MARK:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.answersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath)
        //unpack question from database
        let answer: Dictionary<String, String>! = self.answersArray[indexPath.row]
        
        let text = answer[Constants.QuestionFields.text] as String!
        cell!.textLabel?.text = /*name + ": " + */text
        
        if let photoUrl = answer[Constants.QuestionFields.photoUrl] {
            FIRStorage.storage().referenceForURL(photoUrl).dataWithMaxSize(INT64_MAX) { (data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                cell!.imageView?.image = UIImage.init(data: data!)
            }
        } else if let photoUrl = answer[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
            cell!.imageView?.image = UIImage.init(data: data)
        } else {
            cell!.imageView?.image = UIImage(named: "ic_account_circle")
        }
        return cell!
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
        guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
        answerDataDict[Constants.QuestionFields.userID] = currentUserID
        self.ref.child("answers").child(questionRef!).childByAutoId().setValue(answerDataDict)
    }
    
}






















