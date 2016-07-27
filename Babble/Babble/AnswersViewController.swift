//
//  AnswersViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/21/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

class AnswersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

// MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    var answersArray: [FIRDataSnapshot]! = [] //empty array that can hold data snapshots of answers
    var questionRef: String?

    
// MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        self.configureDatabase()
    }
    
    deinit {
        self.ref.child("answers").child(questionRef!).removeObserverWithHandle(_refHandle)
    }

    
// MARK: - Firebase Database Configuration
    func configureDatabase() {
        self.ref = FIRDatabase.database().reference()
        _refHandle = self.ref.child("answers").child(questionRef!).observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            self.answersArray.append(snapshot)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.answersArray.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
    }
    
    
// MARK: - UITableViewDataSource & UITableViewDelegate methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.answersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath)
        //unpack question from database
        let answerSnapshot: FIRDataSnapshot! = self.answersArray[indexPath.row]
        let answer = answerSnapshot.value as! Dictionary<String, String>
        let name = answer[Constants.AnswerFields.name] as String!
        let text = answer[Constants.AnswerFields.text] as String!
        cell!.textLabel?.text = name + ": " + text
        cell!.imageView?.image = UIImage(named: "ic_account_circle")
        if let photoUrl = answer[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
            cell!.imageView?.image = UIImage(data: data)
        } 
        return cell!
    }
}
