////
////  ProfilePhotoViewController.swift
////  Babble
////
////  Created by Alexis Schreier on 07/31/16.
////  Copyright © 2016 Alexis Schreier. All rights reserved.
////
//
//import UIKit
//import Firebase
//import Photos
//import Kingfisher
//
////MARK: -
////MARK: - ProfilePhotoViewController Class
////MARK: -
//@objc(ProfilePhotoViewController)
//class ProfilePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    //MARK: -
//    //MARK: - Propeties
//    //MARK: -
//    @IBOutlet weak var fullScreenImageView: UIImageView!
//    var imageFromMeVC: UIImage!
//    var selectedImage: UIImage!
//    //var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
//    //var storageRef: FIRStorageReference!
//    //var selectedImageURLString = String()
//    //MARK: -
//    //MARK: - UIViewController Methods
//    //MARK: -
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        fullScreenImageView.image = imageFromMeVC
//    }
//
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == Constants.Segues.ProfilePhotoToMyProfile {
//            guard let destinationVC = segue.destinationViewController as? MeViewController else { return }
//            destinationVC.imageFromProfilePhotoVC = self.selectedImage
//        }
//    }
//    //MARK: -
//    //MARK: - IBActions
//    //MARK: -
//    @IBAction func didTapEditProfilePhoto(sender: UIBarButtonItem) {
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
//                //self.presentViewController(imagePickerController, animated: true, completion: nil)
//                print("Camera option not yet configured :(")
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
//        actionSheet.addAction(takePhotoAction)
//        actionSheet.addAction(cancelAction)
//        presentViewController(actionSheet, animated: true, completion: nil);
//    }
//    //MARK: -
//    //MARK: - UIImagePickerControllerDelegate Methods
//    //MARK: -
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        
//        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
//        self.fullScreenImageView.image = image
//        //AppState.sharedInstance.profileImage = image
//        let profileImageName = "profileImageName.png"
//        let imageData = UIImagePNGRepresentation(image)!
//        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))"
//        
//        let photoStorageRef = self.storageRef.child(filePath)
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
//                guard let downloadURL = metadata!.downloadURL() else { return }
//                guard let downloadURLString = metadata!.downloadURL()?.absoluteString else { return }
//                self.fullScreenImageView.kf_setImageWithURL(downloadURL, placeholderImage: nil, optionsInfo: nil)
//                AppState.sharedInstance.photoDownloadURL = downloadURLString
//                
//                if let currentUserUID = FIRAuth.auth()?.currentUser?.uid {
//                    self.ref.child("users/\(currentUserUID)/photoDownloadURL").setValue(downloadURLString)
//                }
//                
//                let prefetchPhotoDownloadURL = [downloadURLString].map { NSURL(string: $0)! }
//                let prefetcher = ImagePrefetcher(urls: prefetchPhotoDownloadURL, optionsInfo: nil, progressBlock: nil, completionHandler: {
//                    (skippedResources, failedResources, completedResources) -> () in
//                    print("These resources are prefetched: \(completedResources)")
//                })
//                prefetcher.start()
//                
//                
//            }
//        }
//        dismissViewControllerAnimated(true, completion: nil)
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
