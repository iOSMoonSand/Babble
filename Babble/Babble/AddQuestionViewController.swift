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
    func handlePostQuestionButtonTapFor(_ newQuestionText: String)
}
//MARK:
//MARK: - AddQuestionViewController Class
//MARK:
class AddQuestionViewController: UIViewController {
    //MARK:
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var textView: UITextView!
    var newQuestionText: String?
    //MARK:
    //MARK: - UIViewController Methods
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.textView.text = "Example: Swift 2.2 or Swift 3.0?"
        self.textView.textColor = UIColor.lightGray
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == Constants.Segues.PostNewQuestionToHome {
            if self.textView.text == "" || self.textView.text == "Example: Swift 2.2 or Swift 3.0?" {
                Utility.shared.errorAlert("Oops", message: "Please write something before tapping the Post button.", presentingViewController: self)
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.PostNewQuestionToHome {
            newQuestionText = self.textView.text
            guard let destinationVC = segue.destination as? HomeScreenViewController else { return }
            destinationVC.newQuestion = newQuestionText
        }
    }
}
//MARK:
//MARK: - UITextViewDelegate Protocol
//MARK:
extension AddQuestionViewController: UITextViewDelegate {
    //MARK:
    //MARK: - UITextViewDelegate Methods
    //MARK:
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.textView.text == "Example: Swift 2.2 or Swift 3.0?" {
            self.textView.text = ""
            self.textView.textColor = UIColor.black
        }
    }
}














