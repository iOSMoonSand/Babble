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
    //MARK:
    //MARK: - Legal Terms and Conditions
    //MARK:
    struct TermsAndConditions {
        static let terms = "Welcome to Babble!\nWe want to make sure that everyone’s experience using this app is a good one. By choosing “I agree!” you agree to the following terms and conditions:\nAgree to Apple’s End User License Agreement (EULA) that can be found here: http://www.apple.com/legal/internet-services/itunes/appstore/dev/stdeula/\nAgree to the Offensive Messages terms: “Offensive Messages: There is no tolerance for objectionable content or abusive users. You may not use this app to send messages that are offensive. If you see a post or comment that you feel is offensive, please flag it to notify the administrator. Immediate corrective action will be taken by either blocking or suspending the author if they are deemed at fault.”"
    }
}
