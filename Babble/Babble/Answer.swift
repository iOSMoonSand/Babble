//
//  Answer.swift
//  Babble
//
//  Created by Alexis Schreier on 10/04/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import Foundation

class Answer {
    
    let answerID: String
    let text: String
    let userID: String
    var likeCount: Int
    
    init(answerID: String, text: String, userID: String, likeCount: Int){
        self.answerID = answerID
        self.text = text
        self.userID = userID
        self.likeCount = likeCount
    }
}
