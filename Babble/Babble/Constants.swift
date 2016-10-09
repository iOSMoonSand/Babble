//
//  Constants.swift
//  Babble
//
//  Created by Alexis Schreier on 06/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

struct Constants {
    
    struct NotifKeys {
        static let SendUserID = "SendUserID"
        static let SendQuestionID = "SendQuestionID"
        static let HomeQuestionsRetrieved = "HomeQuestionsRetrieved"
        static let DiscoverQuestionsRetrieved = "DiscoverQuestionsRetrieved"
        static let HomeAnswersRetrieved = "HomeAnswersRetrieved"
        static let DiscoverAnswersRetrieved = "DiscoverAnswersRetrieved"
    }
    
    struct Segues {
        static let SignInToHome = "SignInToHome"
        static let HomeToAnswers = "HomeToAnswers"
        static let HomeToAddQuestion = "HomeToAddQuestion"
        static let PostNewQuestionToHome = "PostNewQuestionToHome"
        static let MyProfileToProfilePhoto = "MyProfileToProfilePhoto"
        static let ProfilePhotoToMyProfile = "ProfilePhotoToMyProfile"
        static let HomeToProfiles = "HomeToProfiles"
        static let AnswersToProfiles = "AnswersToProfiles"
        static let DiscoverToDiscoverAnswers = "DiscoverToDiscoverAnswers"
        static let DiscoverToProfiles = "DiscoverToProfiles"
    }
    
    struct ImageData {
        static let ImageName = "profileImage.jpg"
        static let ContentTypeJPEG = "image/jpeg"
    }
    
    struct QuestionFields {
        static let questionID = "questionID"
        static let text = "text"
        static let userID = "userID"
        static let photoUrl = "photoURL"
        static let photoDownloadURL = "photoDownloadURL"
        static let displayName = "displayName"
        static let likeCountID = "likeCountID"
        static let likeCount = "likeCount"
        static let date = "date"
    }
    
    struct AnswerFields {//each answer separated by questionID child
        static let text = "text"
        static let userID = "userID"
        static let photoUrl = "photoURL"
        static let photoDownloadURL = "photoDownloadURL"
        static let likeCount = "likeCount"
        static let displayName = "displayName"
        static let answerID = "answerID"
        static let questionID = "questionID"
    }
    
    struct UserFields {//each user separated by userID child
        static let photoURL = "photoURL"
        static let displayName = "displayName"
        static let userBio = "userBio"
        static let photoDownloadURL = "photoDownloadURL"
    }
    
    struct LikeCountFields {//each LikeCount separated by likeCountID child
        static let likeCount = "likeCount"
    }
    
    struct LikeStatusFields {//each question has users who each have an individual like status
        static let likeStatus = "likeStatus"
    }
}
