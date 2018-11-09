//
//  Constants.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 08/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import Foundation

class Constants {
    
    struct FirebaseStorage {
        static let profileImages = "profile_images"
    }
    
    struct FirebaseDatabase {
        static let usersRef = "users"
        static let userId = "userId"
        static let emailAddress = "emailAddress"
        static let fullName = "fullName"
        static let profileImageURLString = "profileImageURLString"
        
    }
    
    struct CollectionViewCellIds {
        static let userProfileHeaderCell = "userProfileHeaderCell"
//        static let taskCategoryCell = "taskCategoryCell"
//        static let taskCell = "taskCell"
//        static let ChooseTaskCategoryHeaderCell = "chooseTaskCategoryHeaderCell"
//        static let reviewCell = "reviewCell"
//        static let chatMessageCellId = "chatMessageCellId"
    }
    
    struct ErrorDescriptions {
        static let invalidPassword = "The password is invalid or the user does not have a password."
        static let invalidEmailAddress = "There is no user record corresponding to this identifier. The user may have been deleted."
        static let networkError = "Network error (such as timeout, interrupted connection or unreachable host) has occurred."
        static let unavailableEmail = "The email address is already in use by another account."
    }
}
