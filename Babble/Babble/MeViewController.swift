

//
//  MeViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/29/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage


//MARK:
//MARK: - MeViewControllerClass
//MARK:
class MeViewController: UITableViewController, UITextViewDelegate {
    //MARK:
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    var imageFromProfilePhotoVC: UIImage!
    var storageRef: FIRStorageReference!
    var ref: FIRDatabaseReference!
    var tapOutsideTextView = UITapGestureRecognizer()
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        textView.delegate = self
        
        ref = FIRDatabase.database().reference()
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        let usersRef = self.ref.child("users")
        usersRef.child(userID).observeSingleEventOfType(.Value, withBlock: { [weak self] (userSnapshot) in
            guard let user = userSnapshot.value as? [String: AnyObject] else { return }
            if let userBio = user[Constants.UserFields.userBio] as? String {
                self?.textView.text = userBio
            } else {
                self?.textView.text = "Write your bio here!"
            }
            
            })
        
        navigationItem.hidesBackButton = true
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
            
            let url = NSURL(string: AppState.sharedInstance.photoUrlString)
            print("Photo URL: \(url?.absoluteString)")
            self.imageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"))
        }
        //        self.ref = FIRDatabase.database().reference()
        //        let usersRef = self.ref.child("users")
        //        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        //        usersRef.child(userID).observeSingleEventOfType(.Value, withBlock: { (userSnapshot) in
        //            var user = userSnapshot.value as! [String: AnyObject]
        //            if let photoURL = user[Constants.UserFields.photoUrl] as! String? {
        //                FIRStorage.storage().referenceForURL(photoURL).dataWithMaxSize(INT64_MAX) { (data, error) in
        //                    if let error = error {
        //                        print("Error downloading: \(error)")
        //                        return
        //                    }
        //                    self.imageView.image = UIImage(data: data!)
        //                }
        //            } else if let photoURL = user[Constants.UserFields.photoUrl] as! String?, url = NSURL(string:photoURL), data = NSData(contentsOfURL: url) {
        //                self.imageView.image = UIImage(data: data)
        //            } else {
        //                self.imageView.image = UIImage(named: "ic_account_circle")
        //            }
        //        })
    }
    
    
    @IBAction func didTapProfilePhotoImageView(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier(Constants.Segues.MyProfileToProfilePhoto, sender: self)
    }
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
        self.ref.child("users/\(userID)/userBio").setValue(userBioText)
    }
    
}













