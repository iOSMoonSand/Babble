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
    @IBOutlet weak var scrollView: UIScrollView!
    var tapOutsideTextView = UITapGestureRecognizer()
    var tapImageView = UITapGestureRecognizer()
    var chosenProfileImage: UIImage?
    var userBio = ""
    var kbHeight: CGFloat!
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userBioTextView.delegate = self
        self.setDisplayNameLabel()
        self.setImageView()
        self.formatEditButton()
        self.formatBioTextView()
        self.setUserBio()
        self.createGestureRecognizers()
        self.registerForNotifications()
    }
    
    func setDisplayNameLabel() {
        self.displayNameLabel.text = AppState.sharedInstance.displayName
        self.displayNameLabel.font = UIFont.boldSystemFontOfSize(22.0)
    }
    
    func setImageView() {
        if let chosenProfileImage = self.chosenProfileImage {
            self.profilePhotoImageView.image = chosenProfileImage
            self.formatImageView()
        } else {
            if let photoDownloadURL = AppState.sharedInstance.photoDownloadURL {
                self.profilePhotoImageView.kf_setImageWithURL(NSURL(string: photoDownloadURL)!, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"), optionsInfo: nil)
                self.formatImageView()
            } else {
                let image = UIImage(named: "Profile_avatar_placeholder_large")
                self.profilePhotoImageView.image = image
                self.formatImageView()
            }
        }
    }
    
    func formatImageView() {
        self.profilePhotoImageView.layoutIfNeeded()
        self.profilePhotoImageView.layer.borderWidth = 1
        self.profilePhotoImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.size.width / 2
        self.profilePhotoImageView.layer.masksToBounds = false
        self.profilePhotoImageView.clipsToBounds = true
        self.profilePhotoImageView.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func formatEditButton() {
        self.editPhotoButton.setTitle("edit photo", forState: .Normal)
        self.editPhotoButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
    }
    
    func formatBioTextView() {
        self.userBioTextView.layer.borderWidth = 1
        self.userBioTextView.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.userBioTextView.clipsToBounds = true
        self.userBioTextView.layer.cornerRadius = 6
        self.userBioTextView.text = "Write your bio here!"
        self.userBioTextView.textColor = UIColor.lightGrayColor()
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
    
    func createGestureRecognizers() {
        self.tapOutsideTextView = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutsideTextViewWhenEditing))
        self.view.addGestureRecognizer(tapOutsideTextView)
        self.tapOutsideTextView.cancelsTouchesInView = false
        
        self.tapImageView = UITapGestureRecognizer(target: self, action: #selector(self.didTapProfilePhotoImageView))
        self.profilePhotoImageView.userInteractionEnabled = true
        self.profilePhotoImageView.addGestureRecognizer(tapImageView)
    }
    //MARK:
    //MARK: - Gesture Recognizer Target Methods
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
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func didTapOutsideTextViewWhenEditing() {
        self.userBioTextView.resignFirstResponder()
    }
    // MARK:
    // MARK: - Notification Registration Methods
    // MARK:
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object:nil)
    }
    //MARK:
    //MARK: - NSNotification Methods
    //MARK:
    func keyboardWasShown(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let kbSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size as? CGSize? else { return }
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, ((kbSize?.height)! + 8.0), 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= (kbSize?.height)!
        
        if (!CGRectContainsPoint(aRect, self.userBioTextView.frame.origin)) {
            self.scrollView.scrollRectToVisible(self.userBioTextView.frame, animated: true)
        } else {
            self.scrollView.scrollRectToVisible(self.userBioTextView.frame, animated: true)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object:nil)
    }
    //MARK:
    //MARK: - Button Actions
    //MARK:
    @IBAction func didTapEditProfilePictureButton(sender: UIButton) {
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
        if self.userBioTextView.text == "Write your bio here!" {
            self.userBioTextView.text = ""
            self.userBioTextView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("textViewDidEndEditing")
        if self.userBioTextView.text.isEmpty {
            self.userBioTextView.text = "Write your bio here!"
            self.userBioTextView.textColor = UIColor.lightGrayColor()
            return
        }
        self.save(textView.text)
    }
    
    func save(bioText: String) {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        FirebaseMgr.shared.saveNewBio(userID, bioText: bioText)
    }
}












