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
    var storageRef: FIRStorageReference!
    var questionsArray: [FIRDataSnapshot]! = []
    var profilePhotoString: String?
    var newQuestion: String?
    //MARK: -
    //MARK: - UIViewController Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        configureDatabase()
        configureStorage()
    }
    
    deinit {
        self.ref.child("questions").removeObserverWithHandle(_refHandle)
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
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.questionsArray.count-1, inSection: 0)], withRowAnimation: .Automatic)
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
        //assign data to cell
        cell!.textLabel?.text = name + ": " + text
        
//        if let photoUrl = AppState.sharedInstance.photoUrl {
//            question[Constants.QuestionFields.photoUrl] = photoUrl.absoluteString
//        } else {
//            let placeholderPhotoRef = storageRef.child("Profile_avatar_placeholder_large.png")
//            let placeholderPhotoRefString = "gs://babble-8b668.appspot.com/" + placeholderPhotoRef.fullPath
//            question[Constants.QuestionFields.photoUrl] = placeholderPhotoRefString
            //
            //download photo: home page just downloads whatever photo it's fed from the USER
            if let photoUrl = question[Constants.QuestionFields.photoUrl] {
                FIRStorage.storage().referenceForURL(photoUrl).dataWithMaxSize(INT64_MAX) { (data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    cell.imageView?.image = UIImage.init(data: data!)
                }
            } else if profilePhotoString == nil {
                cell!.imageView?.image = UIImage(named: "ic_account_circle")
        } else if let url = NSURL(string:profilePhotoString!), data = NSData(contentsOfURL: url) {
                cell.imageView?.image = UIImage.init(data: data)
        }
//        }
        return cell!
    }
    
    
    //
    //        if let url = question[Constants.QuestionFields.photoUrl] as String! {
    //            FIRStorage.storage().referenceForURL(url).dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
    //                if (error != nil) {
    //                    cell!.imageView?.image = UIImage(named: "ic_account_circle")
    //                    // Uh-oh, an error occurred!
    //                } else {
    //                    cell!.imageView?.image = UIImage(data: data!)
    //                    // Data for "images/island.jpg" is returned
    //                    // ... let islandImage: UIImage! = UIImage(data: data!)
    //                }
    //            }
    //        }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Constants.Segues.HomeToAnswersNavController, sender: self)
    }
    
    
    // MARK: - IBActions
    
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
        questionData[Constants.QuestionFields.name] = AppState.sharedInstance.displayName
        if let photoUrl = AppState.sharedInstance.photoUrl {
            questionData[Constants.QuestionFields.photoUrl] = photoUrl.absoluteString
        } else {
            let placeholderPhotoRef = storageRef.child("Profile_avatar_placeholder_large.png")
            let placeholderPhotoRefString = "gs://babble-8b668.appspot.com/" + placeholderPhotoRef.fullPath
            questionData[Constants.QuestionFields.photoUrl] = placeholderPhotoRefString
            profilePhotoString = placeholderPhotoRefString

        }
        self.ref.child("questions").childByAutoId().setValue(questionData)
    }
    
    
}














