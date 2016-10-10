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
//    //MARK: - Properties
//    //MARK: -
//    
//    @IBOutlet weak var tableView: UITableView!
//    var newQuestion: String?
//    var selectedIndexRow: Int?
//    var questionsArray = [Question]() {
//        didSet{
//            if oldValue.count == 0 {
//                self.tableView.reloadData()
//            } else {
//                let rowDifference = self.questionsArray.count - oldValue.count
//                changeRowsForDifference(rowDifference, inSection: 0)
//            }
//        }
//    }
//    //TODO: understand logic below
//    private func changeRowsForDifference(difference: Int, inSection section: Int){
//        var indexPaths: [NSIndexPath] = []
//        
//        let rowOffSet = self.questionsArray.count-1
//        
//        for i in 0..<abs(difference) {
//            indexPaths.append(NSIndexPath(forRow: i + rowOffSet, inSection: section))
//        }
//        
//        if difference > 0 {
//            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
//        }
//    }
//    //MARK: -
//    //MARK: - UIViewController Methods
//    //MARK: -
//    override func viewDidLoad() {
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        self.registerForNotifications()
//        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
//        FirebaseMgr.shared.retrieveDiscoverQuestions()
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//        if segue.identifier == Constants.Segues.DiscoverToDiscoverAnswers {
//            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
//            let selectedQuestion = self.questionsArray[selectedIndexPath.row]
//            let questionID = selectedQuestion.questionID
//            let questionIdDict = ["questionID": questionID]
//            guard let destinationVC = segue.destinationViewController as? DiscoverAnswersViewController else { return }
//            destinationVC.selectedQuestionIdDict = questionIdDict
//        }
//        
//        if segue.identifier == Constants.Segues.DiscoverToUserProfiles {
//            guard let selectedIndexRow = self.selectedIndexRow else { return }
//            let question = self.questionsArray[selectedIndexRow]
//            let userID = question.userID
//            guard let destinationVC = segue.destinationViewController as? UserProfileViewController else { return }
//            destinationVC.selectedUserID = userID
//        }
//    }
//    // MARK:
//    // MARK: - Notification Registration Methods
//    // MARK:
//    func registerForNotifications() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateQuestionsArray), name: Constants.NotifKeys.DiscoverQuestionsRetrieved, object: nil)
//    }
//    
//    func updateQuestionsArray(){
//        self.questionsArray = FirebaseMgr.shared.discoverQuestionsArray
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
//        questionDataDict[Constants.QuestionFields.likeCount] = 0
//        FirebaseMgr.shared.saveNewQuestion(questionDataDict, userID: currentUserID)
//    }
//    // MARK:
//    // MARK: - Unwind Segues
//    // MARK:
//    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
//        print("help me")
//    }
//    
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
//        let question: Question = self.questionsArray[indexPath.row]
//        //
//        cell.updateViewsWith(question)
//        //
//        FirebaseMgr.shared.retrieveUserDisplayName(question.userID, completion: { (displayName) in
//            cell.displayNameLabel.text = displayName
//        })
//        //
//        FirebaseMgr.shared.retrieveUserPhotoDownloadURL(question.userID, completion: { (photoDownloadURL, defaultImage) in
//            cell.profilePhotoImageButton.setImage(nil, forState: .Normal)
//            if photoDownloadURL != nil {
//                let url = NSURL(string: photoDownloadURL!)
//                cell.profilePhotoImageButton.kf_setImageWithURL(url, forState: .Normal, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"))
//                self.formatImage(cell)
//            } else {
//                cell.profilePhotoImageButton.setImage(UIImage(named: "Profile_avatar_placeholder_large"), forState: .Normal)
//                self.formatImage(cell)
//            }
//        })
//        //
//        FirebaseMgr.shared.retrieveLikeStatus(question.questionID, completion: { (likeStatus) in
//            if likeStatus == 1 {
//                let fullHeartImage = UIImage(named: "heart-full")
//                cell.likeButton.setImage(fullHeartImage, forState: .Normal)
//            } else if likeStatus == 0 {
//                let emptyHeartImage = UIImage(named: "heart-empty")
//                cell.likeButton.setImage(emptyHeartImage, forState: .Normal)
//            }
//        })
//        return cell
//    }
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        performSegueWithIdentifier(Constants.Segues.DiscoverToDiscoverAnswers, sender: self)
//        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }
//    // MARK:
//    // MARK: - Image Formatting
//    // MARK:
//    func formatImage(cell: DiscoverQuestionCell) {
//        cell.profilePhotoImageButton.imageView?.contentMode = .ScaleAspectFill
//        cell.profilePhotoImageButton.layer.borderWidth = 1
//        cell.profilePhotoImageButton.layer.masksToBounds = false
//        cell.profilePhotoImageButton.layer.borderColor = UIColor.blackColor().CGColor
//        cell.profilePhotoImageButton.layer.cornerRadius = cell.profilePhotoImageButton.bounds.width/2
//        cell.profilePhotoImageButton.clipsToBounds = true
//    }
//
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
//        performSegueWithIdentifier(Constants.Segues.DiscoverToUserProfiles, sender: self)
//    }
//    
//    func handleLikeButtonTapOn(row: Int, cell: DiscoverQuestionCell) {
//        let question = self.questionsArray[row]
//        FirebaseMgr.shared.saveNewQuestionLikeCount(question.questionID, completion: { (newLikeCount) in
//            //cell.likeButton.setImage(nil, forState: .Normal)
//            self.questionsArray[row].likeCount = newLikeCount
//            let indexPath = NSIndexPath(forRow: row, inSection: 0)
//            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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
