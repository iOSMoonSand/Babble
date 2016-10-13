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
//    //MARK:
//    //MARK: - UIViewController Methods
//    //MARK:
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        self.defineTableViewRowHeight()
//        self.createGestureRecognizers()
//        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
//        self.tableView.reloadData()
//    }
//    //MARK:
//    //MARK: - viewDidLoad Override Methods
//    //MARK:
//    func defineTableViewRowHeight() {
//        tableView.rowHeight = UITableViewAutomaticDimension
////        tableView.estimatedRowHeight = 300.0
//    }
//    
//    func createGestureRecognizers() {
//        self.tapOutsideTextView = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutsideTextViewWhenEditing))
//        self.view.addGestureRecognizer(tapOutsideTextView)
//        self.tapOutsideTextView.cancelsTouchesInView = false
//    }
//    
//    func didTapOutsideTextViewWhenEditing() {
//        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
//        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? MeVCTextViewCell else { return }
//        cell.bioTextView.resignFirstResponder()
//    }
//    //MARK:
//    //MARK: - Button Actions
//    //MARK:
//    @IBAction func didTapSignOut(sender: UIBarButtonItem) {
//        let signOutAlert = UIAlertController.init(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .Alert)
//        let yesAction = UIAlertAction.init(title: "I'm sure.", style: .Default) { (action) in
//            let firebaseAuth = FIRAuth.auth()
//            do {
//                try firebaseAuth?.signOut()
//                self.dismissViewControllerAnimated(true, completion: nil)
//            } catch let signOutError as NSError {
//                print ("Error signing out: \(signOutError)")
//            }
//            return
//        }
//        let noAction = UIAlertAction.init(title: "I want to stay!", style: .Default) { (action) in
//            return
//        }
//        signOutAlert.addAction(yesAction)
//        signOutAlert.addAction(noAction)
//        self.presentViewController(signOutAlert, animated: true, completion: nil)
//    }
//}
////MARK: -
////MARK: - UITableViewDelegate & UITableViewDataSource Protocols
////MARK: -
//extension MeViewController: UITableViewDelegate, UITableViewDataSource {
//    //MARK: -
//    //MARK: - UITableViewDelegate & UITableViewDataSource Methods
//    //MARK: -
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        
//        var height: CGFloat?
//        
//        if indexPath.row == 0 {
//            height = 296.0
//        }
//        
//        if indexPath.row == 1 {
//            height = 230.0
//        }
//        
//        return height!
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 2
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            guard let cell = tableView.dequeueReusableCellWithIdentifier("MeVCImageCell", forIndexPath: indexPath) as? MeVCImageCell else { return UITableViewCell() }
//            cell.delegate = self
//            cell.selectionStyle = .None
//            if let chosenProfileImage = self.chosenProfileImage {
//                cell.profileImageView.image = chosenProfileImage
//            } else {
//                if let photoDownloadURL = AppState.sharedInstance.photoDownloadURL {
//                    cell.profileImageView.kf_setImageWithURL(NSURL(string: photoDownloadURL)!,
//                                                             placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"),
//                                                             optionsInfo: nil)
//                } else {
//                    let image = UIImage(named: "Profile_avatar_placeholder_large")
//                    cell.profileImageView.image = image
//                }
//            }
//            return cell
//        } else if indexPath.row == 1 {
//            guard let cell = tableView.dequeueReusableCellWithIdentifier("MeVCTextViewCell", forIndexPath: indexPath) as? MeVCTextViewCell else { return UITableViewCell() }
//            cell.delegate = self
//            cell.selectionStyle = .None
//            guard let userID = FIRAuth.auth()?.currentUser?.uid else { return UITableViewCell() }
//            FirebaseMgr.shared.retrieveUserBio(userID, completion: { userBio in
//                if userBio != nil {
//                    cell.bioTextView.text = userBio
//                    cell.bioTextView.textColor = UIColor.blackColor()
//                } else {
//                    cell.bioTextView.text = "Write your bio here!"
//                    cell.bioTextView.textColor = UIColor.grayColor()
//                }
//            })
//            return cell
//        }
//        return UITableViewCell()
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
//        let imageData = UIImageJPEGRepresentation(image, 0.3)!
//        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))"
//        let photoStorageRef = FirebaseMgr.shared.storageRef.child(filePath)
//        let photoRef = photoStorageRef.child("\(Constants.ImageData.ImageName)")
//        let metadata = FIRStorageMetadata()
//        metadata.contentType = Constants.ImageData.ContentTypeJPEG
//        FirebaseMgr.shared.uploadSelectedImageData(photoRef, imageData: imageData, metaData: metadata)
//        dismissViewControllerAnimated(true, completion: nil)
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
//            } else {
//                let noCameraAlert = UIAlertController.init(title: nil, message: "No camera attached to this device.", preferredStyle: .Alert)
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
//        actionSheet.addAction(takePhotoAction)
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
//        FirebaseMgr.shared.saveNewBio(userID, bioText: bioText)
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
