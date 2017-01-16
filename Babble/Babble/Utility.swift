//
//  Utility.swift
//  Babble
//
//  Created by Alexis Schreier on 10/28/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import Foundation
import UIKit

//MARK:
//MARK: - Utility Class Singleton
//MARK:
class Utility {
    //MARK:
    //MARK: - Properties
    //MARK:
    static let shared = Utility()
    //MARK:
    //MARK: - Instance Methods
    //MARK:
    func errorAlert(_ title: String, message: String, presentingViewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Ok", style: .default) { (action) in }
        alertController.addAction(OKAction)
        DispatchQueue.main.async(execute: {
            presentingViewController.present(alertController, animated: true, completion: nil)
        })
    }
}
