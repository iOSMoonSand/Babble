//
//  MeVCTextViewCell.swift
//  Babble
//
//  Created by Alexis Schreier on 09/13/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit

//MARK:
//MARK: - MeVCTextViewCellDelegate Protocol
//MARK:
protocol MeVCTextViewCellDelegate: class {
    //MARK:
    //MARK: - MeVCTextViewCellDelegate Methods
    //MARK:
    func save(bioText: String)
}
//MARK:
//MARK: - MeVCTextViewCell Class
//MARK:
class MeVCTextViewCell: UITableViewCell {
    //MARK:
    //MARK: - Attributes
    //MARK:
    @IBOutlet weak var bioTextView: UITextView!
    weak var delegate: MeVCTextViewCellDelegate?
    //MARK:
    //MARK: - NSObject Methods
    //MARK:
    override func awakeFromNib() {
        super.awakeFromNib()
        bioTextView.delegate = self
    }
}

//MARK:
//MARK: - UITextViewDelegate Protocol
//MARK:
extension MeVCTextViewCell: UITextViewDelegate {
    //MARK:
    //MARK: - UITextViewDelegate Methods
    //MARK:
    func textViewDidBeginEditing(textView: UITextView) {
        print("textViewDidBeginEditing")
        let placeholderText = "Write your bio here!"
        if self.bioTextView.text == placeholderText {
            self.bioTextView.text = ""
            self.bioTextView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("textViewDidEndEditing")
        delegate?.save(textView.text)
    }
}






