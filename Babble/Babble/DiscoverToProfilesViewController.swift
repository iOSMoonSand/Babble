////
////  DiscoverToProfilesViewController.swift
////  Babble
////
////  Created by Alexis Schreier on 09/27/16.
////  Copyright © 2016 Alexis Schreier. All rights reserved.
////
//
//import UIKit
//import Firebase
//
////MARK:
////MARK: - DiscoverToProfilesViewController Class
////MARK:
//class DiscoverToProfilesViewController: UITableViewController {
//    //MARK:
//    //MARK: - Attributes
//    //MARK:
//    @IBOutlet weak var userProfileImageView: UIImageView!
//    @IBOutlet weak var userProfileTextView: UITextView!
//    var userIDRef: String?
//    //MARK:
//    //MARK: - UIViewController Methods
//    //MARK:
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.getAndSetUserData()
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        self.userProfileImageView.layer.borderWidth = 1
//        self.userProfileImageView.layer.masksToBounds = false
//        self.userProfileImageView.layer.borderColor = UIColor.blackColor().CGColor
//        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.bounds.width / 2
//        self.userProfileImageView.clipsToBounds = true
//    }
//    
//    func getAndSetUserData() {
//        guard let userID = self.userIDRef else { return }
//        self.ref.child("users").child(userID).observeEventType(.Value, withBlock: { userSnapshot in
//            guard let user = userSnapshot.value as? [String: AnyObject] else { return }
//            let userBio = user[Constants.UserFields.userBio] as? String
//            if let photoDownloadURL = user[Constants.UserFields.photoDownloadURL] as! String? {
//                self.userProfileImageView.kf_setImageWithURL(NSURL(string: photoDownloadURL), placeholderImage: nil, optionsInfo: nil)
//            } else if let photoURL = user[Constants.UserFields.photoURL] as! String? {
//                FIRStorage.storage().referenceForURL(photoURL).dataWithMaxSize(INT64_MAX) { (data, error) in
//                    if let error = error {
//                        print("Error downloading: \(error)")
//                        return
//                    }
//                    self.userProfileImageView.image = UIImage(data: data!)
//                }
//            }
//            self.userProfileTextView.text = userBio
//        })
//        
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
