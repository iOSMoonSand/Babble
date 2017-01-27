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
            var indexPaths: [IndexPath] = []
            indexPaths.append(IndexPath(row:0, section: 0))
            self.tableView.insertRows(at: indexPaths, with: .fade)
            }
        }
    }
    //MARK: -
    //MARK: - UIViewController Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForNotifications()
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewQuestionCell")
        FirebaseMgr.shared.retrieveHomeQuestions()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.HomeToAnswers {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
            let selectedQuestion = self.questionsArray[selectedIndexPath.row]
            let questionID = selectedQuestion.questionID
            let questionIdDict = ["questionID": questionID]
            guard let destinationVC = segue.destination as? AnswersViewController else { return }
            destinationVC.selectedQuestionIdDict = questionIdDict
        }
        
        if segue.identifier == Constants.Segues.HomeToUserProfiles {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            guard let selectedIndexRow = self.selectedIndexRow else { return }
            let question = self.questionsArray[selectedIndexRow]
            let userID = question.userID
            guard let destinationVC = segue.destination as? UserProfileViewController else { return }
            destinationVC.selectedUserID = userID
        }
    }
    // MARK:
    // MARK: - Notification Registration Methods
    // MARK:
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateQuestionsArray), name: NSNotification.Name(rawValue: Constants.NotifKeys.HomeQuestionsRetrieved), object: nil)
    }
    
    func updateQuestionsArray(){
        self.questionsArray = FirebaseMgr.shared.homeQuestionsArray
    }
    // MARK:
    // MARK: - Notification Unregistration Methods
    // MARK:
    func unregisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK:
    // MARK: - Button Actions
    // MARK:
        @IBAction func didTapPostAddQuestion(_ segue:UIStoryboardSegue) {
            //Unwind segue from AddQuestion to HomeScreen
            //Identifier: PostNewQuestionToHome
            let data = [Constants.QuestionFields.text: self.newQuestion! as String]
            postQuestion(data as [String : AnyObject])
        }
    
        func postQuestion(_ data: [String: AnyObject]) {
            var questionDataDict = data
            guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
            questionDataDict[Constants.QuestionFields.userID] = currentUserID as AnyObject?
            questionDataDict[Constants.QuestionFields.likeCount] = 0 as AnyObject?
            FirebaseMgr.shared.saveNewQuestion(questionDataDict, userID: currentUserID)
        }
    // MARK:
    // MARK: - Unwind Segues
    // MARK:
    @IBAction func didTapBackAnswers(_ segue:UIStoryboardSegue) {
        //From AddQuestion to HomeScreen
    }
    
    @IBAction func didTapCancelAddQuestion(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func didTapBackProfilesToHome(_ segue:UIStoryboardSegue) {
        //From UserProfiles to HomeScreen
    }
    // MARK:
    // MARK: - Deinit
    // MARK:
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
 }
 // MARK:
 // MARK: - UITableViewDelegate & UITableViewDataSource Protocols
 // MARK:
 extension HomeScreenViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK:
    // MARK: - UITableViewDataSource & UITableViewDelegate Methods
    // MARK:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
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
                cell.profilePhotoImageButton.setImage(nil, for: UIControlState())
                if photoDownloadURL != nil {
                    let url = URL(string: photoDownloadURL!)
                    cell.profilePhotoImageButton.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "Profile_avatar_placeholder_large"), options: nil, progressBlock: nil, completionHandler: nil)
                    self.formatImage(cell)
                } else {
                    cell.profilePhotoImageButton.setImage(UIImage(named: "Profile_avatar_placeholder_large"), for: UIControlState())
                    self.formatImage(cell)
                }
            })
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Segues.HomeToAnswers, sender: self)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK:
    // MARK: - Image Formatting
    // MARK:
    func formatImage(_ cell: QuestionCell) {
        cell.profilePhotoImageButton.imageView?.contentMode = .scaleAspectFill
        cell.profilePhotoImageButton.layer.borderWidth = 1
        cell.profilePhotoImageButton.layer.masksToBounds = false
        cell.profilePhotoImageButton.layer.borderColor = UIColor.black.cgColor
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
    func handleProfileImageButtonTapOn(_ cell: QuestionCell) {
        var selectedIndexPath: IndexPath!
        selectedIndexPath = self.tableView.indexPath(for: cell)
        self.selectedIndexRow = selectedIndexPath.row
        performSegue(withIdentifier: Constants.Segues.HomeToUserProfiles, sender: self)
    }
    
    func handleLikeButtonTapOn(_ cell: QuestionCell) {
        var selectedIndexPath: IndexPath!
        selectedIndexPath = self.tableView.indexPath(for: cell)
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
            let indexPath = IndexPath(row: selectedIndexPath.row, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        })
    }
    
    func handleFlagButtonTapFor(cell: QuestionCell, questionID: String) {
        let flagAlert = UIAlertController.init(title: "Flagged Content", message: "Are you sure you want to report this content?", preferredStyle: .alert)
        let yesAction = UIAlertAction.init(title: "Yes, it's offensive", style: .default) { (action) in
            FIRAnalytics.logEvent(withName: "conent_flagged", parameters: [
                kFIRParameterItemID: questionID as NSObject
                //add user who flagged?
                ])
            let alert2 = UIAlertController(title: "Thanks", message: "We'll address the issue immediately.", preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                return
            }))
            self.present(alert2, animated: true, completion: nil)
        }
        let noAction = UIAlertAction.init(title: "No", style: .default) { (action) in
            return
        }
        flagAlert.addAction(yesAction)
        flagAlert.addAction(noAction)
        self.present(flagAlert, animated: true, completion: nil)
    }
 }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
