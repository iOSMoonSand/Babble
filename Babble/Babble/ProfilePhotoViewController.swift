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
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    //MARK: -
    //MARK: - UIViewController Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        fullScreenImageView.image = imageFromMeVC
        configureStorage()
    }
    ///
    ///
    ///
    override func viewWillAppear(animated: Bool) {
    }
    ///
    ///
    ///
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.ProfilePhotoToMyProfile {
            guard let destinationVC = segue.destinationViewController as? MeViewController else { return }
            destinationVC.imageFromProfilePhotoVC = fullScreenImageView.image
        }
    }
    // MARK:
    // MARK: - Firebase Database Reference
    // MARK:
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
    }
    // MARK:
    // MARK: - Firebase Storage Reference
    // MARK:
    func configureStorage() {
        storageRef = FIRStorage.storage().referenceForURL("gs://babble-8b668.appspot.com/")
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
        
        // if it's a photo from the library, not an image from the camera
        if #available(iOS 8.0, *), let referenceUrl = info[UIImagePickerControllerReferenceURL] {
            let assets = PHAsset.fetchAssetsWithALAssetURLs([referenceUrl as! NSURL], options: nil)
            let asset = assets.firstObject
            asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput, info) in
                let imageFile = contentEditingInput?.fullSizeImageURL
                let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))/\(referenceUrl.lastPathComponent!)"
                self.storageRef.child(filePath).putFile(imageFile!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading:\(error.localizedDescription)")
                            return
                        }
                    let storageRefString = self.storageRef.child((metadata?.path)!).description
                    //let storageRefUrl = NSURL(string: storageRefString)
                        
//                    let data = [Constants.UserInfoFields.photoUrl: storageRefString]
//                    self.createUser(data)
                    
                    //AppState.sharedInstance.photoUrl = storageRefUrl
                }
            })
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier(Constants.Segues.ProfilePhotoToMyProfile, sender: nil)
    }
    
    func createUser(data: [String: String]) {
        self.configureDatabase()
        let userInfoData = data
        if let currentUserUID = FIRAuth.auth()?.currentUser?.uid{
            self.ref.child("userInfo").child(currentUserUID).setValue(userInfoData)
        }
    }
    
}








