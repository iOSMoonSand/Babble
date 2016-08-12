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
        static let HomeToSignIn = "HomeToSignIn"
        static let HomeToAnswersNavController = "HomeToAnswersNavController"
        static let HomeToAddQuestion = "HomeToAddQuestion"
        static let PostNewQuestionToHome = "PostNewQuestionToHome"
        static let MyProfileToProfilePhoto = "MyProfileToProfilePhoto"
        static let ProfilePhotoToMyProfile = "ProfilePhotoToMyProfile"
    }
    
    struct QuestionFields {
        static let questionID = "questionID"
        static let text = "text"
        static let userID = "userID"
        static let photoUrl = "photoURL"
    }
    
    struct AnswerFields {
        static let text = "text"
        static let userID = "userID"
        static let photoUrl = "photoURL"
    }
    
    struct UserFields {//each user separated by uid
        static let photoUrl = "photoURL"
        static let name = "name"
    }
}