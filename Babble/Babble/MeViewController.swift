

//
//  MeViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/29/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase
//import SDWebImage

//MARK:
//MARK: - MeViewController Class
//MARK:
class MeViewController: UITableViewController {
    //MARK:
    //MARK: - Attributes
    //MARK:
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    var imageFromProfilePhotoVC: UIImage!
    var tapOutsideTextView = UITapGestureRecognizer()
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        textView.delegate = self
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        let usersRef = FirebaseConfigManager.sharedInstance.ref.child("users")
        usersRef.child(userID).observeSingleEventOfType(.Value, withBlock: { [weak self] (userSnapshot) in
            guard let user = userSnapshot.value as? [String: AnyObject] else { return }
            if let userBio = user[Constants.UserFields.userBio] as? String {
                self?.textView.text = userBio
            } else {
                self?.textView.text = "Write your bio here!"
            }
            })
        if imageFromProfilePhotoVC != nil {
            imageView.image = imageFromProfilePhotoVC
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadFirebaseUserProfilePhoto()
        imageView.layer.cornerRadius = imageView.bounds.width/2
        imageView.clipsToBounds = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.MyProfileToProfilePhoto {
            guard let destinationVC = segue.destinationViewController as? ProfilePhotoViewController else { return }
            destinationVC.imageFromMeVC = imageView.image
        }
    }
    //MARK:
    //MARK: - Load Firebase User Profile Photo
    //MARK:
    func loadFirebaseUserProfilePhoto() {
        if let profileImage = AppState.sharedInstance.profileImage {
            self.imageView.image = profileImage
        } else {
            guard let photoDownloadURL = AppState.sharedInstance.photoDownloadURL else { return }
            imageView.kf_setImageWithURL(NSURL(string: photoDownloadURL)!,
                                         placeholderImage: nil,
                                         optionsInfo: nil)
        }
    }
    
    @IBAction func didTapProfilePhotoImageView(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier(Constants.Segues.MyProfileToProfilePhoto, sender: self)
    }
    //MARK:
    //MARK: - Unwind Segues
    //MARK:
    @IBAction func didTapBackProfilePhotoVC(sender: UIStoryboardSegue) {
        //unwind segue from ProfilePhotoVC to MeVC
        //Identifier: ProfilePhotoToMyProfile
    }
}
//MARK:
//MARK: - UITextViewDelegate Protocol
//MARK:
extension MeViewController: UITextViewDelegate {
    //MARK:
    //MARK: - UITextViewDelegate Methods
    //MARK:
    func textViewDidBeginEditing(textView: UITextView) {
        print("textViewDidBeginEditing")
        self.tableView.allowsSelection = false
        self.tapOutsideTextView = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutsideTextViewWhenEditing))
        self.view.addGestureRecognizer(tapOutsideTextView)
    }
    
    func didTapOutsideTextViewWhenEditing() {
        self.view.endEditing(true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("textViewDidEndEditing")
        self.tableView.allowsSelection = true
        self.view.removeGestureRecognizer(tapOutsideTextView)
        let userBioText = self.textView.text
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        FirebaseConfigManager.sharedInstance.ref.child("users/\(userID)/userBio").setValue(userBioText)
    }
}












