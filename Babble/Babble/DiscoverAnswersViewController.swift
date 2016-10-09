//
//  DiscoverAnswersViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 10/09/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

// MARK:
// MARK: - DiscoverAnswersViewController Class
// MARK:
class DiscoverAnswersViewController: UIViewController {
    // MARK:
    // MARK: - Properties
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
    //TODO: understand logic below
    private func changeRowsForDifference(difference: Int, inSection section: Int){
        var indexPaths: [NSIndexPath] = []
        
        let rowOffSet = self.answersArray.count-1
        
        for i in 0..<abs(difference) {
            indexPaths.append(NSIndexPath(forRow: i + rowOffSet, inSection: section))
        }
        
        if difference > 0 {
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
    }    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.textField.delegate = self
        self.registerForNotifications()
        self.postNotifications()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        FirebaseMgr.shared.retrieveDiscoverAnswers()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateAnswersArray), name: Constants.NotifKeys.DiscoverAnswersRetrieved, object: nil)
    }
    
    func updateAnswersArray() {
        self.answersArray = FirebaseMgr.shared.discoverAnswersArray
    }
    // MARK:
    // MARK: - Notification Post Methods
    // MARK:
    func postNotifications() {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotifKeys.SendQuestionID, object: self, userInfo: self.selectedQuestionIdDict)
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
        let cell = self.tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerCell
        cell.delegate = self
        cell.row = indexPath.row
        let answer: Answer = self.answersArray[indexPath.row]
        //
        cell.updateViewsWith(answer)
        //
        FirebaseMgr.shared.retrieveUserDisplayName(answer.userID, completion: { (displayName) in
            cell.displayNameLabel.text = displayName
        })
        //
        FirebaseMgr.shared.retrieveUserPhotoDownloadURL(answer.userID, completion: { (photoDownloadURL, defaultImage) in
            cell.profilePhotoImageButton.setImage(nil, forState: .Normal)
            if photoDownloadURL != nil {
                let url = NSURL(string: photoDownloadURL!)
                cell.profilePhotoImageButton.kf_setImageWithURL(url, forState: .Normal, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"))
                self.formatImage(cell)
            } else {
                cell.profilePhotoImageButton.setImage(UIImage(named: "Profile_avatar_placeholder_large"), forState: .Normal)
                self.formatImage(cell)
            }
        })
        //
        FirebaseMgr.shared.retrieveLikeStatus(answer.answerID, completion: { (likeStatus) in
            if likeStatus == 1 {
                let fullHeartImage = UIImage(named: "heart-full")
                cell.likeButton.setImage(fullHeartImage, forState: .Normal)
            } else if likeStatus == 0 {
                let emptyHeartImage = UIImage(named: "heart-empty")
                cell.likeButton.setImage(emptyHeartImage, forState: .Normal)
            }
            
        })
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    // MARK:
    // MARK: - Image Formatting
    // MARK:
    func formatImage(cell: AnswerCell) {
        cell.profilePhotoImageButton.imageView?.contentMode = .ScaleAspectFill
        cell.profilePhotoImageButton.layer.borderWidth = 1
        cell.profilePhotoImageButton.layer.masksToBounds = false
        cell.profilePhotoImageButton.layer.borderColor = UIColor.blackColor().CGColor
        cell.profilePhotoImageButton.layer.cornerRadius = cell.profilePhotoImageButton.bounds.width/2
        cell.profilePhotoImageButton.clipsToBounds = true
    }
}
// MARK:
// MARK: - AnswerCellDelegate Protocol
// MARK:
extension DiscoverAnswersViewController: AnswerCellDelegate {
    //MARK:
    //MARK: - AnswerCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(row: Int) {
        //        self.selectedIndexRow = row
        //        performSegueWithIdentifier(Constants.Segues.HomeToProfiles, sender: self)
    }
    
    func handleLikeButtonTapOn(row: Int, cell: AnswerCell) {
        let answer = self.answersArray[row]
        guard let questionID = self.selectedQuestionIdDict?["questionID"] else { return }
        FirebaseMgr.shared.saveNewAnswerLikeCount(questionID, answerID: answer.answerID, completion: { (newLikeCount) in
            self.answersArray[row].likeCount = newLikeCount
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
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
        //        var answerDataDict = data
        //        let currentUserID = FIRAuth.auth()?.currentUser?.uid
        //        answerDataDict[Constants.AnswerFields.userID] = currentUserID
        //        let key = self.ref.child("answers").child(questionRef!).childByAutoId().key
        //        let childUpdates = ["answers/\(questionRef!)/\(key)": answerDataDict,
        //                            "likeCounts/\(key)/likeCount": 0,
        //                            "likeStatuses/\(key)/likeStatus": 1]
        //        self.ref.updateChildValues(childUpdates as! [String : AnyObject])
    }
}






















