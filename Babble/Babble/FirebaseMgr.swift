//
//  FirebaseMgr.swift
//  Babble
//
//  Created by Alexis Schreier on 09/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

//will be used to construct the references used to pull data


import UIKit
import Firebase

//MARK:
//MARK: - FirebaseMgr Class Singleton
//MARK:
class FirebaseMgr {
    //MARK:
    //MARK: - Properties
    //MARK:
    static let shared = FirebaseMgr()
    let ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    let storageRef: FIRStorageReference! = FIRStorage.storage().referenceForURL("gs://babble-8b668.appspot.com/")
    private var _refHandle: FIRDatabaseHandle!
    var questionsArray = [Question]() {
        didSet {
            NSNotificationCenter.defaultCenter().postNotification((NSNotification(name: "questionsRetrieved", object: nil)))
        }
    }
    //MARK:
    //MARK: - FirebaseMgr Methods
    //MARK:
    func retrieveQuestions() {
        //TODO: look up why use [weak self] in closure
        //TODO: use _refHandle in other places?
        self._refHandle = self.ref.child("questions").observeEventType(.Value, withBlock: { (questionSnapshot) in
            self.questionsArray = [Question]()//make a new clean array
            let retrievedQuestions = questionSnapshot.value as! [String: [String: AnyObject]]
            var retrievedQuestion = [String: AnyObject]()
            for (key, value) in retrievedQuestions {
                retrievedQuestion = value
                retrievedQuestion[Constants.QuestionFields.questionID] = key
                guard let
                    questionID = retrievedQuestion[Constants.QuestionFields.questionID] as? String,
                    text = retrievedQuestion[Constants.QuestionFields.text] as? String,
                    userID = retrievedQuestion[Constants.QuestionFields.userID] as? String,
                    likeCount = retrievedQuestion[Constants.QuestionFields.likeCount] as? Int
                else { return }
                let question = Question(questionID: questionID, text: text, userID: userID, likeCount: likeCount)
                // question object includes: text, userID, questionID, likeCount
                self.questionsArray.append(question)
            }
        })
    }
    
    deinit {
        self.ref.child("questions").removeObserverWithHandle(self._refHandle)
    }
}







