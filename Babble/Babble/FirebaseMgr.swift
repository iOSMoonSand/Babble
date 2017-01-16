//
//  FirebaseMgr.swift
//  Babble
//
//  Created by Alexis Schreier on 09/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

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
        FIRStorage.storage().reference(forURL: "gs://babble-8b668.appspot.com/")
    }()
    fileprivate var _questionsRefHandle: FIRDatabaseHandle!
    fileprivate var _answersRefHandle: FIRDatabaseHandle!
    fileprivate var _usersNameRefHandle: FIRDatabaseHandle!
    fileprivate var _usersPhotoRefHandle: FIRDatabaseHandle!
    fileprivate var selectedQuestionID = String()
    fileprivate var selectedUserID = String()
    // Home Questions Array
    var homeQuestionsArray = [Question]() {
        didSet {
            NotificationCenter.default.post((Notification(name: Notification.Name(rawValue: Constants.NotifKeys.HomeQuestionsRetrieved), object: nil)))
        }
    }
    // Home Answers Array
    var homeAnswersArray = [Answer]() {
        didSet {
            NotificationCenter.default.post((Notification(name: Notification.Name(rawValue: Constants.NotifKeys.HomeAnswersRetrieved), object: nil)))
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
        self.homeQuestionsArray = [Question]()
        self._questionsRefHandle = self.questionsRef().observe(.childAdded, with: { (questionSnapshot) in
            let retrievedQuestion = questionSnapshot.value as! [String: AnyObject]
            let questionID = questionSnapshot.key
            guard let
                text = retrievedQuestion[Constants.QuestionFields.text] as? String,
                let userID = retrievedQuestion[Constants.QuestionFields.userID] as? String,
                let likeCount = retrievedQuestion[Constants.QuestionFields.likeCount] as? Int
                else { return }
            let question = Question(questionID: questionID, text: text, userID: userID, likeCount: likeCount)
            if let likeStatuses = retrievedQuestion[Constants.QuestionFields.likeStatuses] as? [String: Bool] {
                question.likeStatuses = likeStatuses
            }
            self.homeQuestionsArray.insert(question, at: 0)
        })
    }
    //MARK:
    //MARK: - Answer Data Retrieval
    //MARK:
    func retrieveHomeAnswers() {
        self.homeAnswersArray = [Answer]()
        self._answersRefHandle = self.answersRef().child(self.selectedQuestionID).observe(.childAdded, with: { (answerSnapshot) in
            let retrievedAnswer = answerSnapshot.value as! [String: AnyObject]
            let answerID = answerSnapshot.key
            guard let
                text = retrievedAnswer[Constants.AnswerFields.text] as? String,
                let userID = retrievedAnswer[Constants.AnswerFields.userID] as? String
            else { return }
            let answer = Answer(answerID: answerID, text: text, userID: userID)
            self.homeAnswersArray.insert(answer, at: 0)
        })
    }
    //MARK:
    //MARK: - User Data Retrieval
    //MARK:
    func retrieveUserDisplayName(_ userID: String, completion: @escaping (_ displayName: String) -> Void) {
        //retrieve userID, displayName, photoURL, userBio, and OPTIONALLY photoDownloadURL
        self._usersNameRefHandle = self.usersRef().child(userID).observe(.value, with: { (userSnapshot) in
            var retrievedUser = userSnapshot.value as! [String: AnyObject]
            if userID == userSnapshot.key {
                guard let displayName = retrievedUser[Constants.UserFields.displayName] as? String else { return }
                completion(displayName)
            }
        })
    }
    
    func retrieveUserPhotoDownloadURL(_ userID: String, completion: @escaping (_ photoDownloadURL: String?, _ defaultImage: UIImage) -> Void) {
        self._usersPhotoRefHandle = self.usersRef().child(userID).observe(.value, with: { (userSnapshot) in
            guard let defaultImage = UIImage(named: "Profile_avatar_placeholder_large") else { return }
            var retrievedUser = userSnapshot.value as! [String: AnyObject]
            if userID == userSnapshot.key {
                if let photoDownloadURL = retrievedUser[Constants.UserFields.photoDownloadURL] as? String {
                    completion(photoDownloadURL, defaultImage)
                } else {
                    print("No photoDownloadURL: user has not selected a profile photo.")
                }
            }
        })
    }
    
    func retrieveUserBio(_ userID: String, completion: @escaping (_ userBio: String?) -> Void) {
        self.usersRef().child("\(userID)/userBio").observeSingleEvent(of: .value, with: { (userBioSnapshot) in
            let retrievedUserBio = userBioSnapshot.value as? String
            completion(retrievedUserBio)
        })
    }
    //MARK:
    //MARK: - User Data Upload
    //MARK:
    func saveNewBio(_ userID: String, bioText: String) {
        self.usersRef().child("\(userID)/userBio").setValue(bioText)
    }
    //MARK:
    //MARK: - Question Like Count Data Upload
    //MARK:
    func saveNewQuestionLikeCount(_ questionID: String, completion: @escaping (_ newLikeCount: Int, _ like: Bool) -> Void) {
        var incrementedLikeCount = Int()
        var decrementedLikeCount = Int()
        self.questionsRef().child(questionID).observeSingleEvent(of: .value, with: { questionSnapshot in
            guard let retrievedQuestion = questionSnapshot.value as? [String: AnyObject] else { return }
            guard let currentLikeCount = retrievedQuestion[Constants.QuestionFields.likeCount] as? Int else { return }
            guard let currentUserID = AppState.sharedInstance.currentUserID else { return }
            if var likeStatusesDict = retrievedQuestion[Constants.QuestionFields.likeStatuses] as? [String: Bool] {
                for (key, value) in likeStatusesDict {
                    if key == currentUserID {
                        self.questionsRef().child("\(questionID)/likeStatuses/\(currentUserID)").removeValue()
                        decrementedLikeCount = currentLikeCount - 1
                        self.questionsRef().child("\(questionID)/likeCount").setValue(decrementedLikeCount)
                        completion(decrementedLikeCount, false)
                    } else if likeStatusesDict[currentUserID] == nil {
                        let newLikeStatus = [currentUserID: true]
                        likeStatusesDict[currentUserID] = true
                        incrementedLikeCount = currentLikeCount + 1
                        self.questionsRef().child("\(questionID)/likeCount").setValue(incrementedLikeCount)
                        self.questionsRef().child(questionID).child("likeStatuses").updateChildValues(newLikeStatus)
                        completion(incrementedLikeCount, true)
                    }
                }
            } else {
                let newLikeStatus = [currentUserID: true]
                incrementedLikeCount = currentLikeCount + 1
                self.questionsRef().child("\(questionID)/likeCount").setValue(incrementedLikeCount)
                self.questionsRef().child(questionID).child("likeStatuses").setValue(newLikeStatus)
                completion(incrementedLikeCount, true)
            }
        })
    }
    //MARK:
    //MARK: - New Question Data Upload
    //MARK:
    func saveNewQuestion(_ dataDict: [String: AnyObject], userID: String) {
        let key = self.questionsRef().childByAutoId().key
        let childUpdates = ["questions/\(key)": dataDict,
                            "likeStatuses/\(key)/\(userID)/likeStatus": 0] as [String : Any]
        self.ref.updateChildValues(childUpdates as [String : AnyObject])
    }
    //MARK:
    //MARK: - New Answer Data Upload
    //MARK:
    func saveNewAnswer(_ dataDict: [String: AnyObject], questionID: String, userID: String) {
        let key = self.answersRef().child(questionID).childByAutoId().key
        let childUpdates = ["answers/\(questionID)/\(key)": dataDict]
        self.ref.updateChildValues(childUpdates)
    }
    //MARK:
    //MARK: - Image Data Upload
    //MARK:
    func uploadSelectedImageData(_ photoRef: FIRStorageReference, imageData: Data, metaData: FIRStorageMetadata) {
        photoRef.put(imageData, metadata: metaData) { metadata, error in
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
                
                let prefetchPhotoDownloadURL = [downloadURLString].map { URL(string: $0)! }
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
        NotificationCenter.default.addObserver(self, selector: #selector(storeQuestionIdDict(_:)), name: NSNotification.Name(rawValue: Constants.NotifKeys.SendQuestionID), object: nil)
    }
    
    @objc func storeQuestionIdDict(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            guard let questionID = userInfo["questionID"] as? String else { return }
            self.selectedQuestionID = questionID
        }
    }
    //MARK:
    //MARK: - Firebase Observer Removal
    //MARK:
    func removeAnswerObservers(For questionID: String) {
        self.answersRef().removeAllObservers()
        self.answersRef().child(questionID).removeAllObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.usersRef().removeObserver(withHandle: self._usersNameRefHandle)
        self.usersRef().removeObserver(withHandle: self._usersPhotoRefHandle)
        self.questionsRef().removeObserver(withHandle: self._questionsRefHandle)
        self.answersRef().removeObserver(withHandle: self._answersRefHandle)
    }
}


















