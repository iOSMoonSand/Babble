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
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    private var _photoURLrefHandle: FIRDatabaseHandle!
    var storageRef: FIRStorageReference!
    var questionsArray = [[String : AnyObject]]()
    var profilePhotoString: String?
    var newQuestion: String?
    var userArray = [String]()
    //MARK: -
    //MARK: - UIViewController Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        self.configureDatabase()
    }
    
    deinit {
        self.ref.child("questions").removeObserverWithHandle(_refHandle)
        // repeat for photoURLRefHandle
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
    }
    // MARK:
    // MARK: - Firebase Database Configuration
    // MARK:
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        _refHandle = self.ref.child("questions").observeEventType(.ChildAdded, withBlock: {/*[weak self]*/ (questionSnapshot) in
            let questionID = questionSnapshot.key
            var question = questionSnapshot.value as! [String: AnyObject]
            question[Constants.QuestionFields.questionID] = questionID
            let likeCount = question[Constants.QuestionFields.likeCount] as! Int
            let userID = question[Constants.QuestionFields.userID] as! String
            AppState.sharedInstance.likeCountQuestionID = questionID
            
            self.ref.child("likeCounts").child(AppState.sharedInstance.likeCountQuestionID).observeEventType(.ChildChanged, withBlock: {(likeCountSnapshot) in
                let likeCount = likeCountSnapshot.value as! Int
                
                question[Constants.QuestionFields.likeCount] = likeCount
                
                var indexesToReload = [NSIndexPath]()
                var reload = false
                for (index, var dict) in self.questionsArray.enumerate() {
                    guard let dictQuestionId = dict[Constants.QuestionFields.questionID] as? String else { continue }
                    guard let newQuestionId = question[Constants.QuestionFields.questionID] as? String else { continue }
                    if (dictQuestionId == newQuestionId) {
                        reload = true
                        self.questionsArray[index][Constants.QuestionFields.likeCount] = likeCount
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
            
            let usersRef = self.ref.child("users")
            usersRef.child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
                var user = userSnapshot.value as! [String: AnyObject]
                let photoURL = user[Constants.UserFields.photoUrl] as! String
                let displayName = user[Constants.UserFields.displayName] as! String
                
                question[Constants.QuestionFields.photoUrl] = photoURL
                question[Constants.QuestionFields.displayName] = displayName
                
                var indexesToReload = [NSIndexPath]()
                
                var reload = false
                //guard let questionsArray = self.questionsArray else { return }
//                var i = 0
                for (index, var dict) in self.questionsArray.enumerate() {
                    guard let dictQuestionId = dict[Constants.QuestionFields.questionID] as? String else { continue }
                    guard let newQuestionId = question[Constants.QuestionFields.questionID] as? String else { continue }
                    if (dictQuestionId == newQuestionId) {
                    //change photo url of dictionary
                        reload = true
//                        i = index
                        
//                        var questionToChange = self.questionsArray[i]
//                        let photoURL = question[Constants.QuestionFields.photoUrl]
                        self.questionsArray[index][Constants.QuestionFields.photoUrl] = photoURL
//                        print("Photo URL in for loop: \(photoURL)")
//                        print("QuestionToChange Photo URL : \(questionToChange[Constants.QuestionFields.photoUrl])")
                        indexesToReload.append(NSIndexPath(forRow: index, inSection: 0))
                    }
                    
                }
                // check to see if the newest questionId is in the questionsArray, if it is, go to that index in the questionArray and change the imageUrl
                // if not, append the question to the questionsArray
                if reload {
//                    var questionToChange = self.questionsArray[i]
//                    let photoURL = question[Constants.QuestionFields.photoUrl]
//                    questionToChange[Constants.QuestionFields.photoUrl] = photoURL
//                    print("Photo URL in for loop: \(photoURL)")
//                    print("QuestionToChange Photo URL : \(questionToChange[Constants.QuestionFields.photoUrl])")
//                    self.tableView.reloadData()
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
        cell.profilePhotoImageView.image = nil
        if let photoUrl = question[Constants.QuestionFields.photoUrl] {
            FIRStorage.storage().referenceForURL(photoUrl as! String).dataWithMaxSize(INT64_MAX) { (data, error) in
                if error != nil {
                    print("Error downloading: \(error)")
                    return
                } else {
                    cell.profilePhotoImageView.image = UIImage(data: data!)
                }
            }
        } else if let photoUrl = question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl as! String), data = NSData(contentsOfURL: url) {
                cell.profilePhotoImageView.image = UIImage(data: data)
        } else {
            cell.profilePhotoImageView.image = UIImage(named: "ic_account_circle")
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
        self.ref.child("likeCounts/\(questionID)/likeCount").setValue(incrementedLikeCount)
        self.ref.child("questions/\(questionID)/likeCount").setValue(incrementedLikeCount)
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

    func postQuestion(data: [String: AnyObject]) {
        
        var questionDataDict = data
        guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
        questionDataDict[Constants.QuestionFields.userID] = currentUserID
        questionDataDict[Constants.QuestionFields.likeCount] = 0
        self.ref.child("questions").childByAutoId().setValue(questionDataDict)
    }

    
}








