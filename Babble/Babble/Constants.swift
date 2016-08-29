//
//  Constants.swift
//  Babble
//
//  Created by Alexis Schreier on 06/30/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

//"https://babble-8b668.firebaseio.com/"

struct Constants {
    
    struct NotificationKeys {
        static let SignedIn = "SignInCompleted"
    }
    
    struct Segues {
        static let SignInToHome = "SignInToHome"
        static let HomeToAnswers = "HomeToAnswers"
        static let HomeToAddQuestion = "HomeToAddQuestion"
        static let PostNewQuestionToHome = "PostNewQuestionToHome"
        static let MyProfileToProfilePhoto = "MyProfileToProfilePhoto"
        static let ProfilePhotoToMyProfile = "ProfilePhotoToMyProfile"
        static let HomeToProfile = "HomeToProfile"
    }
    
    struct QuestionFields {
        static let questionID = "questionID"
        static let text = "text"
        static let userID = "userID"
        static let photoUrl = "photoURL"
        static let displayName = "displayName"
        static let likeCountID = "likeCountID"
        static let likeCount = "likeCount"
    }
    
    struct AnswerFields {//each answer separated by questionID child
        static let text = "text"
        static let userID = "userID"
        static let photoUrl = "photoURL"
        static let likeCount = "likeCount"
        static let displayName = "displayName"
        static let answerID = "answerID"
        static let questionID = "questionID"
    }
    
    struct UserFields {//each user separated by userID child
        static let photoUrl = "photoURL"
        static let displayName = "displayName"
        static let userBio = "userBio"
        static let photoDownloadURL = "photoDownloadURL"
    }
    
    struct LikeCountFields {//each LikeCount separated by likeCountID child
        static let likeCount = "likeCount"
    }

}