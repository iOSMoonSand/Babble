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
    func errorAlert(title: String, message: String, presentingViewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "Ok", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        dispatch_async(dispatch_get_main_queue(), {
            presentingViewController.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}
