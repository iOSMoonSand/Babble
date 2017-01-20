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
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    let ref = FirebaseMgr.shared.ref
    let storageRef = FirebaseMgr.shared.storageRef
    var tapOutsideTextView = UITapGestureRecognizer()
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseMgr.shared.registerForNotifications()
        self.emailField.layer.borderColor = UIColor(red:0.27, green:0.69, blue:0.73, alpha:1.0).cgColor
        self.passwordField.layer.borderColor = UIColor(red:0.27, green:0.69, blue:0.73, alpha:1.0).cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.emailField.delegate = self
        self.passwordField.delegate = self
//        if let user = FIRAuth.auth()?.currentUser {
//            self.signedIn(user)
//        }
    }
    // MARK:
    // MARK: - Firebase Authentication Configuration
    // MARK:
    func signedIn(_ user: FIRUser?) {
        //<FIRUserInfo> protocol provides user data to FIRUser
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.signedIn = true
        let userID = user!.uid
        AppState.sharedInstance.currentUserID = userID
        self.ref?.child("users").child(userID).observe(.value, with: { (userSnapshot) in
            var user = userSnapshot.value as! [String: AnyObject]
            AppState.sharedInstance.photoDownloadURL = nil
            if let photoDownloadURL = user[Constants.UserFields.photoDownloadURL] as! String? {
                AppState.sharedInstance.photoDownloadURL = photoDownloadURL
                let urls = [photoDownloadURL].map { URL(string: $0)! }
                let prefetcher = ImagePrefetcher(urls: urls) {
                    skippedResources, failedResources, completedResources in
                    print("These resources are prefetched: \(completedResources)")
                }
                prefetcher.start()
            }
        })
        self.emailField.text = ""
        self.passwordField.text = ""
        performSegue(withIdentifier: Constants.Segues.SignInToHome, sender: self)
    }
    // MARK:
    // MARK: - IBAction: Sign In
    // MARK:
    @IBAction func didTapSignIn(_ sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
            if let error = error {
                Utility.shared.errorAlert("Oops", message: error.localizedDescription, presentingViewController: self)
                print(error.localizedDescription)
                return
            }
            self.signedIn(user!)
        }
    }
    // MARK:
    // MARK: - IBAction: Create New Account
    // MARK:
    @IBAction func didTapCreateAccount(_ sender: AnyObject) {
        AppState.sharedInstance.photoDownloadURL = nil
        let email = emailField.text
        let password = passwordField.text
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
            if let error = error {
                Utility.shared.errorAlert("Oops", message: error.localizedDescription, presentingViewController: self)
                print(error.localizedDescription)
                return
            }
            self.setDisplayNameAndDefaultPhoto(user!)
            user?.sendEmailVerification(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                print("Email verification sent.")
            })
        }
    }
    
    func setDisplayNameAndDefaultPhoto(_ user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
        changeRequest.commitChanges() { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let placeholderPhotoRef = self.storageRef?.child("Profile_avatar_placeholder_large.png")
            let placeholderPhotoRefString = "gs://babble-8b668.appspot.com/" + (placeholderPhotoRef?.fullPath)! ?? ""
            AppState.sharedInstance.defaultPhotoURL = placeholderPhotoRefString
            let userDataDict = [Constants.UserFields.photoURL: placeholderPhotoRefString]
            self.createUserData(userDataDict)
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    func createUserData(_ data: [String: String]) {
        var userDataDict = data
        let displayName = FIRAuth.auth()?.currentUser?.displayName
        userDataDict[Constants.UserFields.displayName] = displayName
        if let currentUserUID = FIRAuth.auth()?.currentUser?.uid {
            self.ref?.child("users").child(currentUserUID).setValue(userDataDict)
        }
    }
    // MARK:
    // MARK: - IBAction: Reset Password
    // MARK:
    @IBAction func didTapForgotPassword(_ sender: AnyObject) {
        let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!) { (error) in
                if let error = error {
                    Utility.shared.errorAlert("Oops", message: error.localizedDescription, presentingViewController: self)
                    print(error.localizedDescription)
                    return
                }
                Utility.shared.errorAlert("Nice!", message: "An email was sent to \(userInput!) to reset your password.", presentingViewController: self)
            }
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil);
    }
}
// MARK:
// MARK: - UITextFieldDelegate Protocol
// MARK:
extension SignInViewController: UITextFieldDelegate {
// MARK:
// MARK: - UITextFieldDelegate Methods
// MARK:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        self.tapOutsideTextView = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutsideTextViewWhenEditing))
        self.view.addGestureRecognizer(tapOutsideTextView)
    }
    
    func didTapOutsideTextViewWhenEditing() {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        self.view.removeGestureRecognizer(tapOutsideTextView)
    }
}








