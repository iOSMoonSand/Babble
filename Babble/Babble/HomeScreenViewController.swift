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
        _refHandle = self.ref.child("questions").observeEventType(.ChildAdded, withBlock: {[weak self] (questionSnapshot) in
            let questionID = questionSnapshot.key
            var question = questionSnapshot.value as! [String: AnyObject]
            question[Constants.QuestionFields.questionID] = questionID
            let userID = question[Constants.QuestionFields.userID] as! String
            //let likeCount = question[Constants.QuestionFields.likeCount] as! Int
            
            let usersRef = self?.ref.child("users")
            usersRef?.child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
                var user = userSnapshot.value as! [String: AnyObject]
                let photoURL = user[Constants.UserFields.photoUrl] as! String
                let displayName = user[Constants.UserFields.displayName] as! String
                
                question[Constants.QuestionFields.photoUrl] = photoURL
                question[Constants.QuestionFields.displayName] = displayName
                
//                var reload = false
//                for dict in (self?.questionsArray)! {
//                    guard let dictQuestionId = dict[Constants.QuestionFields.questionID] as? String else { continue }
//                    guard let newQuestionId = dict[Constants.QuestionFields.questionID] as? String else { continue }
//                    if dictQuestionId == newQuestionId {
//                    //change photo url of dictionary
//                    reload = true
//                    
//                    }
//                    
//                }
//                // check to see if the newest questionId is in the questionsArray, if it is, go to that index in the questionArray and change the imageUrl
//                // if not, append the question to the questionsArray
//                if reload {
//                    self?.tableView.reloadData()
//                } else {
                self?.questionsArray.append(question)
                    self?.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: (self?.questionsArray.count)!-1, inSection: 0)], withRowAnimation: .Automatic)
//                }
                print(self!.questionsArray)
                
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
        
        //cell.likeButton.tag = indexPath.row

        //cell.likeButton.addTarget(self, action: "updateLikeButtonAndCount:", forControlEvents: .TouchUpInside)
        
        //unpack question from local dict
        let question: [String : AnyObject] = self.questionsArray[indexPath.row]
        let questionText = question[Constants.QuestionFields.text] as! String
        let displayName = question[Constants.QuestionFields.displayName] as! String
        //let likeCount = question[Constants.QuestionFields.likeCount] as! Int
        cell.questionTextLabel.text = questionText
        cell.displayNameLabel.text = displayName
        //cell.likeButtonCountLabel.text = String(likeCount)
        if let photoUrl = question[Constants.QuestionFields.photoUrl] {
            print("Photo URL TableView: \(photoUrl)")
            FIRStorage.storage().referenceForURL(photoUrl as! String).dataWithMaxSize(INT64_MAX) { (data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                cell.profilePhotoImageView.image = UIImage(data: data!)
            }
        } else if let photoUrl = question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl as! String), data = NSData(contentsOfURL: url) {
                cell.profilePhotoImageView.image = UIImage(data: data)
        } else {
            cell.profilePhotoImageView.image = UIImage(named: "ic_account_circle")
        }
//TODO: is this the right way to reload the data?
        return cell
    }
    
    @IBAction func updateLikeButtonAndCount(sender: UIButton) {
        print("tap fired")
        var question: [String : AnyObject] = self.questionsArray[sender.tag]
        let likeCount = question[Constants.QuestionFields.likeCount] as! Int
        question[Constants.QuestionFields.likeCount] = likeCount + 1
        let incrementedLikeCount = question[Constants.QuestionFields.likeCount] as! Int
        let questionID = question[Constants.QuestionFields.questionID] as! String
        self.ref.child("questions/\(questionID)/likeCount").setValue(incrementedLikeCount)
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
    
    @IBAction func didTapCancelAddQuestion(segue:UIStoryboardSegue) {
        //unwind segue from AddQuestion to HomeScreen
        
    }
    
    @IBAction func didTapPostAddQuestion(segue:UIStoryboardSegue) {
        //unwind segue from AddQuestion to HomeScreen
        let data = [Constants.QuestionFields.text: newQuestion! as String]
        postQuestion(data)
    }
    
    func postQuestion(data: [String: String]) {
        
        var questionDataDict = data
        guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
        questionDataDict[Constants.QuestionFields.userID] = currentUserID
        self.ref.child("questions").childByAutoId().setValue(questionDataDict)
    }

    
}








