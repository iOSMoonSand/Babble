//
//  SignInViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 06/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import Kingfisher

struct SignInConstants {
    static let emailPlaceholder = "Email address"
    static let passwordPlaceholder = "Password"
}

//MARK:
//MARK: - SignInViewController Class
//MARK:
class SignInViewController: UIViewController {
    //MARK:
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordIconImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    let ref = FirebaseMgr.shared.ref
    let storageRef = FirebaseMgr.shared.storageRef
    var tapOutsideTextView = UITapGestureRecognizer()
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewGradient = CAGradientLayer()
        viewGradient.frame = self.view.bounds
        viewGradient.colors = [
            UIColor(red:0.43, green:0.84, blue:0.73, alpha:1.0).cgColor,
            UIColor(red:0.25, green:0.69, blue:0.60, alpha:1.0).cgColor
        ]
        self.view.layer.insertSublayer(viewGradient, at: 0)
        
        self.logoImageView.image = self.logoImageView.image?.withRenderingMode(.alwaysTemplate)
        self.logoImageView.tintColor = UIColor(red:0.25, green:0.50, blue:0.60, alpha:1.0)
        
        self.emailIconImageView.image = self.emailIconImageView.image?.withRenderingMode(.alwaysTemplate)
        self.emailIconImageView.tintColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7)
        self.emailField.layer.borderWidth = 0.0
        self.emailField.textColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        self.emailField.attributedPlaceholder = NSAttributedString(string: SignInConstants.emailPlaceholder, attributes: [NSForegroundColorAttributeName: UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7)])
        self.passwordIconImageView.image = self.passwordIconImageView.image?.withRenderingMode(.alwaysTemplate)
        self.passwordIconImageView.tintColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7)
        self.passwordField.layer.borderWidth = 0.0
        self.passwordField.textColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        self.passwordField.attributedPlaceholder = NSAttributedString(string: SignInConstants.passwordPlaceholder, attributes:[NSForegroundColorAttributeName: UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7)])
        
        self.fbLoginButton.delegate = self
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        self.createAccountButton.setTitleColor(UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7), for: .normal)
        self.forgotPasswordButton.setTitleColor(UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7), for: .normal)
        
        
        self.setUserDefaults()
        FirebaseMgr.shared.registerForNotifications()
        self.emailField.layer.borderColor = UIColor(red:0.27, green:0.69, blue:0.73, alpha:1.0).cgColor
        self.passwordField.layer.borderColor = UIColor(red:0.27, green:0.69, blue:0.73, alpha:1.0).cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.makeUserAcceptTerms()
        self.emailField.delegate = self
        self.passwordField.delegate = self
//        if FBSDKAccessToken.current() != nil {
//            guard let user = FIRAuth.auth()?.currentUser else { return }
//            self.signedIn(user)
//        }
//        guard let user = FIRAuth.auth()?.currentUser else { return }
//        self.signedIn(user)
    }
    
    //MARK: - EULA and user-generated content agreement
    func setUserDefaults() {
        UserDefaults.standard.bool(forKey: "launchedBefore")
    }
    func makeUserAcceptTerms() {
        if UserDefaults.standard.bool(forKey: "launchedBefore")  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            let termsAlert = UIAlertController.init(title: "User-generated Content Agreement", message: Constants.TermsAndConditions.terms, preferredStyle: .alert)
            let yesAction = UIAlertAction.init(title: "I agree!", style: .default) { (action) in
                UserDefaults.standard.set(true, forKey: "launchedBefore")
                return
            }
            let noAction = UIAlertAction.init(title: "I disagree.", style: .default) { (action) in
                let alert2 = UIAlertController(title: "Oops", message: "You must agree to the Terms & Conditions to use this app.", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    self.present(termsAlert, animated: true, completion: nil)
                }))
                self.present(alert2, animated: true, completion: nil)
            }
            termsAlert.addAction(yesAction)
            termsAlert.addAction(noAction)
            self.present(termsAlert, animated: true, completion: nil)
        }
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
            //create profile photo Url AppState and upload to Firebase
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

extension SignInViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
//            self.signedIn(user)
            if let error = error {
                Utility.shared.errorAlert("Oops", message: error.localizedDescription, presentingViewController: self)
                print(error.localizedDescription)
                return
            }
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //required method
        print("not using this method")
    }
}






