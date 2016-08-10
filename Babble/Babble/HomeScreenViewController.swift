//
//  HomeScreenViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/02/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    //MARK: -
    //MARK: - Properties
    //MARK: -
    @IBOutlet weak var tableView: UITableView!
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    private var _photoURLrefHandle: FIRDatabaseHandle!
    var storageRef: FIRStorageReference!
    var questionsArray: [FIRDataSnapshot]! = []
    var profilePhotoString: String?
    var newQuestion: String?
    var photoUrlArray = [String]()
    //MARK: -
    //MARK: - UIViewController Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        self.configureDatabase()
        self.configureStorage()
    }
    
    deinit {
        self.ref.child("questions").removeObserverWithHandle(_refHandle)
        // repeat for photoURLRefHandle
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.HomeToAnswersNavController {
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
            let questionSnapShot: FIRDataSnapshot! = self.questionsArray[selectedIndexPath.row]
            let selectedQuestion = questionSnapShot.key
            guard let destinationVC = segue.destinationViewController as? AnswersViewController else { return }
            destinationVC.questionRef = selectedQuestion
        }
    }
    // MARK:
    // MARK: - Firebase Database Configuration
    // MARK:
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        _refHandle = self.ref.child("questions").observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
            self.questionsArray.append(snapshot)
            
            if let uid = snapshot.value?[Constants.QuestionFields.userUID] as? String {
                self._photoURLrefHandle = self.ref.child("userInfo").child(uid).observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
                    if let photoURL = snapshot.value as? String {
                        self.photoUrlArray.append(photoURL)
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.questionsArray.count-1, inSection: 0)], withRowAnimation: .Automatic)
                    }
                })
            }
        })
    }
    // MARK:
    // MARK: - Firebase StorageConfiguration
    // MARK:
    func configureStorage() {
        storageRef = FIRStorage.storage().referenceForURL("gs://babble-8b668.appspot.com/")
    }
    // MARK:
    // MARK: - UITableViewDataSource & UITableViewDelegate methods
    // MARK:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath)
        //unpack question from database
        let questionSnapshot: FIRDataSnapshot! = self.questionsArray[indexPath.row]
        var question = questionSnapshot.value as! Dictionary<String, String>
        let name = question[Constants.QuestionFields.name] as String!
        let text = question[Constants.QuestionFields.text] as String!
        cell!.textLabel?.text = name + ": " + text
    
//        let photoUrl = self.photoUrlArray[indexPath.row]
//        print(photoUrl)
        
//        if let photoUrl = question[Constants.QuestionFields.photoUrl] {
//            FIRStorage.storage().referenceForURL(photoUrl).dataWithMaxSize(INT64_MAX) { (data, error) in
//                if let error = error {
//                    print("Error downloading: \(error)")
//                    return
//                }
//                cell!.imageView?.image = UIImage.init(data: data!)
//            }
//        } else if let photoUrl = question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
//                cell!.imageView?.image = UIImage.init(data: data)
//        } else {
//            cell!.imageView?.image = UIImage(named: "ic_account_circle")
//        }


        return cell!
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
        var questionData = data
        questionData[Constants.QuestionFields.userUID] = FIRAuth.auth()?.currentUser?.uid
        questionData[Constants.QuestionFields.name] = AppState.sharedInstance.displayName
        self.ref.child("questions").childByAutoId().setValue(questionData)
    }
    
    
}














