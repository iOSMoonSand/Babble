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
                var indexPaths: [IndexPath] = []
                indexPaths.append(IndexPath(row:0, section: 0))
                self.tableView.insertRows(at: indexPaths, with: .fade)
            }
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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewAnswerCell")
        FirebaseMgr.shared.retrieveHomeAnswers()
        self.formatTextView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segues.AnswersToUserProfiles {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            guard let selectedIndexRow = self.selectedIndexRow else { return }
            let question = self.answersArray[selectedIndexRow]
            let userID = question.userID
            guard let destinationVC = segue.destination as? UserProfileViewController else { return }
            destinationVC.selectedUserID = userID
        }
    }
    
    func formatTextView() {
        self.sendAnswerTextView.layer.borderWidth = 1
        self.sendAnswerTextView.layer.borderColor = UIColor.darkGray.cgColor
        self.sendAnswerTextView.clipsToBounds = true
        self.sendAnswerTextView.layer.cornerRadius = 6
        self.sendAnswerTextView.text = "Write a comment here!"
        self.sendAnswerTextView.textColor = UIColor.lightGray
    }
    // MARK:
    // MARK: - Notification Registration Methods
    // MARK:
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateAnswersArray), name: NSNotification.Name(rawValue: Constants.NotifKeys.HomeAnswersRetrieved), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object:nil)
    }
    //MARK:
    //MARK: - NSNotification Methods
    //MARK:
    var kbHeight: CGFloat!
    
    func keyboardWasShown(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        guard let kbSize = (info[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size as? CGSize? else { return }
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, ((kbSize?.height)! + 8.0), 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= (kbSize?.height)!
        
        if (!aRect.contains(self.sendAnswerTextView.frame.origin)) {
            self.scrollView.scrollRectToVisible(self.sendAnswerTextView.frame, animated: true)
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    // MARK:
    // MARK: - Unregister Notifications & Obvservers
    // MARK:
    override func viewDidDisappear(_ animated: Bool) {
        guard let questionID = self.selectedQuestionIdDict?["questionID"] else { return }
        FirebaseMgr.shared.removeAnswerObservers(For: questionID)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object:nil)
    }
    
    func updateAnswersArray() {
        self.answersArray = FirebaseMgr.shared.homeAnswersArray
    }
    // MARK:
    // MARK: - Notification Post Methods
    // MARK:
    func postNotifications() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotifKeys.SendQuestionID), object: self, userInfo: self.selectedQuestionIdDict)
    }
    // MARK:
    // MARK: - Button Actions
    // MARK:
    
    @IBAction func didTapSendAnswerButton(_ sender: UIButton) {
        self.sendAnswerTextView.textColor = UIColor.lightGray
        let data = [Constants.AnswerFields.text: self.sendAnswerTextView.text! as String]
        sendAnswer(data as [String : AnyObject])
        self.sendAnswerTextView.resignFirstResponder()
        self.sendAnswerTextView.text = "Thanks for the comment :)"
        self.tableView.allowsSelection = true
        self.view.removeGestureRecognizer(tapOutsideTextView)
    }
    
    func sendAnswer(_ data: [String: AnyObject]) {
        var answerDataDict = data
        guard let
            currentUserID = FIRAuth.auth()?.currentUser?.uid,
            let questionID = self.selectedQuestionIdDict?["questionID"]
            else { return }
        answerDataDict[Constants.AnswerFields.userID] = currentUserID as AnyObject?
        FirebaseMgr.shared.saveNewAnswer(answerDataDict, questionID: questionID, userID: currentUserID)
    }
    // MARK:
    // MARK: - Unwind Segues
    // MARK:
    @IBAction func didTapBackProfilesToAnswers(_ segue:UIStoryboardSegue) {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.answersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath) as! AnswerCell
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
            cell.profilePhotoImageButton.setImage(nil, for: UIControlState())
            if photoDownloadURL != nil {
                let url = URL(string: photoDownloadURL!)
                cell.profilePhotoImageButton.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "Profile_avatar_placeholder_large"), options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                cell.profilePhotoImageButton.setImage(UIImage(named: "Profile_avatar_placeholder_large"), for: UIControlState())
                self.formatImage(cell)
            }
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK:
    // MARK: - Image Formatting
    // MARK:
    func formatImage(_ cell: AnswerCell) {
        cell.profilePhotoImageButton.imageView?.contentMode = .scaleAspectFill
        cell.profilePhotoImageButton.layer.borderWidth = 1
        cell.profilePhotoImageButton.layer.masksToBounds = false
        cell.profilePhotoImageButton.layer.borderColor = UIColor.black.cgColor
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
    func handleProfileImageButtonTapOn(_ cell: AnswerCell) {
        var selectedIndexPath: IndexPath!
        selectedIndexPath = self.tableView.indexPath(for: cell)
        self.selectedIndexRow = selectedIndexPath.row
        performSegue(withIdentifier: Constants.Segues.AnswersToUserProfiles, sender: self)
    }
}

// MARK:
// MARK: - UITextViewDelegate Protocol
// MARK:
extension AnswersViewController: UITextViewDelegate {
    // MARK:
    // MARK: - UITextViewDelegate Methods
    // MARK:
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        if self.sendAnswerTextView.text == "Write a comment here!" || self.sendAnswerTextView.text == "Thanks for the comment :)" {
            self.sendAnswerTextView.text = ""
            self.sendAnswerTextView.textColor = UIColor.black
        }
        self.tableView.allowsSelection = false
        self.tapOutsideTextView = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutsideTextViewWhenEditing))
        self.view.addGestureRecognizer(tapOutsideTextView)
    }
    
    func didTapOutsideTextViewWhenEditing() {
        self.view.endEditing(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        if self.sendAnswerTextView.text.isEmpty {
            self.sendAnswerTextView.text = "Write a comment here!"
            self.sendAnswerTextView.textColor = UIColor.lightGray
        }
        self.tableView.allowsSelection = true
        self.view.removeGestureRecognizer(tapOutsideTextView)
    }
}






















