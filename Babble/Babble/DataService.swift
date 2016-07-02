//
//  DataService.swift
//  Babble
//
//  Created by Alexis Schreier on 06/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//
//This is a service class that interacts with Firebase

import Foundation
import FirebaseAuth
import FirebaseDatabase

class DataService {
    
    //singleton shared instance
    static let sharedManager = DataService()
    
    //create a reference to your database
    let firebaseRef = FIRDatabase.database().reference()
    
    func funky{
        
        firebaseRef.ch
    }
    
}