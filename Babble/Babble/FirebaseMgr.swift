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
    lazy var ref: FIRDatabaseReference! = {
        FIRDatabase.database().reference()
    }()
    lazy var storageRef: FIRStorageReference! = {
        FIRStorage.storage().referenceForURL("gs://babble-8b668.appspot.com/")
    }()
    private var _questionsRefHandle: FIRDatabaseHandle!
    private var _answersRefHandle: FIRDatabaseHandle!
    private var _usersNameRefHandle: FIRDatabaseHandle!
    private var _usersPhotoRefHandle: FIRDatabaseHandle!
    private var selectedQuestionID = String()
    private var selectedUserID = String()
    //
    // Questions Array
    var questionsArray = [Question]() {
        didSet {
            //self.questionsArray.sortInPlace {($0.likeCount > $1.likeCount)}
            NSNotificationCenter.defaultCenter().postNotification((NSNotification(name: Constants.NotifKeys.QuestionsRetrieved, object: nil)))
        }
    }
    //
    // Answers Array
    var answersArray = [Answer]() {
        didSet {
            //self.answersArray.sortInPlace {($0.likeCount > $1.likeCount)}
            NSNotificationCenter.defaultCenter().postNotification((NSNotification(name: Constants.NotifKeys.AnswersRetrieved, object: nil)))
        }
    }
    //MARK:
    //MARK: - Firebase Accessor Methods
    //MARK:
    func questionsRef() -> FIRDatabaseReference {
        return self.ref.child("questions")
    }
    
    func answersRef() -> FIRDatabaseReference {
        return self.ref.child("answers")
    }
    
    func usersRef() -> FIRDatabaseReference {
        return self.ref.child("users")
    }
    
    func likeStatusesRef() -> FIRDatabaseReference {
        return self.ref.child("likeStatuses")
    }
    //MARK:
    //MARK: - Questions Data Retrieval
    //MARK:
    func retrieveQuestions() {
        //TODO: look up why use [weak self] in closure
        //TODO: use _refHandle in other places?
        self.questionsRef().observeSingleEventOfType(.Value, withBlock: { (questionSnapshot) in
            //self.questionsArray = [Question]()//make a new clean array
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
                self.questionsArray.append(question)
            }
        })
    }
    //MARK:
    //MARK: - Answer Data Retrieval
    //MARK:
    func retrieveAnswers() {
        self._answersRefHandle = self.answersRef().child(self.selectedQuestionID).observeEventType(.Value, withBlock: { (answerSnapshot) in
            self.answersArray = [Answer]()//make a new clean array
            if answerSnapshot.value is NSNull {
            } else {
                let retrievedAnswers = answerSnapshot.value as! [String: [String: AnyObject]]
                var retrievedAnswer = [String: AnyObject]()
                for (key, value) in retrievedAnswers {
                    retrievedAnswer = value
                    retrievedAnswer[Constants.AnswerFields.answerID] = key
                    guard let
                        answerID = retrievedAnswer[Constants.AnswerFields.answerID] as? String,
                        text = retrievedAnswer[Constants.AnswerFields.text] as? String,
                        userID = retrievedAnswer[Constants.AnswerFields.userID] as? String,
                        likeCount = retrievedAnswer[Constants.AnswerFields.likeCount] as? Int
                        else { return }
                    let answer = Answer(answerID: answerID, text: text, userID: userID, likeCount: likeCount)
                    self.answersArray.append(answer)
                }
            }
        })
    }
    //MARK:
    //MARK: - User Data Retrieval
    //MARK:
    func retrieveUserDisplayName(userID: String, completion: (displayName: String) -> Void) {
        //retrieve userID, displayName, photoURL, userBio, and OPTIONALLY photoDownloadURL
        self._usersNameRefHandle = self.usersRef().child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
            var retrievedUser = userSnapshot.value as! [String: AnyObject]
            if userID == userSnapshot.key {
                guard let displayName = retrievedUser[Constants.UserFields.displayName] as? String else { return }
                completion(displayName: displayName)
            }
        })
    }
    
    func retrieveUserPhotoDownloadURL(userID: String, completion: (photoDownloadURL: String?, defaultImage: UIImage) -> Void) {
        self._usersPhotoRefHandle = self.usersRef().child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
            guard let defaultImage = UIImage(named: "Profile_avatar_placeholder_large") else { return }
            var retrievedUser = userSnapshot.value as! [String: AnyObject]
            if userID == userSnapshot.key {
                if let photoDownloadURL = retrievedUser[Constants.UserFields.photoDownloadURL] as? String {
                    completion(photoDownloadURL: photoDownloadURL, defaultImage: defaultImage)
                } else {
                    print("No photoDownloadURL: user has not selected a profile photo.")
                }
            }
        })
    }
    //MARK:
    //MARK: - Saving Like Count Data
    //MARK:
    func saveNewLikeCount(questionID: String, completion: (wantedQuestionIndex: Int, newLikeCount: Int) -> Void) {
        var incrementedLikeCount = Int()
        self.questionsRef().child("\(questionID)/likeCount").observeSingleEventOfType(.Value, withBlock: { (likeCountSnapshot) in
            guard let currentLikeCount = likeCountSnapshot.value as? Int else { return }
            guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
            self.likeStatusesRef().child(questionID).observeSingleEventOfType(.Value, withBlock: { (likeStatusesSnapshot) in
                if likeStatusesSnapshot.hasChild(currentUserID) {
                    self.likeStatusesRef().child(questionID).child(currentUserID).observeSingleEventOfType(.Value, withBlock: {
                        (likeStatusSnapshot) in
                        let likeStatusDict = likeStatusSnapshot.value as! [String: Int]
                        guard let likeStatus = likeStatusDict[Constants.LikeStatusFields.likeStatus] else { return }
                        if likeStatus == 0 {
                            incrementedLikeCount = (currentLikeCount) + 1
                            self.questionsRef().child("\(questionID)/likeCount").setValue(incrementedLikeCount)
                            self.likeStatusesRef().child("\(questionID)/\(currentUserID)/likeStatus").setValue(1)
                            
                            let wantedQuestionIndex = self.questionsArray.indexOf { $0.questionID == "\(questionID)" }
                            print(wantedQuestionIndex!)
                            completion(wantedQuestionIndex: wantedQuestionIndex!, newLikeCount: incrementedLikeCount)
                            
                        } else if likeStatus == 1 {
                            let decrementedLikeCount = (currentLikeCount) - 1
                            self.questionsRef().child("\(questionID)/likeCount").setValue(decrementedLikeCount)
                            self.likeStatusesRef().child("\(questionID)/\(currentUserID)/likeStatus").setValue(0)
                            
                            let wantedQuestionIndex = self.questionsArray.indexOf { $0.questionID == "\(questionID)" }
                            print(wantedQuestionIndex!)
                            completion(wantedQuestionIndex: wantedQuestionIndex!, newLikeCount: decrementedLikeCount)
                            
                        }
                    })
                } else {
                    incrementedLikeCount = (currentLikeCount) + 1
                    self.questionsRef().child("\(questionID)/likeCount").setValue(incrementedLikeCount)
                    self.likeStatusesRef().child("\(questionID)/\(currentUserID)/likeStatus").setValue(1)
                    
                    let wantedQuestionIndex = self.questionsArray.indexOf { $0.questionID == "\(questionID)" }
                    print(wantedQuestionIndex!)
                    completion(wantedQuestionIndex: wantedQuestionIndex!, newLikeCount: incrementedLikeCount)
                    
                }
            })
        })
    }
    //MARK:
    //MARK: - Notification Registration Methods
    //MARK:
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(storeQuestionIdDict(_:)), name: Constants.NotifKeys.SendQuestionID, object: nil)
    }
    
    @objc func storeQuestionIdDict(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            guard let questionID = userInfo["questionID"] as? String else { return }
            self.selectedQuestionID = questionID
        }
    }
    
    deinit {
        self.questionsRef().removeObserverWithHandle(self._questionsRefHandle)
        self.usersRef().removeObserverWithHandle(self._usersNameRefHandle)
        self.usersRef().removeObserverWithHandle(self._usersPhotoRefHandle)
        self.answersRef().removeObserverWithHandle(self._answersRefHandle)
    }
}


















