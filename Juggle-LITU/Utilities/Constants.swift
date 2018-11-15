//
//  Constants.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 08/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import Foundation

class Constants {
    
    struct BarcalonaCoordinates {
        static let maximumLatitude: Double = 41.465
        static let minimumLatitude: Double = 41.320
        static let maximumLongitude: Double = 2.190
        static let minimumLongitude: Double = 2.069
    }
    
    struct FirebaseStorage {
        static let profileImages = "profile_images"
    }
    
    struct FirebaseDatabase {
        static let usersRef = "users"
        static let userId = "userId"
        static let emailAddress = "emailAddress"
        static let fullName = "fullName"
        static let profileImageURLString = "profileImageURLString"
        
        static let jugglersRef = "jugglers"
        static let userAccepted = "userAccepted"
        
        static let applicationsRef = "applications"
        
        static let tasksRef = "tasks"
        static let taskStatus = "taskStatus"
        static let taskReviewed = "taskReviewed"
        static let taskCategory = "taskCategory"
        static let taskTitle = "taskTitle"
        static let taskDescription = "taskDescription"
        static let taskBudget = "taskBudget"
        static let isTaskOnline = "isTaskOnline"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let stringLocation = "stringLocation"
        static let creationDate = "creationDate"
        
        static let messagesRef = "messages"
        static let userMessagesRef = "user-messages"
        static let text = "text"
        static let fromId = "fromId"
        static let toId = "toId"
        static let taskId = "taskId"
        static let timeStamp = "timeStamp"
        static let taskOwnerId = "taskOwnerId"
    }
    
    struct CollectionViewCellIds {
        static let userProfileHeaderCell = "userProfileHeaderCell"
        static let jugglerProfileHeaderCell = "jugglerProfileHeaderCell"
        static let taskCategoryCell = "taskCategoryCell"
//        static let ChooseTaskCategoryHeaderCell = "chooseTaskCategoryHeaderCell"
//        static let reviewCell = "reviewCell"
        static let chatMessageCellId = "chatMessageCellId"
    }
    
    struct TableViewCellIds {
        static let messageTableViewCell = "messageTableViewCell"
    }
    
    struct TaskCategories {
        static let all = "All"
        static let cleaning = "Cleaning"
        static let delivery = "Delivery"
        static let moving = "Moving"
        static let computerIT = "Computer/IT"
        static let handyMan = "Handyman"
        static let gardening = "Gardening"
        static let assembly = "Assembly"
        static let other = "Other"
        
        static func categoryArray() -> [String] {
            return [self.cleaning, self.delivery, self.moving, self.computerIT, self.handyMan, self.gardening, self.assembly, self.other]
        }
    }
    
    struct ErrorDescriptions {
        static let invalidPassword = "The password is invalid or the user does not have a password."
        static let invalidEmailAddress = "There is no user record corresponding to this identifier. The user may have been deleted."
        static let networkError = "Network error (such as timeout, interrupted connection or unreachable host) has occurred."
        static let unavailableEmail = "The email address is already in use by another account."
    }
}
