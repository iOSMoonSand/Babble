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
    var questionsArray: [FIRDataSnapshot]! = [] //empty array that can hold data snapshots of questions
    var newQuestion: String?
//MARK: -
//MARK: - UIViewController Methods
//MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        configureDatabase()
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

    
// MARK: - Firebase Database Configuration
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        _refHandle = self.ref.child("questions").observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
            self.questionsArray.append(snapshot)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.questionsArray.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
    }
    
    
// MARK: - UITableViewDataSource & UITableViewDelegate methods
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
        cell!.imageView?.image = UIImage(named: "ic_account_circle")
        if let photoUrl = question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
            cell!.imageView?.image = UIImage(data: data)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Constants.Segues.HomeToAnswersNavController, sender: self)
    }
    
    
// MARK: - IBActions
    
    @IBAction func didTapSignOut(sender: AnyObject) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            //            AppState.sharedInstance.signedIn = false
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
        }
        self.ref.child("questions").childByAutoId().setValue(questionData)
    }
    

}














