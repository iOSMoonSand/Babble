//
//  UserProfileViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 10/09/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

//MARK:
//MARK: - UserProfileViewController Class
//MARK:
class UserProfileViewController: UIViewController {
    //MARK:
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var displayNameLabel: UILabel!
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
    
    func retrieveUserProfileData() {
        guard let userID = self.selectedUserID else { return }
        
        FirebaseMgr.shared.retrieveUserDisplayName(userID, completion: { displayName in
            self.displayNameLabel.text = displayName
        })
        
        FirebaseMgr.shared.retrieveUserBio(userID, completion: { userBio in
            if userBio == nil {
                self.userProfileTextView.text = "Apparently, this user prefers to keep an air of mystery about them."
                self.userProfileTextView.textColor = UIColor.lightGray
            } else {
                self.userProfileTextView.text = userBio
            }
        })
        
        FirebaseMgr.shared.retrieveUserPhotoDownloadURL(userID, completion: { photoDownloadURL, defaultImage in
            if photoDownloadURL != nil {
                let url = URL(string: photoDownloadURL!)
                self.userProfileImageView.kf.setImage(with: url, placeholder: UIImage(named: "Profile_avatar_placeholder_large"), options: nil, progressBlock: nil, completionHandler: nil)
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
        self.userProfileImageView.layer.borderColor = UIColor.black.cgColor
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.bounds.width / 2
        self.userProfileImageView.clipsToBounds = true
    }
    
    
    @IBAction func blockButtonTouchUpInside(_ sender: UIButton) {
        guard let userID = self.selectedUserID else { return }
        guard let currentUserID = AppState.sharedInstance.currentUserID else { return }
        let blockAlert = UIAlertController.init(title: "Block User", message: "Are you sure you want to block this user?", preferredStyle: .alert)
        let yesAction = UIAlertAction.init(title: "Yes, I'm sure", style: .default) { (action) in
            FIRAnalytics.logEvent(withName: "user_blocked", parameters: [
                kFIRParameterItemID: userID as NSObject,
                "offendedUser": currentUserID as NSObject
                ])
            let alert2 = UIAlertController(title: "Thanks", message: "This user won't bother you any more.", preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                return
            }))
            self.present(alert2, animated: true, completion: nil)
        }
        let noAction = UIAlertAction.init(title: "No", style: .default) { (action) in
            return
        }
        blockAlert.addAction(yesAction)
        blockAlert.addAction(noAction)
        self.present(blockAlert, animated: true, completion: nil)
    }
    
    
    
}







