//
//  AddQuestionViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/27/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit

class AddQuestionViewController: UIViewController, UITextViewDelegate {
    
//MARK: - Properties
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textLabel: UILabel!
    var newQuestionText: String?
   
//MARK: - UIViewController Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.PostNewQuestionToHome {
            newQuestionText = self.textView.text
            
            guard let destinationVC = segue.destinationViewController as? HomeScreenViewController else { return }
            destinationVC.newQuestion = newQuestionText
        }
    }
    
}
















