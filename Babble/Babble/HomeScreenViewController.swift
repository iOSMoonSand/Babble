//
//  HomeScreenViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/02/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

//MARK: -
//MARK: - HomeScreenViewController Class
//MARK: -
class HomeScreenViewController: UIViewController {
    //MARK: -
    //MARK: - Attributes
    //MARK: -
    @IBOutlet weak var tableView: UITableView!
    private var _refHandle: FIRDatabaseHandle!
    var questionsArray = [[String : AnyObject]]()
    var newQuestion: String?
    var selectedIndexRow: Int?
    //MARK: -
    //MARK: - UIViewController Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        self.retrieveQuestionData()
    }
    
    deinit {
        FirebaseConfigManager.sharedInstance.ref.child("questions").removeObserverWithHandle(_refHandle)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == Constants.Segues.HomeToAnswers {
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
            let questionSnapShot = self.questionsArray[selectedIndexPath.row]
            let questionID = questionSnapShot[Constants.QuestionFields.questionID]
            guard let nav = segue.destinationViewController as? UINavigationController else { return }
            guard let answersVC = nav.topViewController as? AnswersViewController else { return }
            answersVC.questionRef = questionID as? String
            guard let destinationVC = segue.destinationViewController as? AnswersViewController else { return }
            destinationVC.questionRef = questionID as? String
        }
        
        if segue.identifier == Constants.Segues.HomeToProfile {
            guard let selectedIndexRow = selectedIndexRow else { return }
            var question: [String : AnyObject] = self.questionsArray[selectedIndexRow]
            let userID = question[Constants.QuestionFields.userID]
            guard let nav = segue.destinationViewController as? UINavigationController else { return }
            guard let UserProfilesVC = nav.topViewController as? UserProfilesViewController else { return }
            UserProfilesVC.userIDRef = userID as? String
            guard let destinationVC = segue.destinationViewController as? UserProfilesViewController else { return }
            destinationVC.userIDRef = userID as? String
        }
    }
    // MARK:
    // MARK: - Firebase Database Retrieval
    // MARK:
    func retrieveQuestionData() {
        //TODO: why use [weak self] in closure
        _refHandle = FirebaseConfigManager.sharedInstance.ref.child("questions").observeEventType(.Value, withBlock: { (questionSnapshot) in
            self.questionsArray = [[String : AnyObject]]()//make a new clean array
            let questions = questionSnapshot.value as! [String: [String: AnyObject]]
            var question = [String: AnyObject]()
            for (key, value) in questions {
                question = value
                question[Constants.QuestionFields.questionID] = key
                // question object includes: text, userID, questionID
                self.questionsArray.append(question)
            }
            self.questionsArray.sortInPlace {
                (($0 as [String: AnyObject])["likeCount"] as? Int) > (($1 as [String: AnyObject])["likeCount"] as? Int)
            }
            self.tableView.reloadData()
        })
    }
    // MARK:
    // MARK: - Button Actions
    // MARK:
    @IBAction func didTapPostAddQuestion(segue:UIStoryboardSegue) {
        //Unwind segue from AddQuestion to HomeScreen
        //Identifier: PostNewQuestionToHome
        let data = [Constants.QuestionFields.text: newQuestion! as String]
        postQuestion(data)
    }
    
    func postQuestion(data: [String: AnyObject]) {
        var questionDataDict = data
        let currentUserID = FirebaseConfigManager.sharedInstance.currentUser?.uid
        questionDataDict[Constants.QuestionFields.userID] = currentUserID
        let key = FirebaseConfigManager.sharedInstance.ref.child("questions").childByAutoId().key
        let childUpdates = ["questions/\(key)": questionDataDict,
                            "likeCounts/\(key)/likeCount": 0,
                            "likeCounts/\(key)/likeStatus": 1]
        FirebaseConfigManager.sharedInstance.ref.updateChildValues(childUpdates as! [String : AnyObject])
    }
    // MARK:
    // MARK: - Unwind Segues
    // MARK:
    @IBAction func didTapBackAnswers(segue:UIStoryboardSegue) {
        //From AddQuestion to HomeScreen
    }
    @IBAction func didTapCancelAddQuestion(segue:UIStoryboardSegue) {
        //From AddQuestion to HomeScreen
    }
    @IBAction func didTapBackProfiles(segue:UIStoryboardSegue) {
        //From UserProfiles to HomeScreen
    }
}
// MARK:
// MARK: - UITableViewDelegate & UITableViewDataSource Protocols
// MARK:
extension HomeScreenViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK:
    // MARK: - UITableViewDataSource & UITableViewDelegate Methods
    // MARK:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionCell
        cell.delegate = self
        cell.row = indexPath.row
        let question: [String : AnyObject] = self.questionsArray[indexPath.row]
        cell.performWithQuestion(question)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Constants.Segues.HomeToAnswers, sender: self)
    }
}
// MARK:
// MARK: - QuestionCellDelegate Protocol
// MARK:
extension HomeScreenViewController: QuestionCellDelegate {
    //MARK:
    //MARK: - QuestionCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(row: Int) {
        self.selectedIndexRow = row
        performSegueWithIdentifier(Constants.Segues.HomeToProfile, sender: self)
    }
    
    func handleLikeButtonTapOn(row: Int) {
        let question = self.questionsArray[row]
        let questionID = question[Constants.QuestionFields.questionID] as! String
        //increment question likeCount
        FirebaseConfigManager.sharedInstance.ref.child("likeCounts").child(questionID).observeSingleEventOfType(.Value, withBlock: { (likeCountSnapshot) in
            let likeCountDict = likeCountSnapshot.value as! [String: Int]
            guard let currentLikeCount = likeCountDict[Constants.LikeCountFields.likeCount] else { return }
            guard let currentLikeStatus = likeCountDict[Constants.LikeCountFields.likeStatus] else { return }
            
            if currentLikeStatus == 0 {
                let decrementedLikeCount = (currentLikeCount) - 1
                FirebaseConfigManager.sharedInstance.ref.child("likeCounts/\(questionID)/likeCount").setValue(decrementedLikeCount)
                FirebaseConfigManager.sharedInstance.ref.child("likeCounts/\(questionID)/likeStatus").setValue(1)
            } else if currentLikeStatus == 1 {
                let incrementedLikeCount = (currentLikeCount) + 1
                FirebaseConfigManager.sharedInstance.ref.child("likeCounts/\(questionID)/likeCount").setValue(incrementedLikeCount)
                FirebaseConfigManager.sharedInstance.ref.child("likeCounts/\(questionID)/likeStatus").setValue(0)
            }
        })
    }
}


















