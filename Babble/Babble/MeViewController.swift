

//
//  MeViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/29/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase


//MARK: -
//MARK: - MeViewControllerClass
//MARK: -
class MeViewController: UITableViewController {
//MARK: -
//MARK: - Properties
//MARK: -
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    var imageFromProfilePhotoVC: UIImage!
    var storageRef: FIRStorageReference!
//MARK: -
//MARK: - UIViewController Methods
//MARK: -
    override func viewDidLoad() {
        
        self.configureStorage()
        
        navigationItem.hidesBackButton = true
        //
        //TODO: why not user FIRUser ?
        //
        
//        if let photoUrl = AppState.sharedInstance.photoUrlString? {
//        
//            FIRStorage.storage().referenceForURL(photoUrl).dataWithMaxSize(INT64_MAX) { (data, error) in
//                if let error = error {
//                    print("Error downloading: \(error)")
//                    return
//                }
//                self.imageView.image = UIImage.init(data: data!)
//            }
//        } else if let photoUrl = AppState.sharedInstance.photoUrlString?, url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
//            self.imageView.image = UIImage.init(data: data)
//        } else {
//            self.imageView.image = UIImage(named: "ic_account_circle")
//        }

//        if imageFromProfilePhotoVC != nil {
//            imageView.image = imageFromProfilePhotoVC
//        }
    }

    override func viewWillAppear(animated: Bool) {
        imageView.layer.cornerRadius = imageView.bounds.width/2
        imageView.clipsToBounds = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.MyProfileToProfilePhoto {
            guard let destinationVC = segue.destinationViewController as? ProfilePhotoViewController else { return }
            destinationVC.imageFromMeVC = imageView.image
        }
    }
    
    func configureStorage() {
        storageRef = FIRStorage.storage().referenceForURL("gs://babble-8b668.appspot.com/")
    }
    
    
    
    
    @IBAction func didTapProfilePhotoImageView(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier(Constants.Segues.MyProfileToProfilePhoto, sender: self)
    }
    

}













