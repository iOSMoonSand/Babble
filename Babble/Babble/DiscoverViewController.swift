////
////  DiscoverViewController.swift
////  Babble
////
////  Created by Alexis Schreier on 09/27/16.
////  Copyright © 2016 Alexis Schreier. All rights reserved.
////
//
//import UIKit
//import Firebase
//
////MARK: -
////MARK: - DiscoverViewController Class
////MARK: -
//class DiscoverViewController: UIViewController {
//    //MARK: -
//    //MARK: - Attributes
//    //MARK: -
//    @IBOutlet weak var tableView: UITableView!
//    private var _refHandle: FIRDatabaseHandle!
//    var questionsArray = [[String : AnyObject]]()
//    var newQuestion: String?
//    var selectedIndexRow: Int?
//    
//    //MARK: -
//    //MARK: - UIViewController Methods
//    //MARK: -
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
//        self.retrieveQuestionData()
//    }
//    
//    deinit {
//        FirebaseConfigManager.sharedInstance.ref.child("questions").removeObserverWithHandle(_refHandle)
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//        if segue.identifier == Constants.Segues.DiscoverToAnswers {
//            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
//            let questionSnapShot = self.questionsArray[selectedIndexPath.row]
//            let questionID = questionSnapShot[Constants.QuestionFields.questionID]
//            guard let destinationVC = segue.destinationViewController as? DiscoverAnswersViewController else { return }
//            destinationVC.questionRef = questionID as? String
//        }
//        
//        if segue.identifier == Constants.Segues.DiscoverToProfiles {
//            guard let selectedIndexRow = selectedIndexRow else { return }
//            var question: [String : AnyObject] = self.questionsArray[selectedIndexRow]
//            let userID = question[Constants.QuestionFields.userID]
//            guard let destinationVC = segue.destinationViewController as? DiscoverToProfilesViewController else { return }
//            destinationVC.userIDRef = userID as? String
//        }
//    }
//    // MARK:
//    // MARK: - Firebase Database Retrieval
//    // MARK:
//    func retrieveQuestionData() {
//        //TODO: look up why use [weak self] in closure
//        //TODO: use _refHandle in other places?
//        _refHandle = FirebaseConfigManager.sharedInstance.ref.child("questions").observeEventType(.Value, withBlock: { (questionSnapshot) in
//            self.questionsArray = [[String : AnyObject]]()//make a new clean array
//            let questions = questionSnapshot.value as! [String: [String: AnyObject]]
//            var question = [String: AnyObject]()
//            for (key, value) in questions {
//                question = value
//                question[Constants.QuestionFields.questionID] = key
//                // question object includes: text, userID, questionID
//                self.questionsArray.append(question)
//            }
////            self.questionsArray.sortInPlace {
////                (($0 as [String: AnyObject])["likeCount"] as? Int) > (($1 as [String: AnyObject])["likeCount"] as? Int)
////            }
//            self.tableView.reloadData()
//        })
//    }
//    // MARK:
//    // MARK: - Button Actions
//    // MARK:
//    @IBAction func didTapPostAddQuestion(segue:UIStoryboardSegue) {
//        //Unwind segue from AddQuestion to HomeScreen
//        //Identifier: PostNewQuestionToHome
//        let data = [Constants.QuestionFields.text: self.newQuestion! as String]
//        postQuestion(data)
//    }
//    
//    func postQuestion(data: [String: AnyObject]) {
//        var questionDataDict = data
//        guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
//        questionDataDict[Constants.QuestionFields.userID] = currentUserID
//        let key = FirebaseConfigManager.sharedInstance.ref.child("questions").childByAutoId().key
//        let childUpdates = ["questions/\(key)": questionDataDict,
//                            "likeCounts/\(key)/likeCount": 0,
//                            "likeStatuses/\(key)/\(currentUserID)/likeStatus": 0]
//        FirebaseConfigManager.sharedInstance.ref.updateChildValues(childUpdates as! [String : AnyObject])
//    }
//    // MARK:
//    // MARK: - Unwind Segues
//    // MARK:
//    @IBAction func didTapBackDiscoverAnswers(segue:UIStoryboardSegue) {
//        //From AddQuestion to HomeScreen
//    }
//    @IBAction func didTapCancelAddQuestion(segue:UIStoryboardSegue) {
//        //From AddQuestion to HomeScreen
//    }
//    @IBAction func didTapBackDiscoverToProfiles(segue:UIStoryboardSegue) {
//        //From DiscoverToProfiles to Discover
//    }
//}
//// MARK:
//// MARK: - UITableViewDelegate & UITableViewDataSource Protocols
//// MARK:
//extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
//    // MARK:
//    // MARK: - UITableViewDataSource & UITableViewDelegate Methods
//    // MARK:
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.questionsArray.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = self.tableView.dequeueReusableCellWithIdentifier("DiscoverQuestionCell", forIndexPath: indexPath) as! DiscoverQuestionCell
//        cell.delegate = self
//        cell.row = indexPath.row
//        let question: [String: AnyObject] = self.questionsArray[indexPath.row]
//        cell.performWithQuestion(question)
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        performSegueWithIdentifier(Constants.Segues.DiscoverToAnswers, sender: self)
//        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }
//}
//// MARK:
//// MARK: - DiscoverQuestionCellDelegate Protocol
//// MARK:
//extension DiscoverViewController: DiscoverQuestionCellDelegate {
//    //MARK:
//    //MARK: - DiscoverQuestionCellDelegate Methods
//    //MARK:
//    func handleProfileImageButtonTapOn(row: Int) {
//        self.selectedIndexRow = row
//        performSegueWithIdentifier(Constants.Segues.DiscoverToProfiles, sender: self)
//    }
//    
//    func handleLikeButtonTapOn(row: Int) {
//        let question = self.questionsArray[row]
//        let questionID = question[Constants.QuestionFields.questionID] as! String
//        //increment question likeCount
//        FirebaseConfigManager.sharedInstance.ref.child("likeCounts").child(questionID).observeSingleEventOfType(.Value, withBlock: { (likeCountSnapshot) in
//            let likeCountDict = likeCountSnapshot.value as! [String: AnyObject]
//            guard let currentLikeCount = likeCountDict[Constants.LikeCountFields.likeCount] as! Int? else { return }
//            guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
//            FirebaseConfigManager.sharedInstance.ref.child("likeStatuses").child(questionID).child(currentUserID).observeSingleEventOfType(.Value, withBlock: {
//                (likeStatusSnapshot) in
//                let likeStatusDict = likeStatusSnapshot.value as! [String: Int]
//                guard let likeStatus = likeStatusDict[Constants.LikeStatusFields.likeStatus] else { return }
//                if likeStatus == 0 {
//                    let incrementedLikeCount = (currentLikeCount) + 1
//                    FirebaseConfigManager.sharedInstance.ref.child("likeCounts/\(questionID)/likeCount").setValue(incrementedLikeCount)
//                    FirebaseConfigManager.sharedInstance.ref.child("likeStatuses/\(questionID)/\(currentUserID)/likeStatus").setValue(1)
//                } else if likeStatus == 1 {
//                    let decrementedLikeCount = (currentLikeCount) - 1
//                    FirebaseConfigManager.sharedInstance.ref.child("likeCounts/\(questionID)/likeCount").setValue(decrementedLikeCount)
//                    FirebaseConfigManager.sharedInstance.ref.child("likeStatuses/\(questionID)/\(currentUserID)/likeStatus").setValue(0)
//                }
//            })
//        })
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
