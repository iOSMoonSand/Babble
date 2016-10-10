//
//  UserProfileViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 10/09/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Kingfisher

class UserProfileViewController: UITableViewController {

    //MARK:
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userProfileTextView: UITextView!
    var selectedUserID: String?
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.retrieveUserProfileData()
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func retrieveUserProfileData() {
        guard let userID = self.selectedUserID else { return }
        
        FirebaseMgr.shared.retrieveUserBio(userID, completion: { userBio in
            self.userProfileTextView.text = userBio
        })
        
        FirebaseMgr.shared.retrieveUserPhotoDownloadURL(userID, completion: { photoDownloadURL, defaultImage in
            if photoDownloadURL != nil {
                let url = NSURL(string: photoDownloadURL!)
                self.userProfileImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
                self.formatImage()
            } else {
                self.userProfileImageView.image =  UIImage(named: "Profile_avatar_placeholder_large")
                self.formatImage()
            }
        })
    }
    
    func formatImage() {
        self.userProfileImageView.layer.borderWidth = 1
        self.userProfileImageView.layer.masksToBounds = false
        self.userProfileImageView.layer.borderColor = UIColor.blackColor().CGColor
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.bounds.width / 2
        self.userProfileImageView.clipsToBounds = true
    }
}







