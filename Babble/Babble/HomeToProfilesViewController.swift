//
//  HomeToProfilesViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 09/06/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

//MARK:
//MARK: - HomeToProfilesViewController Class
//MARK:
class HomeToProfilesViewController: UITableViewController {
    //MARK:
    //MARK: - Attributes
    //MARK:
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userProfileTextView: UITextView!
    var userIDRef: String?
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAndSetUserData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.bounds.width / 2
        self.userProfileImageView.clipsToBounds = true
    }
    
    func getAndSetUserData() {
        guard let userID = self.userIDRef else { return }
        FirebaseConfigManager.sharedInstance.ref.child("users").child(userID).observeEventType(.Value, withBlock: { userSnapshot in
            guard let user = userSnapshot.value as? [String: AnyObject] else { return }
            let userBio = user[Constants.UserFields.userBio] as? String
            if let photoDownloadURL = user[Constants.UserFields.photoDownloadURL] as! String? {
                self.userProfileImageView.kf_setImageWithURL(NSURL(string: photoDownloadURL), placeholderImage: nil, optionsInfo: nil)
            } else if let photoURL = user[Constants.UserFields.photoURL] as! String? {
                FIRStorage.storage().referenceForURL(photoURL).dataWithMaxSize(INT64_MAX) { (data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    self.userProfileImageView.image = UIImage(data: data!)
                }
            }
            self.userProfileTextView.text = userBio
        })
    
    }
}












