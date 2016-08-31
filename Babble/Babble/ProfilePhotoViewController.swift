//
//  ProfilePhotoViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/31/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase
import Photos
import SDWebImage

//MARK: -
//MARK: - ProfilePhotoViewController Class
//MARK: -
@objc(ProfilePhotoViewController)
class ProfilePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: -
    //MARK: - Propeties
    //MARK: -
    @IBOutlet weak var fullScreenImageView: UIImageView!
    var imageFromMeVC: UIImage!
    var selectedImage: UIImage!
    //var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    //var storageRef: FIRStorageReference!
    var selectedImageURLString = String()
    //MARK: -
    //MARK: - UIViewController Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        fullScreenImageView.image = imageFromMeVC
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.ProfilePhotoToMyProfile {
            guard let destinationVC = segue.destinationViewController as? MeViewController else { return }
            destinationVC.imageFromProfilePhotoVC = self.selectedImage
        }
    }
    //MARK: -
    //MARK: - IBActions
    //MARK: -
    @IBAction func didTapEditProfilePhoto(sender: UIBarButtonItem) {
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
                //self.presentViewController(imagePickerController, animated: true, completion: nil)
                print("Camera option not yet configured :(")
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
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(cancelAction)
        presentViewController(actionSheet, animated: true, completion: nil);
    }
    //MARK: -
    //MARK: - UIImagePickerControllerDelegate Methods
    //MARK: -
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.fullScreenImageView.image = self.selectedImage
        AppState.sharedInstance.profileImage = self.selectedImage
        //
        // if it's a photo from the library, not an image from the camera
        //
        if let selectedImageURL = info[UIImagePickerControllerReferenceURL] {
            //get selected image URL
            let assets = PHAsset.fetchAssetsWithALAssetURLs([selectedImageURL as! NSURL], options: nil)
            let asset = assets.firstObject
            asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput, info) in
                let imageFile = contentEditingInput?.fullSizeImageURL
                //create a new gs unique file name fir the selected photo
                let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))/\(selectedImageURL.lastPathComponent!)"
                //add the image file to the newly create filePath with completion...
                FirebaseConfigManager.sharedInstance.storageRef.child(filePath).putFile(imageFile!, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Error uploading:\(error.localizedDescription)")
                        return
                    } else {
                        //store the image in cache using the downloadURL
                        //store the downloadURL in AppState singleton
                        //set the downloadURL as a child value for the current user
                        if let url = metadata?.downloadURL()?.absoluteString {
                            SDImageCache.sharedImageCache().storeImage(self.selectedImage, forKey: url)
                            AppState.sharedInstance.photoUrlString = url
                            if let currentUserUID = FirebaseConfigManager.sharedInstance.currentUser?.uid {
                                FirebaseConfigManager.sharedInstance.ref.child("users/\(currentUserUID)/photoDownloadURL").setValue(url)
                            }
                        }
                        //update the current user's photoURL as well
                        self.selectedImageURLString = FirebaseConfigManager.sharedInstance.storageRef.child((metadata?.path)!).description
                        if let currentUserUID = FirebaseConfigManager.sharedInstance.currentUser?.uid {
                            FirebaseConfigManager.sharedInstance.ref.child("users/\(currentUserUID)/photoURL").setValue(self.selectedImageURLString)
                            //this sets the full screen image of the ProfilePhotoVC
                            self.setSelectedImageAsProfileImageView()
                        }
                    }
                }
                //once completion ends, the imageFile is in gs
            })
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setSelectedImageAsProfileImageView() {
        if self.selectedImageURLString.isEmpty {
            print("selectedImageURLString is an empty string...")
        } else {
            FIRStorage.storage().referenceForURL(self.selectedImageURLString).dataWithMaxSize(INT64_MAX) { (data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                self.fullScreenImageView.image = UIImage(data: data!)
            }
        }
    }
}








