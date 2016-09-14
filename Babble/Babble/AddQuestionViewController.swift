//
//  AddQuestionViewController.swift
//  Babble
//
//  Created by Alexis Schreier on 07/27/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit

//MARK:
//MARK: - AddQuestionViewControllerDelegate Class Protocol
//MARK:
protocol AddQuestionViewControllerDelegate: class {
    func handlePostQuestionButtonTapFor(newQuestionText: String)
}
//MARK:
//MARK: - AddQuestionViewController Class
//MARK:
class AddQuestionViewController: UIViewController {
    //MARK:
    //MARK: - Attributes
    //MARK:
    @IBOutlet weak var textView: UITextView!
    var newQuestionText: String?
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.PostNewQuestionToHome {
            newQuestionText = self.textView.text
            guard let destinationVC = segue.destinationViewController as? HomeScreenViewController else { return }
            destinationVC.newQuestion = newQuestionText
        }
    }
}

extension AddQuestionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        let placeholderText = "Example: Why do cats meow?"
        if self.textView.text == placeholderText {
            self.textView.text = ""
        }
    }
    
}














