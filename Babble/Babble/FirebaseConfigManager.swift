//
//  FirebaseConfigManager.swift
//  Babble
//
//  Created by Alexis Schreier on 08/22/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import Firebase

class FirebaseConfigManager {
    static let sharedInstance = FirebaseConfigManager()
    
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    var storageRef: FIRStorageReference! = FIRStorage.storage().referenceForURL("gs://babble-8b668.appspot.com/")
    var currentUser: FIRUser! = FIRAuth.auth()?.currentUser
}