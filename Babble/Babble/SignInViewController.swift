//
//  SignInViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 06/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

//MARK:
//MARK: - SignInViewController Class
//MARK:
class SignInViewController: UIViewController {
    //MARK:
    //MARK: - Attributes
    //MARK:
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
        }
    }
    // MARK:
    // MARK: - Firebase Authentication Configuration
    // MARK:
    func signedIn(user: FIRUser?) {
        
        //<FIRUserInfo> protocol provides user data to FIRUser
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.signedIn = true
        
        let usersRef = FirebaseConfigManager.sharedInstance.ref.child("users")
        let userID = user!.uid
        usersRef.child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
            var user = userSnapshot.value as! [String: AnyObject]
            if let photoDownloadURL = user[Constants.UserFields.photoDownloadURL] as! String? {
                AppState.sharedInstance.photoDownloadURL = photoDownloadURL
                AppState.sharedInstance.profileImage = nil
                let prefetchPhotoDownloadURL = [photoDownloadURL].map { NSURL(string: $0)! }
                let prefetcher = ImagePrefetcher(urls: prefetchPhotoDownloadURL, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (skippedResources, failedResources, completedResources) -> () in
                    print("These resources are prefetched: \(completedResources)")
                })
                prefetcher.start()
            }
            
        })
        
        //NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
        performSegueWithIdentifier(Constants.Segues.SignInToHome, sender: self)
    }
    // MARK:
    // MARK: - IBAction: Sign In
    // MARK:
    @IBAction func didTapSignIn(sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text
        FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(user!)
        }
    }
    // MARK:
    // MARK: - IBAction: Create New Account
    // MARK:
    @IBAction func didTapCreateAccount(sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text
        FIRAuth.auth()?.createUserWithEmail(email!, password: password!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.setDisplayName(user!)
        }
    }
    
    func setDisplayName(user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.componentsSeparatedByString("@")[0]
        changeRequest.commitChangesWithCompletion() { [weak self] (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let placeholderPhotoRef = FirebaseConfigManager.sharedInstance.storageRef.child("Profile_avatar_placeholder_large.png")
            let placeholderPhotoRefString = "gs://babble-8b668.appspot.com/" + placeholderPhotoRef.fullPath ?? ""
            let userDataDict = [Constants.UserFields.photoUrl: placeholderPhotoRefString]
            self?.createUserData(userDataDict)
            self?.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    func createUserData(data: [String: String]) {
        var userDataDict = data
        let displayName = FIRAuth.auth()?.currentUser?.displayName
        userDataDict[Constants.UserFields.displayName] = displayName
        if let currentUserUID = FIRAuth.auth()?.currentUser?.uid {
            FirebaseConfigManager.sharedInstance.ref.child("users").child(currentUserUID).setValue(userDataDict)
        }
    }
    // MARK:
    // MARK: - IBAction: Reset Password
    // MARK:
    @IBAction func didTapForgotPassword(sender: AnyObject) {
        let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordResetWithEmail(userInput!) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        prompt.addTextFieldWithConfigurationHandler(nil)
        prompt.addAction(okAction)
        presentViewController(prompt, animated: true, completion: nil);
    }
}










