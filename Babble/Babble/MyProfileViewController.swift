//
//  MyProfileViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 10/12/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

//MARK:
//MARK: - MyProfileViewController Class
//MARK:
class MyProfileViewController: UIViewController {
    //MARK:
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var userBioTextView: UITextView!
    var tapOutsideTextView = UITapGestureRecognizer()
    var tapImageView = UITapGestureRecognizer()
    var chosenProfileImage: UIImage?
    var userBio = ""
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDisplayNameLabel()
        self.setImageView()
        self.formatImageView()
        self.formatEditButton()
        self.setUserBio()
        self.createGestureRecognizers()
    }
    
    func setDisplayNameLabel() {
        self.displayNameLabel.text = AppState.sharedInstance.displayName
        self.displayNameLabel.font = UIFont.boldSystemFontOfSize(22.0)
    }
    
    func createGestureRecognizers() {
        self.tapOutsideTextView = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutsideTextViewWhenEditing))
        self.view.addGestureRecognizer(tapOutsideTextView)
        self.tapOutsideTextView.cancelsTouchesInView = false
        
        self.tapImageView = UITapGestureRecognizer(target: self, action: #selector(self.didTapProfilePhotoImageView))
        self.profilePhotoImageView.userInteractionEnabled = true
        self.profilePhotoImageView.addGestureRecognizer(tapImageView)
    }
    
    func setImageView() {
        if let chosenProfileImage = self.chosenProfileImage {
            self.profilePhotoImageView.image = chosenProfileImage
        } else {
            if let photoDownloadURL = AppState.sharedInstance.photoDownloadURL {
                self.profilePhotoImageView.kf_setImageWithURL(NSURL(string: photoDownloadURL)!, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"), optionsInfo: nil)
            } else {
                let image = UIImage(named: "Profile_avatar_placeholder_large")
                self.profilePhotoImageView.image = image
            }
        }
    }
    
    func setUserBio() {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        FirebaseMgr.shared.retrieveUserBio(userID, completion: { userBio in
            if userBio != nil {
                self.userBioTextView.text = userBio
                self.userBioTextView.textColor = UIColor.blackColor()
            } else {
                self.userBioTextView.text = "Write your bio here!"
                self.userBioTextView.textColor = UIColor.grayColor()
            }
        })
    }
    
    func formatImageView() {
        self.profilePhotoImageView.layoutIfNeeded()
        self.profilePhotoImageView.layer.borderWidth = 1
        self.profilePhotoImageView.layer.masksToBounds = false
        self.profilePhotoImageView.layer.borderColor = UIColor.blackColor().CGColor
        self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.bounds.width/2
        self.profilePhotoImageView.clipsToBounds = true
    }
    
    func formatEditButton() {
        self.editPhotoButton.setTitle("edit photo", forState: .Normal)
        self.editPhotoButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
    }
    //MARK:
    //MARK: - Gesture Recognizer Selector Methods
    //MARK:
    func didTapProfilePhotoImageView() {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        //.PhotoLibrary
        let choosePhotoAction = UIAlertAction.init(title: "Choose Photo", style: UIAlertActionStyle.Default) { (action) in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .PhotoLibrary
            
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        //.Carmera
        let takePhotoAction = UIAlertAction.init(title: "Take Photo", style: UIAlertActionStyle.Default) { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                imagePickerController.sourceType = .Camera
                self.presentViewController(imagePickerController, animated: true, completion: nil)
                //print("Camera option not yet configured :(")
            } else {
                let noCameraAlert = UIAlertController.init(title: nil, message: "No camera attached to this device.", preferredStyle: .Alert)
                let okAction = UIAlertAction.init(title: "OK", style: .Default) { (action) in
                    return
                }
                noCameraAlert.addAction(okAction)
                self.presentViewController(noCameraAlert, animated: true, completion: nil)
            }
        }
        //.Cancel
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) in
        }
        actionSheet.addAction(choosePhotoAction)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(cancelAction)
        presentViewController(actionSheet, animated: true, completion: nil);
    }
    
    func didTapOutsideTextViewWhenEditing() {
        self.userBioTextView.resignFirstResponder()
    }
    
    //MARK:
    //MARK: - Button Actions
    //MARK:
    @IBAction func didTapEditPhoto(sender: UIButton) {
        didTapProfilePhotoImageView()
    }
    
    @IBAction func didTapSignOut(sender: UIBarButtonItem) {
        let signOutAlert = UIAlertController.init(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .Alert)
        let yesAction = UIAlertAction.init(title: "I'm sure.", style: .Default) { (action) in
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                self.dismissViewControllerAnimated(true, completion: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: \(signOutError)")
            }
            return
        }
        let noAction = UIAlertAction.init(title: "I want to stay!", style: .Default) { (action) in
            return
        }
        signOutAlert.addAction(yesAction)
        signOutAlert.addAction(noAction)
        self.presentViewController(signOutAlert, animated: true, completion: nil)
    }
}
//MARK:
//MARK: - UIImagePickerControllerDelegate &  UINavigationControllerDelegate Protocol
//MARK:
extension MyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: -
    //MARK: - UIImagePickerControllerDelegate Methods
    //MARK: -
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.chosenProfileImage = image
        setImageView()
        let imageData = UIImageJPEGRepresentation(image, 0.3)!
        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))"
        let photoStorageRef = FirebaseMgr.shared.storageRef.child(filePath)
        let photoRef = photoStorageRef.child("\(Constants.ImageData.ImageName)")
        let metadata = FIRStorageMetadata()
        metadata.contentType = Constants.ImageData.ContentTypeJPEG
        FirebaseMgr.shared.uploadSelectedImageData(photoRef, imageData: imageData, metaData: metadata)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
//MARK:
//MARK: - UITextViewDelegate Protocol
//MARK:
extension MyProfileViewController: UITextViewDelegate {
    //MARK:
    //MARK: - UITextViewDelegate Methods
    //MARK:
    func textViewDidBeginEditing(textView: UITextView) {
        print("textViewDidBeginEditing")
        let placeholderText = "Write your bio here!"
        if self.userBioTextView.text == placeholderText {
            self.userBioTextView.text = ""
            self.userBioTextView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("textViewDidEndEditing")
        self.save(textView.text)
    }
    
    func save(bioText: String) {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        FirebaseMgr.shared.saveNewBio(userID, bioText: bioText)
    }
}












