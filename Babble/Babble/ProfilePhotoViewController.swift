//
//  ProfilePhotoViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/31/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit

class ProfilePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: -
    //MARK: - Propeties
    //MARK: -
    @IBOutlet weak var fullScreenImageView: UIImageView!
    var imageFromMeVC: UIImage!
    var selectedImage: UIImage!
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
            destinationVC.imageFromProfilePhotoVC = fullScreenImageView.image
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
                self.presentViewController(imagePickerController, animated: true, completion: nil)
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
        selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        fullScreenImageView.image = selectedImage
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier(Constants.Segues.ProfilePhotoToMyProfile, sender: nil)
    }
    
}











