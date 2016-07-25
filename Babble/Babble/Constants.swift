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
    }
    
    struct QuestionFields {
        static let name = "name"
        static let text = "text"
        static let photoUrl = "photoUrl"
        static let imageUrl = "imageUrl"
    }
    
    struct AnswerFields {
        static let name = "name"
        static let text = "text"
        static let photoUrl = "photoUrl"
        static let imageUrl = "imageUrl"
    }
}