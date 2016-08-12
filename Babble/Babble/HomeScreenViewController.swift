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
class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    //MARK: -
    //MARK: - Properties
    //MARK: -
    @IBOutlet weak var tableView: UITableView!
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    private var _photoURLrefHandle: FIRDatabaseHandle!
    var storageRef: FIRStorageReference!
    var questionsArray: [Dictionary<String, String>]! = []
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
        if segue.identifier == Constants.Segues.HomeToAnswersNavController {
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
            let questionSnapShot: Dictionary<String, String>! = self.questionsArray[selectedIndexPath.row]
            let questionID = questionSnapShot[Constants.QuestionFields.questionID]
            guard let destinationVC = segue.destinationViewController as? AnswersViewController else { return }
            destinationVC.questionRef = questionID as String!
        }
    }
    // MARK:
    // MARK: - Firebase Database Configuration
    // MARK:
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        _refHandle = self.ref.child("questions").observeEventType(.ChildAdded, withBlock: {(questionSnapshot) in
            
            let questionID = questionSnapshot.key
            var question = questionSnapshot.value as! Dictionary<String, String>
            question[Constants.QuestionFields.questionID] = questionID
            let userID = question[Constants.QuestionFields.userID] as String!
            
            let usersRef = self.ref.child("users")
            usersRef.child(userID).observeSingleEventOfType(.Value, withBlock: { (userSnapshot) in
                var user = userSnapshot.value as! Dictionary<String, String>
                let photoURL = user[Constants.UserFields.photoUrl] as String!
                let displayName = FIRAuth.auth()?.currentUser?.displayName as String!
                
                question[Constants.QuestionFields.photoUrl] = photoURL
                question[Constants.QuestionFields.displayName] = displayName
                
                self.questionsArray.append(question)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.questionsArray.count-1, inSection: 0)], withRowAnimation: .Automatic)
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
        //unpack question from local dict
        let question: Dictionary<String, String>! = self.questionsArray[indexPath.row]
        let questionText = question[Constants.QuestionFields.text] as String!
        let displayName = question[Constants.QuestionFields.displayName] as String!
        cell.questionTextLabel.text = questionText
        //cell.displayNameLabel = displayName
        if let photoUrl = question[Constants.QuestionFields.photoUrl] {
            FIRStorage.storage().referenceForURL(photoUrl).dataWithMaxSize(INT64_MAX) { (data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                cell.profilePhotoImageView.image = UIImage(data: data!)
            }
        } else if let photoUrl = question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
                cell.profilePhotoImageView.image = UIImage(data: data)
        } else {
            cell.profilePhotoImageView.image = UIImage(named: "ic_account_circle")
        }
//TODO: is this the right way to reload the data?
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Constants.Segues.HomeToAnswersNavController, sender: self)
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






//class StandardTableViewCell : UITableViewCell {
//    //attributes
//    
//    //outlets
//    @IBOutlet weak var avatarImageView : UIImage!
//    func perform(/*param1: param2:*/) {
//        //Excute Completion block ----> Response {
//        /*
//            self.avatarImageView = UIImage(data:data)
//        */
//    }
//}







