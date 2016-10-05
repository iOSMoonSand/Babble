//
//  User.swift
//  Babble
//
//  Created by Alexis Schreier on 09/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import Foundation

class User {
    
    let userID: String
    let displayName: String
    let photoURL: String
    var photoDownloadURL: String?
    let userBio: String
    
    init(userID: String, displayName: String, photoURL: String, userBio: String){
        self.userID = userID
        self.displayName = displayName
        self.photoURL = photoURL
        self.userBio = userBio
    }
}