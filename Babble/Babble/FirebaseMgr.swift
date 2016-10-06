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
    private var _usersRefHandle: FIRDatabaseHandle!
    private var selectedQuestionID = String()
    private var selectedUserID = String()
    var user: User?
    //
    // Questions Array
    //
    var questionsArray = [Question]() {
        didSet {
            self.questionsArray.sortInPlace {($0.likeCount > $1.likeCount)}
            NSNotificationCenter.defaultCenter().postNotification((NSNotification(name: Constants.NotifKeys.QuestionsRetrieved, object: nil)))
        }
    }
    //
    // Answers Array
    //
    var answersArray = [Answer]() {
        didSet {
            self.answersArray.sortInPlace {($0.likeCount > $1.likeCount)}
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
    
    func UsersRef() -> FIRDatabaseReference {
        return self.ref.child("users")
    }
    //MARK:
    //MARK: - Questions Data Retrieval
    //MARK:
    func retrieveQuestions() {
        //TODO: look up why use [weak self] in closure
        //TODO: use _refHandle in other places?
        self._questionsRefHandle = self.questionsRef().observeEventType(.Value, withBlock: { (questionSnapshot) in
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
    //MARK: - User Data Retrieval Method
    //MARK:
    func retrieveUserDisplayName(userID: String, completion: (displayName: String) -> Void) {
        //retrieve userID, displayName, photoURL, userBio, and OPTIONALLY photoDownloadURL
        self._usersRefHandle = self.UsersRef().child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
            var retrievedUser = userSnapshot.value as! [String: AnyObject]
            if userID == userSnapshot.key {
                guard let displayName = retrievedUser[Constants.UserFields.displayName] as? String else { return }
                completion(displayName: displayName)
            }
        })
    }
    
    func retrieveUserPhotoDownloadURL(userID: String, completion: (photoDownloadURL: String?, defaultImage: UIImage) -> Void) {
        self._usersRefHandle = self.UsersRef().child(userID).observeEventType(.Value, withBlock: { (userSnapshot) in
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
    
//                        if let photoDownloadURL = self.question[Constants.QuestionFields.photoDownloadURL] as! String? {
//                            let url = NSURL(string: photoDownloadURL)
//                            self.profilePhotoImageButton.kf_setImageWithURL(url, forState: .Normal, placeholderImage: UIImage(named: "Profile_avatar_placeholder_large"))
//                        } else if let photoUrl = self.question[Constants.QuestionFields.photoUrl] {
//                            let image = UIImage(named: "Profile_avatar_placeholder_large")
//                            self.profilePhotoImageButton.setImage(image, forState: .Normal)
//                        } else if let photoUrl = self.question[Constants.QuestionFields.photoUrl] {
//                            FIRStorage.storage().referenceForURL(photoUrl as! String).dataWithMaxSize(INT64_MAX) { (data, error) in
//                                self.profilePhotoImageButton.setImage(nil, forState: .Normal)
//                                if error != nil {
//                                    print("Error downloading: \(error)")
//                                    return
//                                } else {
//                                    let image = UIImage(data: data!)
//                                    self.profilePhotoImageButton.setImage(image, forState: .Normal)
//                                }
//                            }
//                        }
//        
//                    } else if let photoUrl = self.question[Constants.QuestionFields.photoUrl], url = NSURL(string:photoUrl as! String), data = NSData(contentsOfURL: url) {
//                        let image = UIImage(data: data)
//                        self.profilePhotoImageButton.setImage(image, forState: .Normal)
//        
//                    }
//                    self.profilePhotoImageButton.imageView?.contentMode = .ScaleAspectFill
//                    self.profilePhotoImageButton.layer.borderWidth = 1
//                    self.profilePhotoImageButton.layer.masksToBounds = false
//                    self.profilePhotoImageButton.layer.borderColor = UIColor.blackColor().CGColor
//                    self.profilePhotoImageButton.layer.cornerRadius = self.profilePhotoImageButton.bounds.width/2
//                    self.profilePhotoImageButton.clipsToBounds = true
//                })
//
//    }
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
        self.UsersRef().removeObserverWithHandle(self._usersRefHandle)
        self.answersRef().removeObserverWithHandle(self._answersRefHandle)
    }
}


















