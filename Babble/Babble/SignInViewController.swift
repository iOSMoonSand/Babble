//
//  SignInViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 06/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

//MARK:
//MARK: - SignInViewController Class
//MARK:
class SignInViewController: UIViewController {
    //MARK:
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
//TODO: navigationItem.hidesBackButton = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.configureStorage()
        if let user = FIRAuth.auth()?.currentUser {
        self.signedIn(user)
            ref = FIRDatabase.database().reference()
            let usersRef = self.ref.child("users")
            let userID = user.uid
            usersRef.child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
                var user = userSnapshot.value as! [String: AnyObject]
                if let photoDownloadURL = user[Constants.UserFields.photoDownloadURL] as! String? {
                    FIRStorage.storage().referenceForURL(photoDownloadURL).dataWithMaxSize(INT64_MAX) { (data, error) in
                        if let error = error {
                            print("Error downloading: \(error)")
                            return
                        }
                        let image = UIImage(data: data!)
                        SDImageCache.sharedImageCache().storeImage(image, forKey: photoDownloadURL)
                        AppState.sharedInstance.profileImage = image
                        
                    }

                }
                
            })
            
            //check if user has profileimage url in Firebase
            // if so, download and cache profileImage
            // set url on AppState
        }
    }
    // MARK:
    // MARK: - Firebase Authentication Configuration
    // MARK:
    func signedIn(user: FIRUser?) {
        //<FIRUserInfo> protocol provides user data to FIRUser
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        //AppState.sharedInstance.photoUrlString = user?.photoURL
        AppState.sharedInstance.signedIn = true

        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
        performSegueWithIdentifier(Constants.Segues.SignInToHome, sender: nil)
    }
    // MARK:
    // MARK: - Firebase Storage Configuration
    // MARK:
    func configureStorage() {
        storageRef = FIRStorage.storage().referenceForURL("gs://babble-8b668.appspot.com/")
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
        self.configureStorage()
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.componentsSeparatedByString("@")[0]
        changeRequest.commitChangesWithCompletion() { [weak self] (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let placeholderPhotoRef = self?.storageRef.child("Profile_avatar_placeholder_large.png") else { return }
            let placeholderPhotoRefString = "gs://babble-8b668.appspot.com/" + placeholderPhotoRef.fullPath ?? ""
            let userDataDict = [Constants.UserFields.photoUrl: placeholderPhotoRefString]
            self?.createUserData(userDataDict)
            self?.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    func createUserData(data: [String: String]) {
        ref = FIRDatabase.database().reference()
        var userDataDict = data
        let displayName = FIRAuth.auth()?.currentUser?.displayName
        userDataDict[Constants.UserFields.displayName] = displayName
        if let currentUserUID = FIRAuth.auth()?.currentUser?.uid {
            self.ref.child("users").child(currentUserUID).setValue(userDataDict)
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
