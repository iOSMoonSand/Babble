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
    // MARK: - Properties
    // MARK:
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendAnswerTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    var selectedQuestionIdDict: [String: String]?
    var selectedIndexRow: Int?
    var tapOutsideTextView = UITapGestureRecognizer()
    var answersArray = [Answer]() {
        didSet{
            if answersArray.count == 0 {
                self.tableView.reloadData()
            } else {
                var indexPaths: [NSIndexPath] = []
                indexPaths.append(NSIndexPath(forRow:0, inSection: 0))
                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            }
        }
    }
    private func changeRowsForDifference(difference: Int, inSection section: Int){
        var indexPaths: [NSIndexPath] = []
        
        let rowOffSet = self.answersArray.count-1
        
        for i in 0..<abs(difference) {
            indexPaths.append(NSIndexPath(forRow: i + rowOffSet, inSection: section))
        }
        
        if difference > 0 {
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
    }
    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.sendAnswerTextView.delegate = self
        self.registerForNotifications()
        self.postNotifications()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewAnswerCell")
        FirebaseMgr.shared.retrieveHomeAnswers()
        self.formatTextView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == Constants.Segues.AnswersToUserProfiles {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            guard let selectedIndexRow = self.selectedIndexRow else { return }
            let question = self.answersArray[selectedIndexRow]
            let userID = question.userID
            guard let destinationVC = segue.destinationViewController as? UserProfileViewController else { return }
            destinationVC.selectedUserID = userID
        }
    }
    
    func formatTextView() {
        self.sendAnswerTextView.layer.borderWidth = 1
        self.sendAnswerTextView.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.sendAnswerTextView.clipsToBounds = true
        self.sendAnswerTextView.layer.cornerRadius = 6
        self.sendAnswerTextView.text = "Write a comment here!"
        self.sendAnswerTextView.textColor = UIColor.lightGrayColor()
    }
    // MARK:
    // MARK: - Notification Registration Methods
    // MARK:
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateAnswersArray), name: Constants.NotifKeys.HomeAnswersRetrieved, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object:nil)
    }
    //MARK:
    //MARK: - NSNotification Methods
    //MARK:
    var kbHeight: CGFloat!
    
    func keyboardWasShown(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let kbSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size as? CGSize? else { return }
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, ((kbSize?.height)! + 8.0), 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= (kbSize?.height)!
        
        if (!CGRectContainsPoint(aRect, self.sendAnswerTextView.frame.origin)) {
            self.scrollView.scrollRectToVisible(self.sendAnswerTextView.frame, animated: true)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    // MARK:
    // MARK: - Unregister Notifications & Obvservers
    // MARK:
    override func viewDidDisappear(animated: Bool) {
        guard let questionID = self.selectedQuestionIdDict?["questionID"] else { return }
        FirebaseMgr.shared.removeAnswerObservers(For: questionID)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object:nil)
    }
    
    func updateAnswersArray() {
        self.answersArray = FirebaseMgr.shared.homeAnswersArray
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
        self.sendAnswerTextView.textColor = UIColor.lightGrayColor()
        let data = [Constants.AnswerFields.text: self.sendAnswerTextView.text! as String]
        sendAnswer(data)
        self.sendAnswerTextView.resignFirstResponder()
        self.sendAnswerTextView.text = "Thanks for the comment :)"
        self.tableView.allowsSelection = true
        self.view.removeGestureRecognizer(tapOutsideTextView)
    }
    
    
    
    func sendAnswer(data: [String: AnyObject]) {
        var answerDataDict = data
        guard let
            currentUserID = FIRAuth.auth()?.currentUser?.uid,
            questionID = self.selectedQuestionIdDict?["questionID"]
            else { return }
        answerDataDict[Constants.AnswerFields.userID] = currentUserID
        FirebaseMgr.shared.saveNewAnswer(answerDataDict, questionID: questionID, userID: currentUserID)
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
extension AnswersViewController: AnswerCellDelegate {
    //MARK:
    //MARK: - AnswerCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(cell: AnswerCell) {
        var selectedIndexPath: NSIndexPath!
        selectedIndexPath = self.tableView.indexPathForCell(cell)
        self.selectedIndexRow = selectedIndexPath.row
        performSegueWithIdentifier(Constants.Segues.AnswersToUserProfiles, sender: self)
    }
}

// MARK:
// MARK: - UITextViewDelegate Protocol
// MARK:
extension AnswersViewController: UITextViewDelegate {
    // MARK:
    // MARK: - UITextViewDelegate Methods
    // MARK:
    func textViewDidBeginEditing(textView: UITextView) {
        print("textViewDidBeginEditing")
        if self.sendAnswerTextView.text == "Write a comment here!" || self.sendAnswerTextView.text == "Thanks for the comment :)" {
            self.sendAnswerTextView.text = ""
            self.sendAnswerTextView.textColor = UIColor.blackColor()
        }
        self.tableView.allowsSelection = false
        self.tapOutsideTextView = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutsideTextViewWhenEditing))
        self.view.addGestureRecognizer(tapOutsideTextView)
    }
    
    func didTapOutsideTextViewWhenEditing() {
        self.view.endEditing(true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("textViewDidEndEditing")
        if self.sendAnswerTextView.text.isEmpty {
            self.sendAnswerTextView.text = "Write a comment here!"
            self.sendAnswerTextView.textColor = UIColor.lightGrayColor()
        }
        self.tableView.allowsSelection = true
        self.view.removeGestureRecognizer(tapOutsideTextView)
    }
}






















