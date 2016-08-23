//
//  UserProfilesViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 08/22/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

//MARK:
//MARK: - UserProfilesViewController Class
//MARK:
class UserProfilesViewController: UITableViewController {
    //MARK:
    //MARK: - Attributes
    //MARK:
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userProfileTextView: UITextView!
    var userIDRef: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAndSetUserData()
    }
    
    func getAndSetUserData() {
        guard let userID = self.userIDRef else { return }
        FirebaseConfigManager.sharedInstance.ref.child("users").child(userID).observeEventType(.Value, withBlock: { userSnapshot in
            guard let user = userSnapshot.value as? [String: AnyObject] else { return }
            let userBio = user[Constants.UserFields.userBio] as! String
            let photoURL = user[Constants.UserFields.photoUrl] as! String
            
            self.userProfileTextView.text = userBio
            
            FIRStorage.storage().referenceForURL(photoURL).dataWithMaxSize(INT64_MAX) { (data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                self.userProfileImageView.image = UIImage(data: data!)
            }
        })
    }
    
}
