//
//  Task.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 10/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import Foundation

struct Task {
    
    let id: String
    let userId: String
    
    let latitude: Double?
    let longitude: Double?
    let stringLocation: String?
    
    let reviewed: Int
    let status: Int
    
    let isOnline: Bool
    let duration: Double
    let budget: Int
    let category: String
    let description: String
    let title: String
    let creationDate: Date
    
    init(id: String, dictionary: [String : Any]) {
        
        self.id = id
        
        self.userId = dictionary[Constants.FirebaseDatabase.userId] as? String ?? ""
        let online = dictionary[Constants.FirebaseDatabase.isTaskOnline] as? Int ?? 1
        
        if online == 1 {
            self.isOnline = true
            self.latitude = nil
            self.longitude = nil
            self.stringLocation = nil
        } else {
            self.isOnline = false
            self.latitude = dictionary[Constants.FirebaseDatabase.latitude] as? Double ?? 41.390205
            self.longitude = dictionary[Constants.FirebaseDatabase.longitude] as? Double ?? 2.154007
            self.stringLocation = dictionary[Constants.FirebaseDatabase.stringLocation] as? String ?? ""
        }
        
        self.reviewed = dictionary[Constants.FirebaseDatabase.taskReviewed] as? Int ?? 0
        self.status = dictionary[Constants.FirebaseDatabase.taskStatus] as? Int ?? 0
        
        self.budget = dictionary[Constants.FirebaseDatabase.taskBudget] as? Int ?? 0
        self.category = dictionary[Constants.FirebaseDatabase.taskCategory] as? String ?? ""
        self.description = dictionary[Constants.FirebaseDatabase.taskDescription] as? String ?? ""
        self.title = dictionary[Constants.FirebaseDatabase.taskTitle] as? String ?? ""
        self.duration = dictionary[Constants.FirebaseDatabase.taskDuration] as? Double ?? 0.0
        
        let secondsFrom1970 = dictionary[Constants.FirebaseDatabase.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
