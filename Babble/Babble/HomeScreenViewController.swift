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
    //MARK: - Properties
    //MARK: -
    @IBOutlet weak var tableView: UITableView!
    //var top10QuestionsArray = ArraySlice<[Question]>()
    var newQuestion: String?
    var selectedIndexRow: Int?
    var questionsArray = [Question]() {
        didSet{
            if oldValue.count == 0 {
                self.tableView.reloadData()
            } else {
                let rowDifference = questionsArray.count - oldValue.count
                changeRowsForDifference(rowDifference, inSection: 0)
            }
        }
    }
    
    private func changeRowsForDifference(difference: Int, inSection section: Int){
        var indexPaths: [NSIndexPath] = []
        let rowOffSet = section == 0 ? questionsArray.count-1 : questionsArray.count-1
        for i in 0..<abs(difference) {
            indexPaths.append(NSIndexPath(forRow: i + rowOffSet, inSection: section))
        }
        if difference > 0 {
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        } else {
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
    }
    //MARK: -
    //MARK: - UIViewController Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.registerForNotifications()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        FirebaseMgr.shared.retrieveQuestions()
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.HomeToAnswers {
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
            let selectedQuestion = self.questionsArray[selectedIndexPath.row]
            let questionID = selectedQuestion.questionID
            let questionIdDict = ["questionID": questionID]
            guard let destinationVC = segue.destinationViewController as? AnswersViewController else { return }
            destinationVC.selectedQuestionIdDict = questionIdDict
        }
//
//        if segue.identifier == Constants.Segues.HomeToProfiles {
//            guard let selectedIndexRow = selectedIndexRow else { return }
//            var question: [String : AnyObject] = self.top10QuestionsArray[selectedIndexRow]
//            let userID = question[Constants.QuestionFields.userID]
//            guard let destinationVC = segue.destinationViewController as? HomeToProfilesViewController else { return }
//            destinationVC.userIDRef = userID as? String
//        }
    }
    // MARK:
    // MARK: - Notification Registration Methods
    // MARK:
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateQuestionsArray), name: Constants.NotifKeys.QuestionsRetrieved, object: nil)
    }
    
    func updateQuestionsArray(){
        self.questionsArray = FirebaseMgr.shared.questionsArray
    }
    // MARK:
    // MARK: - Button Actions
    // MARK:
//    @IBAction func didTapPostAddQuestion(segue:UIStoryboardSegue) {
//        //Unwind segue from AddQuestion to HomeScreen
//        //Identifier: PostNewQuestionToHome
//        let data = [Constants.QuestionFields.text: self.newQuestion! as String]
//        postQuestion(data)
//    }
    
//    func postQuestion(data: [String: AnyObject]) {
//        var questionDataDict = data
//        guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
//        questionDataDict[Constants.QuestionFields.userID] = currentUserID
//        let key = self.ref.child("questions").childByAutoId().key
//        let childUpdates = ["questions/\(key)": questionDataDict,
//                            "likeCounts/\(key)/likeCount": 0,
//                            "likeStatuses/\(key)/\(currentUserID)/likeStatus": 0]
//        self.ref.updateChildValues(childUpdates as! [String : AnyObject])
//    }
    // MARK:
    // MARK: - Unwind Segues
    // MARK:
    @IBAction func didTapBackAnswers(segue:UIStoryboardSegue) {
        //From AddQuestion to HomeScreen
    }
    @IBAction func didTapCancelAddQuestion(segue:UIStoryboardSegue) {
        //From AddQuestion to HomeScreen
    }
    @IBAction func didTapBackProfilesToHome(segue:UIStoryboardSegue) {
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
        return self.questionsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionCell
        cell.delegate = self
        cell.row = indexPath.row
        let question: Question = self.questionsArray[indexPath.row]
        cell.performWithQuestion(question)
        FirebaseMgr.shared.retrieveUserDisplayName(question.userID, completion: { (displayName) in
            cell.displayNameLabel.text = displayName
        })
        FirebaseMgr.shared.retrieveUserPhotoDownloadURL(question.userID, completion: { (photoDownloadURL, defaultImage) in
            if photoDownloadURL != nil {
                let url = NSURL(string: photoDownloadURL!)
                cell.profilePhotoImageButton.kf_setImageWithURL(url, forState: .Normal, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"))
            } else {
                cell.profilePhotoImageButton.setImage(UIImage(named: "Profile_avatar_placeholder_large"), forState: .Normal)
            }
        })
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Constants.Segues.HomeToAnswers, sender: self)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
//        self.selectedIndexRow = row
//        performSegueWithIdentifier(Constants.Segues.HomeToProfiles, sender: self)
    }
//
    func handleLikeButtonTapOn(row: Int) {
//        let question = self.questionsArray[row]
//        let questionID = question[Constants.QuestionFields.questionID] as! String
//        //increment question likeCount
//        self.ref.child("likeCounts").child(questionID).observeSingleEventOfType(.Value, withBlock: { (likeCountSnapshot) in
//            let likeCountDict = likeCountSnapshot.value as! [String: AnyObject]
//            guard let currentLikeCount = likeCountDict[Constants.LikeCountFields.likeCount] as! Int? else { return }
//            guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
//            self.ref.child("likeStatuses").child(questionID).child(currentUserID).observeSingleEventOfType(.Value, withBlock: {
//                (likeStatusSnapshot) in
//                let likeStatusDict = likeStatusSnapshot.value as! [String: Int]
//                guard let likeStatus = likeStatusDict[Constants.LikeStatusFields.likeStatus] else { return }
//                if likeStatus == 0 {
//                    let incrementedLikeCount = (currentLikeCount) + 1
//                    self.ref.child("likeCounts/\(questionID)/likeCount").setValue(incrementedLikeCount)
//                    self.ref.child("likeStatuses/\(questionID)/\(currentUserID)/likeStatus").setValue(1)
//                } else if likeStatus == 1 {
//                    let decrementedLikeCount = (currentLikeCount) - 1
//                    self.ref.child("likeCounts/\(questionID)/likeCount").setValue(decrementedLikeCount)
//                    self.ref.child("likeStatuses/\(questionID)/\(currentUserID)/likeStatus").setValue(0)
//                }
//                })
//        })
    }
}


















