////
////  MeVCImageCell.swift
////  Babble
////
////  Created by Alexis Schreier on 09/13/16.
////  Copyright © 2016 Alexis Schreier. All rights reserved.
////
//
//import UIKit
//
//protocol MeVCImageCellDelegate: class {
//    func didTapProfilePhotoImageView()
//}
//
//class MeVCImageCell: UITableViewCell {
//    @IBOutlet weak var profileImageView: UIImageView!
//    @IBOutlet weak var editLabel: UILabel!
//    weak var delegate: MeVCImageCellDelegate?
//    
//    override func awakeFromNib() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
//        self.profileImageView.addGestureRecognizer(tapGesture)
////        self.profileImageView.layer.borderWidth = 1
////        self.profileImageView.layer.masksToBounds = false
////        self.profileImageView.layer.borderColor = UIColor.blackColor().CGColor
////        self.profileImageView.layer.cornerRadius = profileImageView.bounds.width/2
////        self.profileImageView.clipsToBounds = true
//    }
//    
//    func imageTapped() {
//        delegate?.didTapProfilePhotoImageView()
//    }
//}
