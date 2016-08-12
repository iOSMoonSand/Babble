//
//  QuestionCell.swift
//  Babble
//
//  Created by Alexis Schreier on 08/12/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit

//MARK:
//MARK: - UITableViewCell Class
//MARK:
class QuestionCell: UITableViewCell {
    //MARK:
    //MARK: - Properties
    //MARK:
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var likeButtonImageView: UIImageView!
    @IBOutlet weak var likeButtonCountLabel: UILabel!
    
}
