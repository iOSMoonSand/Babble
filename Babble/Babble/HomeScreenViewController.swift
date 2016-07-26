//
//  HomeScreenViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/02/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
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
    
    override func viewDidLoad() {
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        return cell
    }
}
