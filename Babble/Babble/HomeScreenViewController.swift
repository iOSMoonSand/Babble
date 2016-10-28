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
 //MARK:-
 class HomeScreenViewController: UIViewController {
    //MARK: -
    //MARK: - Properties
    //MARK: -
    @IBOutlet weak var tableView: UITableView!
    var newQuestion: String?
    var selectedIndexRow: Int?
    var questionsArray = [Question]() {
        didSet{
            if questionsArray.count == 0 {
                self.tableView.reloadData()
            } else {
            var indexPaths: [NSIndexPath] = []
            indexPaths.append(NSIndexPath(forRow:0, inSection: 0))
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            }
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
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewQuestionCell")
        FirebaseMgr.shared.retrieveHomeQuestions()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.HomeToAnswers {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
            let selectedQuestion = self.questionsArray[selectedIndexPath.row]
            let questionID = selectedQuestion.questionID
            let questionIdDict = ["questionID": questionID]
            guard let destinationVC = segue.destinationViewController as? AnswersViewController else { return }
            destinationVC.selectedQuestionIdDict = questionIdDict
        }
        
        if segue.identifier == Constants.Segues.HomeToUserProfiles {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            guard let selectedIndexRow = self.selectedIndexRow else { return }
            let question = self.questionsArray[selectedIndexRow]
            let userID = question.userID
            guard let destinationVC = segue.destinationViewController as? UserProfileViewController else { return }
            destinationVC.selectedUserID = userID
        }
    }
    // MARK:
    // MARK: - Notification Registration Methods
    // MARK:
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateQuestionsArray), name: Constants.NotifKeys.HomeQuestionsRetrieved, object: nil)
    }
    
    func updateQuestionsArray(){
        self.questionsArray = FirebaseMgr.shared.homeQuestionsArray
    }
    // MARK:
    // MARK: - Notification Unregistration Methods
    // MARK:
    func unregisterForNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    // MARK:
    // MARK: - Button Actions
    // MARK:
        @IBAction func didTapPostAddQuestion(segue:UIStoryboardSegue) {
            //Unwind segue from AddQuestion to HomeScreen
            //Identifier: PostNewQuestionToHome
            let data = [Constants.QuestionFields.text: self.newQuestion! as String]
            postQuestion(data)
        }
    
        func postQuestion(data: [String: AnyObject]) {
            var questionDataDict = data
            guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
            questionDataDict[Constants.QuestionFields.userID] = currentUserID
            questionDataDict[Constants.QuestionFields.likeCount] = 0
            FirebaseMgr.shared.saveNewQuestion(questionDataDict, userID: currentUserID)
        }
    // MARK:
    // MARK: - Unwind Segues
    // MARK:
    @IBAction func didTapBackAnswers(segue:UIStoryboardSegue) {
        //From AddQuestion to HomeScreen
    }
    
    @IBAction func didTapCancelAddQuestion(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func didTapBackProfilesToHome(segue:UIStoryboardSegue) {
        //From UserProfiles to HomeScreen
    }
    // MARK:
    // MARK: - Deinit
    // MARK:
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        //cell.row = indexPath.row
        let question: Question = self.questionsArray[indexPath.row]
        //
        cell.updateViewsWith(question)
        //
        FirebaseMgr.shared.retrieveUserDisplayName(question.userID, completion: { (displayName) in
            cell.displayNameLabel.text = displayName
        })
        //
        FirebaseMgr.shared.retrieveUserPhotoDownloadURL(question.userID, completion: { (photoDownloadURL, defaultImage) in
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
        performSegueWithIdentifier(Constants.Segues.HomeToAnswers, sender: self)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    // MARK:
    // MARK: - Image Formatting
    // MARK:
    func formatImage(cell: QuestionCell) {
        cell.profilePhotoImageButton.imageView?.contentMode = .ScaleAspectFill
        cell.profilePhotoImageButton.layer.borderWidth = 1
        cell.profilePhotoImageButton.layer.masksToBounds = false
        cell.profilePhotoImageButton.layer.borderColor = UIColor.blackColor().CGColor
        cell.profilePhotoImageButton.layer.cornerRadius = cell.profilePhotoImageButton.bounds.width/2
        cell.profilePhotoImageButton.clipsToBounds = true
    }
 }
 // MARK:
 // MARK: - QuestionCellDelegate Protocol
 // MARK:
 extension HomeScreenViewController: QuestionCellDelegate {
    //MARK:
    //MARK: - QuestionCellDelegate Methods
    //MARK:
    func handleProfileImageButtonTapOn(cell: QuestionCell) {
        var selectedIndexPath: NSIndexPath!
        selectedIndexPath = self.tableView.indexPathForCell(cell)
        self.selectedIndexRow = selectedIndexPath.row
        performSegueWithIdentifier(Constants.Segues.HomeToUserProfiles, sender: self)
    }
    
    func handleLikeButtonTapOn(cell: QuestionCell) {
        var selectedIndexPath: NSIndexPath!
        selectedIndexPath = self.tableView.indexPathForCell(cell)
        guard let currentUserID = AppState.sharedInstance.currentUserID else { return }
        let question = self.questionsArray[selectedIndexPath.row]
        var likeStatusesDict = self.questionsArray[selectedIndexPath.row].likeStatuses
        FirebaseMgr.shared.saveNewQuestionLikeCount(question.questionID, completion: { newLikeCount, like in
            self.questionsArray[selectedIndexPath.row].likeCount = newLikeCount
            if like == true && likeStatusesDict != nil {
                self.questionsArray[selectedIndexPath.row].likeStatuses![currentUserID] = true
            } else if like == true && likeStatusesDict == nil {
                self.questionsArray[selectedIndexPath.row].likeStatuses = [currentUserID: true]
            } else if like == false && likeStatusesDict != nil {
                self.questionsArray[selectedIndexPath.row].likeStatuses![currentUserID] = nil
            }
            let indexPath = NSIndexPath(forRow: selectedIndexPath.row, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
    }
 }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
