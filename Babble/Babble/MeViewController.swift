

//
//  MeViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/29/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

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
    var isKeyboardOpen = false
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        registerForKeyboardNotifications()
        textView.delegate = self
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        let usersRef = FirebaseConfigManager.sharedInstance.ref.child("users")
        usersRef.child(userID).observeSingleEventOfType(.Value, withBlock: { [weak self] (userSnapshot) in
            guard let user = userSnapshot.value as? [String: AnyObject] else { return }
            if let userBio = user[Constants.UserFields.userBio] as? String {
                if userBio == "" {
                    self?.textView.text = "Write your bio here!"
                    self?.textView.textColor = UIColor.grayColor()
                } else {
                    self?.textView.text = userBio
                    self?.textView.textColor = UIColor.blackColor()
                }
            }
            })
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadFirebaseUserProfilePhoto()
        imageView.layer.cornerRadius = imageView.bounds.width/2
        imageView.clipsToBounds = true
    }
    
    deinit {
        unregisterForKeyboardNotifications()
    }
    //MARK:
    //MARK: - Load Firebase User Profile Photo
    //MARK:
    func loadFirebaseUserProfilePhoto() {
        if let photoDownloadURL = AppState.sharedInstance.photoDownloadURL {
            self.imageView.kf_setImageWithURL(NSURL(string: photoDownloadURL)!,
                                              placeholderImage: nil,
                                              optionsInfo: nil)
        } else {
            let image = UIImage(named: "Profile_avatar_placeholder_large")
            self.imageView.image = image
        }
    }
    
    @IBAction func didTapProfilePhotoImageView(sender: UITapGestureRecognizer) {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        //.PhotoLibrary
        let choosePhotoAction = UIAlertAction.init(title: "Choose Photo", style: UIAlertActionStyle.Default) { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .PhotoLibrary
            imagePickerController.delegate = self
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        //.Carmera
        let takePhotoAction = UIAlertAction.init(title: "Take Photo", style: UIAlertActionStyle.Default) { (action) in
            let imagePickerController = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                imagePickerController.sourceType = .Camera
                self.presentViewController(imagePickerController, animated: true, completion: nil)
                //print("Camera option not yet configured :(")
            } else {//TODO: localized error handling
                let noCameraAlert = UIAlertController.init(title: nil, message: "No camera attached to this device", preferredStyle: .Alert)
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
        //actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(cancelAction)
        presentViewController(actionSheet, animated: true, completion: nil);
    }
    
    @IBAction func didTapSignOut(sender: UIBarButtonItem) {
        print("sign out button tapped")
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth!.signOut()
            AppState.sharedInstance.signedIn = false
            dismissViewControllerAnimated(true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        } catch {
            print("Bundexy says: An unknown error was caught.")
        }
    }
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - NSNotification Methods
    //MARK: -
    
    var kbHeight: CGFloat!
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIKeyboardDidHideNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidChangeFrame(_:)), name: UIKeyboardDidChangeFrameNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didChangePreferredContentSize(_:)), name: UIContentSizeCategoryDidChangeNotification, object:nil)
    }
    
    func unregisterForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidChangeFrameNotification, object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object:nil)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
        
//        if self.isKeyboardOpen {
//            return
//        }
//        self.isKeyboardOpen = true
//        guard let keyBoardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size, rate = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else { return }
//        self.resizeTableViewWithKeyboardSize(keyBoardSize, rate: rate)
        
    }
    
    func keyboardDidHide(notification: NSNotification) {
        self.animateTextField(false)
        if self.textView.text == "" {
            self.textView.text = "Write your bio here!"
            self.textView.textColor = UIColor.grayColor()
        }
//        if (self.isKeyboardOpen == false) {
//            return
//        }
//        self.isKeyboardOpen = false
//        let rate = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
//        let heigth = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
//        let contentInsets = UIEdgeInsetsMake(heigth, UIEdgeInsetsZero.left, UIEdgeInsetsZero.bottom, UIEdgeInsetsZero.right)
//        UIView.animateWithDuration(rate!) { () -> Void in
//            self.tableView.contentInset = contentInsets
//            self.tableView.scrollIndicatorInsets = contentInsets
//        }
    }
    
    func animateTextField(up: Bool) {
        var movement = (up ? -kbHeight : kbHeight)
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }
    
    func keyboardDidChangeFrame(notification: NSNotification) {
//        if (self.isKeyboardOpen == true) {
//            guard let keyBoardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size, rate = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else { return }
//            self.resizeTableViewWithKeyboardSize(keyBoardSize, rate: rate)
//        }
    }
    
    func resizeTableViewWithKeyboardSize(keyBoardSize:CGSize, rate:Double) {
        let heigth = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
//        let frame = CGRect(x: tableView.bounds.origin.x, y: tableView.bounds.origin.y - keyBoardSize.height, width: tableView.bounds.width, height: tableView.bounds.height + keyBoardSize.height)
        let contentInsets = UIEdgeInsetsMake(heigth, 0.0, (keyBoardSize.height), 0.0)
        UIView.animateWithDuration(rate) { () -> Void in
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
//            self?.tableView.frame = frame
        }
    }
    
    func didChangePreferredContentSize(notification: NSNotification) {
        //self.sections = sharedInstance.itemsBySection(self.isLogin)
        self.tableView.reloadData()
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////






//MARK:
//MARK: - UIImagePickerControllerDelegate &  UINavigationControllerDelegate Protocol
//MARK:
extension MeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: -
    //MARK: - UIImagePickerControllerDelegate Methods
    //MARK: -
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.imageView.image = image
        let profileImageName = "profileImageName.jpg"
        let imageData = UIImageJPEGRepresentation(image, 0.3)!
        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))"
        
        let photoStorageRef = FirebaseConfigManager.sharedInstance.storageRef.child(filePath)
        let photoRef = photoStorageRef.child("\(profileImageName)")
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/png"
        
        photoRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading:\(error.localizedDescription)")
                return
            } else {
                guard let downloadURL = metadata!.downloadURL() else { return }
                guard let downloadURLString = metadata!.downloadURL()?.absoluteString else { return }
                self.imageView.kf_setImageWithURL(downloadURL, placeholderImage: nil, optionsInfo: nil)
                AppState.sharedInstance.photoDownloadURL = downloadURLString
                
                if let currentUserUID = FIRAuth.auth()?.currentUser?.uid {
                    FirebaseConfigManager.sharedInstance.ref.child("users/\(currentUserUID)/photoDownloadURL").setValue(downloadURLString)
                }
                
                let prefetchPhotoDownloadURL = [downloadURLString].map { NSURL(string: $0)! }
                let prefetcher = ImagePrefetcher(urls: prefetchPhotoDownloadURL, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (skippedResources, failedResources, completedResources) -> () in
                    print("These resources are prefetched: \(completedResources)")
                })
                prefetcher.start()
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
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
        let placeholderText = "Write your bio here!"
        if self.textView.text == placeholderText {
            self.textView.text = ""
        }
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












