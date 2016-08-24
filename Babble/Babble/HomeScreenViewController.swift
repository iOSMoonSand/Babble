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
class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
    //MARK: -
    //MARK: - Properties
    //MARK: -
    @IBOutlet weak var tableView: UITableView!
    private var _refHandle: FIRDatabaseHandle!
    private var _photoURLrefHandle: FIRDatabaseHandle!
    var questionsArray = [[String : AnyObject]]()
    var profilePhotoString: String?
    var newQuestion: String?
    var userArray = [String]()
    var selectedIndexRow: Int?
    //MARK: -
    //MARK: - UIViewController Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        self.configureDatabase()
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
    // MARK: - Firebase Database Configuration
    // MARK:
    func configureDatabase() {
        _refHandle = FirebaseConfigManager.sharedInstance.ref.child("questions").observeEventType(.Value, withBlock: {/*[weak self]*/ (questionSnapshot) in
            let questionID = questionSnapshot.key
            
            
            
            var questions = questionSnapshot.value as! [String: AnyObject]
            
            
            for (key, obj) in question {
                let test = obj as! [String : AnyObject]
                NSLog("question", test)
            }
            re
            
            
            
            
            
            
            
            question[Constants.QuestionFields.questionID] = questionID
            let likeCount = question[Constants.QuestionFields.likeCount] as! Int
            let userID = question[Constants.QuestionFields.userID] as! String
            AppState.sharedInstance.likeCountQuestionID = questionID
            
            FirebaseConfigManager.sharedInstance.ref.child("likeCounts").child(AppState.sharedInstance.likeCountQuestionID).observeEventType(.ChildChanged, withBlock: {(likeCountSnapshot) in
                let likeCount = likeCountSnapshot.value as! Int
                
                question[Constants.QuestionFields.likeCount] = likeCount
                
//                var indexesToReload = [NSIndexPath]()
//                var reload = false
                for (index, var dict) in self.questionsArray.enumerate() {
                    guard let dictQuestionId = dict[Constants.QuestionFields.questionID] as? String else { continue }
                    guard let newQuestionId = question[Constants.QuestionFields.questionID] as? String else { continue }
                    if (dictQuestionId == newQuestionId) {
                        //reload = true
                        self.questionsArray[index][Constants.QuestionFields.likeCount] = likeCount
                        //indexesToReload.append(NSIndexPath(forRow: index, inSection: 0))
                    }
                }
//                if reload {
//                    self.tableView.reloadRowsAtIndexPaths(indexesToReload, withRowAnimation: .None)
//                } else {
//                    self.questionsArray.append(question)
//                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: (self.questionsArray.count)-1, inSection: 0)], withRowAnimation: .Automatic)
//                }
                self.questionsArray.sortInPlace {
                    (($0 as [String: AnyObject])["likeCount"] as? Int) > (($1 as [String: AnyObject])["likeCount"] as? Int)
                }
                self.tableView.reloadData()
            })
            let usersRef = FirebaseConfigManager.sharedInstance.ref.child("users")
            usersRef.child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
                var user = userSnapshot.value as! [String: AnyObject]
                let photoURL = user[Constants.UserFields.photoUrl] as! String
                let displayName = user[Constants.UserFields.displayName] as! String
                
                question[Constants.QuestionFields.photoUrl] = photoURL
                question[Constants.QuestionFields.displayName] = displayName
                
                var indexesToReload = [NSIndexPath]()
                var reload = false
                for (index, var dict) in self.questionsArray.enumerate() {
                    guard let dictQuestionId = dict[Constants.QuestionFields.questionID] as? String else { continue }
                    guard let newQuestionId = question[Constants.QuestionFields.questionID] as? String else { continue }
                    if (dictQuestionId == newQuestionId) {
                        reload = true
                        self.questionsArray[index][Constants.QuestionFields.photoUrl] = photoURL
                        indexesToReload.append(NSIndexPath(forRow: index, inSection: 0))
                    }
                }
                if reload {
                    self.tableView.reloadRowsAtIndexPaths(indexesToReload, withRowAnimation: .None)
                } else {
                    self.questionsArray.append(question)
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: (self.questionsArray.count)-1, inSection: 0)], withRowAnimation: .Automatic)
                }
                })
            { (error) in
                print(error.localizedDescription)
            }
        })
    }
    // MARK:
    // MARK: - UITableViewDataSource & UITableViewDelegate methods
    // MARK:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionCell
        
        cell.delegate = self
        cell.row = indexPath.row
        
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: "tapFiredLikeButton:", forControlEvents: .TouchUpInside)
        
        //unpack question from local dict
        let question: [String : AnyObject] = self.questionsArray[indexPath.row]
        let questionText = question[Constants.QuestionFields.text] as! String
        let displayName = question[Constants.QuestionFields.displayName] as! String
        let likeCount = question[Constants.QuestionFields.likeCount] as! Int
        cell.questionTextLabel.text = questionText
        cell.displayNameLabel.text = displayName
        cell.likeButtonCountLabel.text = String(likeCount)
        cell.profilePhotoImageButton.setBackgroundImage(nil, forState: .Normal)
        if let photoUrl = question[Constants.QuestionFields.photoUrl] {
            FIRStorage.storage().referenceForURL(photoUrl as! String).dataWithMaxSize(INT64_MAX) { (data, error) in
                if error != nil {
                    print("Error downloading: \(error)")
                    return
                } else {
                    let image = UIImage(data: data!)
                    cell.profilePhotoImageButton.setBackgroundImage(image, forState: .Normal)
                }
            }
        } else if let photoUrl = question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl as! String), data = NSData(contentsOfURL: url) {
            let image = UIImage(data: data)
            cell.profilePhotoImageButton.setBackgroundImage(image, forState: .Normal)
            
        } else {
            let image = UIImage(named: "ic_account_circle")
            cell.profilePhotoImageButton.setBackgroundImage(image, forState: .Normal)
        }
        return cell
    }
    
    @IBAction func tapFiredLikeButton(sender: UIButton) {
        
        print("tap fired for like button")
        var question: [String : AnyObject] = self.questionsArray[sender.tag]
        let likeCount = question[Constants.QuestionFields.likeCount] as! Int
        question[Constants.QuestionFields.likeCount] = likeCount + 1
        let incrementedLikeCount = question[Constants.QuestionFields.likeCount] as! Int
        let questionID = question[Constants.QuestionFields.questionID] as! String
        FirebaseConfigManager.sharedInstance.ref.child("likeCounts/\(questionID)/likeCount").setValue(incrementedLikeCount)
        FirebaseConfigManager.sharedInstance.ref.child("questions/\(questionID)/likeCount").setValue(incrementedLikeCount)
        AppState.sharedInstance.likeCountQuestionID = questionID
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Constants.Segues.HomeToAnswers, sender: self)
    }
    
    // MARK:
    // MARK: - IBActions
    // MARK:
    @IBAction func didTapSignOut(sender: AnyObject) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            performSegueWithIdentifier(Constants.Segues.HomeToSignIn, sender: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
    }
    
    @IBAction func didTapBackAnswers(segue:UIStoryboardSegue) {
        //unwind segue from AddQuestion to HomeScreen
        
    }
    
    @IBAction func didTapCancelAddQuestion(segue:UIStoryboardSegue) {
        //unwind segue from AddQuestion to HomeScreen
        
    }
    
    @IBAction func didTapPostAddQuestion(segue:UIStoryboardSegue) {
        //unwind segue from AddQuestion to HomeScreen
        let data = [Constants.QuestionFields.text: newQuestion! as String]
        postQuestion(data)
    }
    
    @IBAction func didTapBackProfiles(segue:UIStoryboardSegue) {
        //unwind segue from UserProfiles to HomeScreen
        
    }
    
    func postQuestion(data: [String: AnyObject]) {
        
        var questionDataDict = data
        guard let currentUserID = FirebaseConfigManager.sharedInstance.currentUser?.uid else { return }
        questionDataDict[Constants.QuestionFields.userID] = currentUserID
        questionDataDict[Constants.QuestionFields.likeCount] = 0
        FirebaseConfigManager.sharedInstance.ref.child("questions").childByAutoId().setValue(questionDataDict)
    }
    
    
}

extension HomeScreenViewController: QuestionCellDelegate {
    
    func handleButtonTapOn(row: Int) {
        selectedIndexRow = row
        performSegueWithIdentifier(Constants.Segues.HomeToProfile, sender: self)
    }
}






