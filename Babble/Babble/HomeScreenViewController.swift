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

// MARK: - Instance Variables
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    var questionsArray: [FIRDataSnapshot]! = [] //empty array that can hold data snapshots of questions
    
    
// MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    

// MARK: - View Loading & Appearing
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        
        configureDatabase()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.ref.removeObserverWithHandle(_refHandle)
    }

// MARK: - Firebase Database Configuration
    func configureDatabase() {
        
        ref = FIRDatabase.database().reference()
        
        //listen for new questions in the database
        _refHandle = self.ref.child("questions").observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
            
            self.questionsArray.append(snapshot)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.questionsArray.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
    }
    
    deinit {
        
        self.ref.child("questions").removeObserverWithHandle(_refHandle)
    }
    
    
// MARK: - UITableViewDataSource & UITableViewDelegate methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return questionsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath)
        
        //unpack question from database
        let questionSnapshot: FIRDataSnapshot! = self.questionsArray[indexPath.row]
        let question = questionSnapshot.value as! Dictionary<String, String>
        let name = question[Constants.QuestionFields.name] as String!
        let text = question[Constants.QuestionFields.text] as String!
        
        cell!.textLabel?.text = name + ": " + text
        cell!.imageView?.image = UIImage(named: "ic_account_circle")
        if let photoUrl = question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
        cell!.imageView?.image = UIImage(data: data)
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let questionSnapshot: FIRDataSnapshot! = self.questionsArray[indexPath.row]
        let selectedQuestion = questionSnapshot.key
        
        let destinationVC = AnswersViewController()
        let answerVCQuestionRef = destinationVC.questionRef
        if var tempAnswerVCQuestionRef = answerVCQuestionRef {
            tempAnswerVCQuestionRef = selectedQuestion
            print("User tapped on: \(answerVCQuestionRef)")
        }
        
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
    

}
