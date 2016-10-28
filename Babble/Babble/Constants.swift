//
//  Constants.swift
//  Babble
//
//  Created by Alexis Schreier on 06/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

//MARK:
//MARK: - Constants Structure
//MARK:
struct Constants {
    //MARK:
    //MARK: - Notification Names
    //MARK:
    struct NotifKeys {
        static let SendUserID = "SendUserID"
        static let SendQuestionID = "SendQuestionID"
        static let HomeQuestionsRetrieved = "HomeQuestionsRetrieved"
        static let HomeAnswersRetrieved = "HomeAnswersRetrieved"
    }
    //MARK:
    //MARK: - Segue IDs
    //MARK:
    struct Segues {
        static let SignInToHome = "SignInToHome"
        static let HomeToAnswers = "HomeToAnswers"
        static let HomeToAddQuestion = "HomeToAddQuestion"
        static let PostNewQuestionToHome = "PostNewQuestionToHome"
        static let MyProfileToProfilePhoto = "MyProfileToProfilePhoto"
        static let ProfilePhotoToMyProfile = "ProfilePhotoToMyProfile"
        static let DiscoverToDiscoverAnswers = "DiscoverToDiscoverAnswers"
        static let HomeToUserProfiles = "HomeToUserProfiles"
        static let AnswersToUserProfiles = "AnswersToUserProfiles"
        static let DiscoverToUserProfiles = "DiscoverToUserProfiles"
        static let DiscoverAnswersToUserProfiles = "DiscoverAnswersToUserProfiles"
    }
    //MARK:
    //MARK: - Image Uploading
    //MARK:
    struct ImageData {
        static let ImageName = "profileImage.jpg"
        static let ContentTypeJPEG = "image/jpeg"
    }
    //MARK:
    //MARK: - JSON: Questions Node
    //MARK:
    struct QuestionFields {// questions -> questionID
        static let questionID = "questionID"
        static let text = "text"
        static let userID = "userID"
        static let photoUrl = "photoURL"
        static let photoDownloadURL = "photoDownloadURL"
        static let displayName = "displayName"
        static let likeCountID = "likeCountID"
        static let likeCount = "likeCount"
        static let likeStatuses = "likeStatuses"
        static let date = "date"
    }
    //MARK:
    //MARK: - JSON: Answers Node
    //MARK:
    struct AnswerFields {// answers -> questionID -> answerID
        static let text = "text"
        static let userID = "userID"
        static let photoUrl = "photoURL"
        static let photoDownloadURL = "photoDownloadURL"
        static let likeCount = "likeCount"
        static let likeStatuses = "likeStatuses"
        static let displayName = "displayName"
        static let answerID = "answerID"
        static let questionID = "questionID"
    }
    //MARK:
    //MARK: - JSON: Answers Node
    //MARK:
    struct UserFields {//users -> userID
        static let photoURL = "photoURL"
        static let displayName = "displayName"
        static let userBio = "userBio"
        static let photoDownloadURL = "photoDownloadURL"
    }
}
