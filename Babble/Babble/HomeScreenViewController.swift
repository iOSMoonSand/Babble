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
    var messages: [FIRDataSnapshot]! = [] //empty array that can hold data snapshots
    
    
// MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    

// MARK: - View Loading & Appearing
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.messages.removeAll()
        _refHandle = self.ref.child("messages").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            
            self.messages.append(snapshot)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.ref.removeObserverWithHandle(_refHandle)
    }

// MARK: - Firebase Database Configuration
    func configureDatabase() {
        
        ref = FIRDatabase.database().reference()
        
        //listen for new messages in the database
        _refHandle = self.ref.child("messages").observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
            
            self.messages.append(snapshot)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
    }
    
    deinit {
        
        self.ref.child("messages").removeObserverWithHandle(_refHandle)
    }
    
    
// MARK: - UITableViewDataSource & UITableViewDelegate methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath)
        
        //unpack message from database
        let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, String>
        let name = message[Constants.MessageFields.name] as String!
        let text = message[Constants.MessageFields.text] as String!
        
        cell!.textLabel?.text = name + ": " + text
        cell!.imageView?.image = UIImage(named: "ic_account_circle")
        if let photoUrl = message[Constants.MessageFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
        cell!.imageView?.image = UIImage(data: data)
        }
        
        return cell!
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
