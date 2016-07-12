//
//  SignInViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 06/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

//SignUp a user, set display name, Sign In with email/password, remember a signed in user and request a password reset

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //checks if user login creds are cashed, if so: sign in, if not display the Login view
    override func viewDidAppear(animated: Bool) {
        
        //if-let optional binding, accesses auth shared instance and gets the current cashed user if there is one
        if let user = FIRAuth.auth()?.currentUser {
            
            //method defined below to sign users in
            self.signedIn(user)
        }
    }
    
    func signedIn(user: FIRUser?) {
        
//        MeasurementHelper.sendLoginEvent()
//
//        //<FIRUserInfo> is a protocol that represents user data from an identity provider (the user)
//        //FIRUser is the delegate
//        //gives us the user's display name if one was entered or else their email
//        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
//        //URL of the user's profile photo
//        AppState.sharedInstance.photoUrl = user?.photoURL
//        //idicates the user is singed in
//        AppState.sharedInstance.signedIn = true
//        
//        //creates notification in the Notification Center's dispatch table named "SignInCompleted" and posts it to the receiver
//        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
//        
        performSegueWithIdentifier(Constants.Segues.SignInToHome, sender: nil)
    }
    
    @IBAction func didTapSignIn(sender: AnyObject) {
        
        //variables that store the user-inputed email and password in the VC's text field
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
    
    @IBAction func didTapCreateAccount(sender: AnyObject) {
        
        ////variables that store the user-inputed email and password in the VC's text field
        let email = emailField.text
        let password = passwordField.text
        
        //Creates and, on success, signs in a user with the given email address and password
        FIRAuth.auth()?.createUserWithEmail(email!, password: password!) { (user, error) in
            if let error = error {//if there's an error
                
                print(error.localizedDescription)
                return
            }
            //success calls this method which logs user in
            self.setDisplayName(user!)
        }
    }
    
    func setDisplayName(user: FIRUser) {
        
        //Creates an object which may be used to change the user's profile data.
        let changeRequest = user.profileChangeRequest()
        //Set the properties of the returned object: set to index 0 of the returned [String]
        changeRequest.displayName = user.email!.componentsSeparatedByString("@")[0]
        //then call FIRUserProfileChangeRequest.commitChangesWithCallback: to perform the updates atomically.
        changeRequest.commitChangesWithCompletion(){ (error) in
            if let error = error {
                
                print(error.localizedDescription)
                return
            }
            //sign in the current user
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    @IBAction func didTapForgotPassword(sender: AnyObject) {
        
        //configuring the alert controller with the actions and style you want
        let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { (action) in
            
            //stores the user input (email) in `userInput`
            let userInput = prompt.textFields![0].text
            
            if (userInput!.isEmpty) {//fail block
                return
            }
            //if user successfully entered a valid email address, send a password reset email to it
            FIRAuth.auth()?.sendPasswordResetWithEmail(userInput!) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        
        //adds a text field to the alert
        prompt.addTextFieldWithConfigurationHandler(nil)
        //adds okAction to prompt
        prompt.addAction(okAction)
        //displays the configured alert message to the user
        presentViewController(prompt, animated: true, completion: nil);
    }
}
