//
//  AppState.swift
//  Babble
//
//  Created by Alexis Schreier on 07/27/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    var signedIn = false
    var displayName: String?
    var photoDownloadURL: String?
    var defaultPhotoURL: String?
}

