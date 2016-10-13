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
import Kingfisher

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
    // Home Questions Array
    var homeQuestionsArray = [Question]() {
        didSet {
            NSNotificationCenter.defaultCenter().postNotification((NSNotification(name: Constants.NotifKeys.HomeQuestionsRetrieved, object: nil)))
        }
    }
    //
    // Home Answers Array
    var homeAnswersArray = [Answer]() {
        didSet {
            NSNotificationCenter.defaultCenter().postNotification((NSNotification(name: Constants.NotifKeys.HomeAnswersRetrieved, object: nil)))
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
    func retrieveHomeQuestions() {
        //TODO: look up why use [weak self] in closure
        self.homeQuestionsArray = [Question]()
        self._questionsRefHandle = self.questionsRef().observeEventType(.ChildAdded, withBlock: { (questionSnapshot) in
            let retrievedQuestion = questionSnapshot.value as! [String: AnyObject]
            let questionID = questionSnapshot.key
                guard let
                    text = retrievedQuestion[Constants.QuestionFields.text] as? String,
                    userID = retrievedQuestion[Constants.QuestionFields.userID] as? String,
                    likeCount = retrievedQuestion[Constants.QuestionFields.likeCount] as? Int
                    else { return }
                let question = Question(questionID: questionID, text: text, userID: userID, likeCount: likeCount)
                self.homeQuestionsArray.insert(question, atIndex: 0)
        })
    }
    //MARK:
    //MARK: - Answer Data Retrieval
    //MARK:
    func retrieveHomeAnswers() {
        self.homeAnswersArray = [Answer]()
        self._answersRefHandle = self.answersRef().child(self.selectedQuestionID).observeEventType(.ChildAdded, withBlock: { (answerSnapshot) in
                let retrievedAnswer = answerSnapshot.value as! [String: AnyObject]
                let answerID = answerSnapshot.key
                    guard let
                        text = retrievedAnswer[Constants.AnswerFields.text] as? String,
                        userID = retrievedAnswer[Constants.AnswerFields.userID] as? String,
                        likeCount = retrievedAnswer[Constants.AnswerFields.likeCount] as? Int
                        else { return }
                    let answer = Answer(answerID: answerID, text: text, userID: userID, likeCount: likeCount)
                self.homeAnswersArray.insert(answer, atIndex: 0)
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
    
    func retrieveUserBio(userID: String, completion: (userBio: String?) -> Void) {
        self.usersRef().child("\(userID)/userBio").observeSingleEventOfType(.Value, withBlock: { (userBioSnapshot) in
            let retrievedUserBio = userBioSnapshot.value as? String
            completion(userBio: retrievedUserBio)
        })
    }
    //MARK:
    //MARK: - LikeStatus Data Retrieval
    //MARK:
    func retrieveLikeStatus(objectID: String, completion: (likeStatus: Int) -> Void) {
        guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
        self.likeStatusesRef().child(objectID).observeSingleEventOfType(.Value, withBlock: { (likeStatusesSnapshot) in
            if likeStatusesSnapshot.hasChild(currentUserID) {
                self.likeStatusesRef().child(objectID).child(currentUserID).observeSingleEventOfType(.Value, withBlock: { (likeStatusSnapshot) in
                    var retrievedLikeStatus = likeStatusSnapshot.value as! [String: Int]
                    if currentUserID == likeStatusSnapshot.key {
                        guard let likeStatus = retrievedLikeStatus[Constants.LikeStatusFields.likeStatus] else { return }
                        completion(likeStatus: likeStatus)
                    }
                })
            } else {
                let likeStatus = 0
                self.likeStatusesRef().child("\(objectID)/\(currentUserID)/likeStatus").setValue(0)
                completion(likeStatus: likeStatus)
            }
        })
    }
    //MARK:
    //MARK: - User Data Upload
    //MARK:
    func saveNewBio(userID: String, bioText: String) {
        self.usersRef().child("\(userID)/userBio").setValue(bioText)
    }
    //MARK:
    //MARK: - Question Like Count Data Upload
    //MARK:
    func saveNewQuestionLikeCount(questionID: String, completion: (newLikeCount: Int) -> Void) {
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
                            completion(newLikeCount: incrementedLikeCount)
                        } else if likeStatus == 1 {
                            let decrementedLikeCount = (currentLikeCount) - 1
                            self.questionsRef().child("\(questionID)/likeCount").setValue(decrementedLikeCount)
                            self.likeStatusesRef().child("\(questionID)/\(currentUserID)/likeStatus").setValue(0)
                            completion(newLikeCount: decrementedLikeCount)
                        }
                    })
                } else {
                    incrementedLikeCount = (currentLikeCount) + 1
                    self.questionsRef().child("\(questionID)/likeCount").setValue(incrementedLikeCount)
                    self.likeStatusesRef().child("\(questionID)/\(currentUserID)/likeStatus").setValue(1)
                    completion(newLikeCount: incrementedLikeCount)
                }
            })
        })
    }
    //MARK:
    //MARK: - New Question Data Upload
    //MARK:
    func saveNewQuestion(dataDict: [String: AnyObject], userID: String) {
        let key = self.questionsRef().childByAutoId().key
        let childUpdates = ["questions/\(key)": dataDict,
                            "likeStatuses/\(key)/\(userID)/likeStatus": 0]
        self.ref.updateChildValues(childUpdates as! [String : AnyObject])
    }
    //MARK:
    //MARK: - Answer Like Count Data Upload
    //MARK:
    func saveNewAnswerLikeCount(questionID: String, answerID: String, completion: (newLikeCount: Int) -> Void) {
        var incrementedLikeCount = Int()
        self.answersRef().child("\(questionID)/\(answerID)/likeCount").observeSingleEventOfType(.Value, withBlock: { (likeCountSnapshot) in
            guard let currentLikeCount = likeCountSnapshot.value as? Int else { return }
            guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else { return }
            self.likeStatusesRef().child(answerID).observeSingleEventOfType(.Value, withBlock: { (likeStatusesSnapshot) in
                if likeStatusesSnapshot.hasChild(currentUserID) {
                    self.likeStatusesRef().child(answerID).child(currentUserID).observeSingleEventOfType(.Value, withBlock: {
                        (likeStatusSnapshot) in
                        let likeStatusDict = likeStatusSnapshot.value as! [String: Int]
                        guard let likeStatus = likeStatusDict[Constants.LikeStatusFields.likeStatus] else { return }
                        if likeStatus == 0 {
                            incrementedLikeCount = (currentLikeCount) + 1
                            self.answersRef().child("\(questionID)/\(answerID)/likeCount").setValue(incrementedLikeCount)
                            self.likeStatusesRef().child("\(answerID)/\(currentUserID)/likeStatus").setValue(1)
                            completion(newLikeCount: incrementedLikeCount)
                        } else if likeStatus == 1 {
                            let decrementedLikeCount = (currentLikeCount) - 1
                            self.answersRef().child("\(questionID)/\(answerID)/likeCount").setValue(decrementedLikeCount)
                            self.likeStatusesRef().child("\(answerID)/\(currentUserID)/likeStatus").setValue(0)
                            completion(newLikeCount: decrementedLikeCount)
                        }
                    })
                } else {
                    incrementedLikeCount = (currentLikeCount) + 1
                    self.answersRef().child("\(questionID)/\(answerID)/likeCount").setValue(incrementedLikeCount)
                    self.likeStatusesRef().child("\(answerID)/\(currentUserID)/likeStatus").setValue(1)
                    completion(newLikeCount: incrementedLikeCount)
                }
            })
        })
    }
    //MARK:
    //MARK: - New Answer Data Upload
    //MARK:
    func saveNewAnswer(dataDict: [String: AnyObject], questionID: String, userID: String) {
        let key = self.answersRef().child(questionID).childByAutoId().key
        let childUpdates = ["answers/\(questionID)/\(key)": dataDict,
                            "likeStatuses/\(key)/\(userID)/likeStatus": 0]
        self.ref.updateChildValues(childUpdates as! [String : AnyObject])
    }
    //MARK:
    //MARK: - Image Data Upload
    //MARK:
    func uploadSelectedImageData(photoRef: FIRStorageReference, imageData: NSData, metaData: FIRStorageMetadata) {
        photoRef.putData(imageData, metadata: metaData) { metadata, error in
            if let error = error {
                print("Error uploading:\(error.localizedDescription)")
                return
            } else {
                //guard let downloadURL = metadata!.downloadURL() else { return }
                guard let downloadURLString = metadata!.downloadURL()?.absoluteString else { return }
                //self.imageView.kf_setImageWithURL(downloadURL, placeholderImage: nil, optionsInfo: nil)
                AppState.sharedInstance.photoDownloadURL = downloadURLString
                
                if let currentUserUID = FIRAuth.auth()?.currentUser?.uid {
                    self.usersRef().child("\(currentUserUID)/photoDownloadURL").setValue(downloadURLString)
                }
                
                let prefetchPhotoDownloadURL = [downloadURLString].map { NSURL(string: $0)! }
                let prefetcher = ImagePrefetcher(urls: prefetchPhotoDownloadURL, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (skippedResources, failedResources, completedResources) -> () in
                    print("These resources are prefetched: \(completedResources)")
                })
                prefetcher.start()
            }
        }
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
    //MARK:
    //MARK: - Firebase Ovbserver Removal
    //MARK:
    func removeAnswerObservers(For questionID: String) {
        self.answersRef().removeAllObservers()
        self.answersRef().child(questionID).removeAllObservers()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.usersRef().removeObserverWithHandle(self._usersNameRefHandle)
        self.usersRef().removeObserverWithHandle(self._usersPhotoRefHandle)
        self.questionsRef().removeObserverWithHandle(self._questionsRefHandle)
        self.answersRef().removeObserverWithHandle(self._answersRefHandle)
    }
}


















