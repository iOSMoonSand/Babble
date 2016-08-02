

//
//  MeViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/29/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit


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
//MARK: -
//MARK: - UIViewController Methods
//MARK: -
    override func viewDidLoad() {
        textView.delegate = self
        
        navigationItem.hidesBackButton = true
        imageView.layer.cornerRadius = imageView.bounds.width/2
        imageView.clipsToBounds = true
        if imageFromProfilePhotoVC != nil {
            imageView.image = imageFromProfilePhotoVC
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.MyProfileToProfilePhoto {
            guard let destinationVC = segue.destinationViewController as? ProfilePhotoViewController else { return }
            destinationVC.imageFromMeVC = imageView.image
        }
    }
}

extension MeViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
    }
    
    @IBAction func didTapProfileImage(sender: UITapGestureRecognizer) {
        //action segue to present ProfilePhotoVC added via Storyboard
    }
    
    @IBAction func didTapCancelProfilePhotoEdit(segue: UIStoryboardSegue) {
        //exit segue back to MeVC
    }
    
}













