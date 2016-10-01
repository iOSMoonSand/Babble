//
//  Question.swift
//  Babble
//
//  Created by Alexis Schreier on 09/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import Foundation

class Question {
    
    let questionID: String
    let text: String
    let userID: String
    let likeCount: Int
    
    init(questionID: String, text: String, userID: String, likeCount: Int){
        self.questionID = questionID
        self.text = text
        self.userID = userID
        self.likeCount = likeCount
    }
}








