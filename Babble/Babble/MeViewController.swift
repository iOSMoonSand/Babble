//
//
////
////  MeViewController.swift
////  Babble
////
////  Created by Alexis Schreier on 07/29/16.
////  Copyright © 2016 Alexis Schreier. All rights reserved.
////
//
//import UIKit
//import Firebase
//import Kingfisher
//
////MARK:
////MARK: - MeViewController Class
////MARK:
//class MeViewController: UIViewController {
//    //MARK:
//    //MARK: - Attributes
//    //MARK:
//    @IBOutlet weak var tableView: UITableView!
//    var imageFromProfilePhotoVC: UIImage!
//    var tapOutsideTextView = UITapGestureRecognizer()
//    var chosenProfileImage: UIImage?
//    var userBio = ""
//    var isKeyboardOpen = false
//    var kbHeight: CGFloat!
//    //MARK:
//    //MARK: - UIViewController Methods
//    //MARK:
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        registerForKeyboardNotifications()
//        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
//        FirebaseConfigManager.sharedInstance.ref.child("users").child(userID).observeSingleEventOfType(.Value, withBlock: { (userSnapshot) in
//            guard let user = userSnapshot.value as? [String: AnyObject] else { return }
//            if let userBioTemp = user[Constants.UserFields.userBio] as? String {
//                if !userBioTemp.isEmpty {
//                    self.userBio = userBioTemp
//                }
//            }
//            self.tableView.reloadData()
//        })
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 300.0
//        self.tapOutsideTextView = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutsideTextViewWhenEditing))
//        self.view.addGestureRecognizer(tapOutsideTextView)
//        self.tapOutsideTextView.cancelsTouchesInView = false
//        self.view.backgroundColor = UIColor.whiteColor()
//    }
//    
//    func didTapOutsideTextViewWhenEditing() {
//        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
//        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? MeVCTextViewCell else { return }
//        cell.bioTextView.resignFirstResponder()
//    }
//    
//    deinit {
//        unregisterForKeyboardNotifications()
//    }
//    
//    @IBAction func didTapSignOut(sender: UIBarButtonItem) {
//        let firebaseAuth = FIRAuth.auth()
//        do {
//            try firebaseAuth!.signOut()
//            AppState.sharedInstance.signedIn = false
//            dismissViewControllerAnimated(true, completion: nil)
//        } catch let signOutError as NSError {
//            print ("Error signing out: \(signOutError)")
//        } catch {
//            print("Bundexy says: An unknown error was caught.")
//        }
//    }
//    //MARK: -
//    //MARK: - NSNotification Methods
//    //MARK: -
//    func registerForKeyboardNotifications() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object:nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIKeyboardDidHideNotification, object:nil)
//    }
//    
//    func unregisterForKeyboardNotifications() {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object:nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object:nil)
//    }
//    
//    func keyboardDidShow(notification: NSNotification) {
//        if self.isKeyboardOpen {
//            return
//        }
//        self.isKeyboardOpen = true
//        if let userInfo = notification.userInfo {
//            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
//                kbHeight = keyboardSize.height
//                self.animateTextField(true)
//            }
//        }
//    }
//    
//    func keyboardDidHide(notification: NSNotification) {
//        if self.isKeyboardOpen == false {
//            return
//        }
//        self.isKeyboardOpen = false
//        self.animateTextField(false)
//    }
//    
//    func animateTextField(up: Bool) {
//        let movement = (up ? -kbHeight : kbHeight)
//        UIView.animateWithDuration(0.1, animations: {
//            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
//        })
//    }
//}
////MARK:
////MARK: - UIImagePickerControllerDelegate &  UINavigationControllerDelegate Protocol
////MARK:
//extension MeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    //MARK: -
//    //MARK: - UIImagePickerControllerDelegate Methods
//    //MARK: -
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
//        self.chosenProfileImage = image
//        tableView.reloadData()
//        let profileImageName = "profileImageName.jpg"
//        let imageData = UIImageJPEGRepresentation(image, 0.3)!
//        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))"
//        
//        let photoStorageRef = FirebaseConfigManager.sharedInstance.storageRef.child(filePath)
//        let photoRef = photoStorageRef.child("\(profileImageName)")
//        
//        let metadata = FIRStorageMetadata()
//        metadata.contentType = "image/png"
//        
//        photoRef.putData(imageData, metadata: metadata) { metadata, error in
//            if let error = error {
//                print("Error uploading:\(error.localizedDescription)")
//                return
//            } else {
//                //guard let downloadURL = metadata!.downloadURL() else { return }
//                guard let downloadURLString = metadata!.downloadURL()?.absoluteString else { return }
//                //self.imageView.kf_setImageWithURL(downloadURL, placeholderImage: nil, optionsInfo: nil)
//                AppState.sharedInstance.photoDownloadURL = downloadURLString
//                
//                if let currentUserUID = FIRAuth.auth()?.currentUser?.uid {
//                    FirebaseConfigManager.sharedInstance.ref.child("users/\(currentUserUID)/photoDownloadURL").setValue(downloadURLString)
//                }
//                
//                let prefetchPhotoDownloadURL = [downloadURLString].map { NSURL(string: $0)! }
//                let prefetcher = ImagePrefetcher(urls: prefetchPhotoDownloadURL, optionsInfo: nil, progressBlock: nil, completionHandler: {
//                    (skippedResources, failedResources, completedResources) -> () in
//                    print("These resources are prefetched: \(completedResources)")
//                })
//                prefetcher.start()
//            }
//        }
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//}
////MARK: -
////MARK: - UITableViewDelegate & UITableViewDataSource Protocols
////MARK: -
//extension MeViewController: UITableViewDelegate, UITableViewDataSource {
//    //MARK: -
//    //MARK: - UITableViewDelegate & UITableViewDataSource Methods
//    //MARK: -
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 2
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            guard let cell = tableView.dequeueReusableCellWithIdentifier("MeVCImageCell", forIndexPath: indexPath) as? MeVCImageCell else { return UITableViewCell()}
//            cell.delegate = self
//            cell.selectionStyle = .None
//            if let chosenProfileImage = chosenProfileImage {
//                cell.display(chosenProfileImage)
//            } else {
//                cell.downloadImage()
//            }
//            return cell
//        } else if indexPath.row == 1 {
//            guard let cell = tableView.dequeueReusableCellWithIdentifier("MeVCTextViewCell", forIndexPath: indexPath) as? MeVCTextViewCell else { return UITableViewCell()}
//            cell.delegate = self
//            cell.selectionStyle = .None
//            if userBio.isEmpty {
//                cell.bioTextView.text = "Write your bio here!"
//                cell.bioTextView.textColor = UIColor.grayColor()
//            } else {
//                cell.bioTextView.text = userBio
//                cell.bioTextView.textColor = UIColor.blackColor()
//            }
//            return cell
//        }
//        return UITableViewCell()
//    }
//}
////MARK: -
////MARK: - MeVCImageCellDelegate Protocol
////MARK: -
//extension MeViewController: MeVCImageCellDelegate {
//    //MARK: -
//    //MARK: - MeVCImageCellDelegate Methods
//    //MARK: -
//    func didTapProfilePhotoImageView() {
//        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//        //.PhotoLibrary
//        let choosePhotoAction = UIAlertAction.init(title: "Choose Photo", style: UIAlertActionStyle.Default) { (action) in
//            let imagePickerController = UIImagePickerController()
//            imagePickerController.sourceType = .PhotoLibrary
//            imagePickerController.delegate = self
//            self.presentViewController(imagePickerController, animated: true, completion: nil)
//        }
//        //.Carmera
//        let takePhotoAction = UIAlertAction.init(title: "Take Photo", style: UIAlertActionStyle.Default) { (action) in
//            let imagePickerController = UIImagePickerController()
//            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
//                imagePickerController.sourceType = .Camera
//                self.presentViewController(imagePickerController, animated: true, completion: nil)
//                //print("Camera option not yet configured :(")
//            } else {//TODO: localized error handling
//                let noCameraAlert = UIAlertController.init(title: nil, message: "No camera attached to this device", preferredStyle: .Alert)
//                let okAction = UIAlertAction.init(title: "OK", style: .Default) { (action) in
//                    return
//                }
//                noCameraAlert.addAction(okAction)
//                self.presentViewController(noCameraAlert, animated: true, completion: nil)
//            }
//        }
//        //.Cancel
//        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) in
//        }
//        actionSheet.addAction(choosePhotoAction)
//        //actionSheet.addAction(takePhotoAction)
//        actionSheet.addAction(cancelAction)
//        presentViewController(actionSheet, animated: true, completion: nil);
//    }
//}
////MARK: -
////MARK: - MeVCTextViewCellDelegate Protocol
////MARK: -
//extension MeViewController: MeVCTextViewCellDelegate {
//    //MARK: -
//    //MARK: - MeVCTextViewCellDelegate Methods
//    //MARK: -
//    func save(bioText: String) {
//        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
//        FirebaseConfigManager.sharedInstance.ref.child("users/\(userID)/userBio").setValue(bioText)
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
