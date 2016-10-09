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
 //MARK-
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
                let rowDifference = self.questionsArray.count - oldValue.count
                changeRowsForDifference(rowDifference, inSection: 0)
            }
        }
    }
    //TODO: understand logic below
    private func changeRowsForDifference(difference: Int, inSection section: Int){
        var indexPaths: [NSIndexPath] = []
        
        let rowOffSet = self.questionsArray.count-1
        
        for i in 0..<abs(difference) {
            indexPaths.append(NSIndexPath(forRow: i + rowOffSet, inSection: section))
        }
        
        if difference > 0 {
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
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
        FirebaseMgr.shared.retrieveHomeQuestions()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateQuestionsArray), name: Constants.NotifKeys.HomeQuestionsRetrieved, object: nil)
    }
    
    func updateQuestionsArray(){
        self.questionsArray = FirebaseMgr.shared.homeQuestionsArray
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
        //
        FirebaseMgr.shared.retrieveLikeStatus(question.questionID, completion: { (likeStatus) in
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
    func handleProfileImageButtonTapOn(row: Int) {
        //        self.selectedIndexRow = row
        //        performSegueWithIdentifier(Constants.Segues.HomeToProfiles, sender: self)
    }
    
    func handleLikeButtonTapOn(row: Int, cell: QuestionCell) {
        let question = self.questionsArray[row]
        FirebaseMgr.shared.saveNewQuestionLikeCount(question.questionID, completion: { (newLikeCount) in
            //cell.likeButton.setImage(nil, forState: .Normal)
            self.questionsArray[row].likeCount = newLikeCount
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
    }
 }
 
 
 
 
 
 
 
 
 //if let photoDownloadURL = self.question[Constants.QuestionFields.photoDownloadURL] as! String? {
 //                            let url = NSURL(string: photoDownloadURL)
 //                            self.profilePhotoImageButton.kf_setImageWithURL(url, forState: .Normal, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"))
 //                        } else if let photoUrl = self.question[Constants.QuestionFields.photoUrl] {
 //                            let image = UIImage(named: "Profile_avatar_placeholder_large")
 //                            self.profilePhotoImageButton.setImage(image, forState: .Normal)
 //                        } else if let photoUrl = self.question[Constants.QuestionFields.photoUrl] {
 //                            FIRStorage.storage().referenceForURL(photoUrl as! String).dataWithMaxSize(INT64_MAX) { (data, error) in
 //                                self.profilePhotoImageButton.setImage(nil, forState: .Normal)
 //                                if error != nil {
 //                                    print("Error downloading: \(error)")
 //                                    return
 //                                } else {
 //                                    let image = UIImage(data: data!)
 //                                    self.profilePhotoImageButton.setImage(image, forState: .Normal)
 //                                }
 //                            }
 //                        }
 //
 //                    } else if let photoUrl = self.question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl as! String), data = NSData(contentsOfURL: url) {
 //                        let image = UIImage(data: data)
 //                        self.profilePhotoImageButton.setImage(image, forState: .Normal)
 //
 //                    }
 //                })
 
 
 
 
 
 
 
 
 
