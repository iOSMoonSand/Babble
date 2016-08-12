//
//  SignInViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 06/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

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
        AppState.sharedInstance.photoUrlString = user?.photoURL
        AppState.sharedInstance.signedIn = true

        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
        performSegueWithIdentifier(Constants.Segues.SignInToHome, sender: nil)
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
        changeRequest.commitChangesWithCompletion(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        
        self.signedIn(FIRAuth.auth()?.currentUser)
        
        let placeholderPhotoRef = storageRef.child("Profile_avatar_placeholder_large.png")
        let placeholderPhotoRefString = "gs://babble-8b668.appspot.com/" + placeholderPhotoRef.fullPath
        
        let userDataDict = [Constants.UserFields.photoUrl: placeholderPhotoRefString]
        self.createUserData(userDataDict)
    }
    
    func createUserData(data: [String: String]) {
        configureDatabase()
        var userDataDict = data
        let displayName = FIRAuth.auth()?.currentUser?.displayName
        userDataDict[Constants.UserFields.displayName] = displayName
        if let currentUserUID = FIRAuth.auth()?.currentUser?.uid {
            self.ref.child("users").child(currentUserUID).setValue(userDataDict)
        }
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
    }
    
    func configureStorage() {
        storageRef = FIRStorage.storage().referenceForURL("gs://babble-8b668.appspot.com/")
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
