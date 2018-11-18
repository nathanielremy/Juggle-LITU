//
//  Review.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 18/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import Foundation

struct Review {
    
    let id: String
    let userId: String
    let intRating: Double
    let creationDate: Date
    let reviewString: String
    
    init(id: String, dictionary: [String : Any]) {
        self.id = id
        self.userId = dictionary[Constants.FirebaseDatabase.userId] as? String ?? ""
        self.intRating = dictionary[Constants.FirebaseDatabase.rating] as? Double ?? 0
        self.reviewString = dictionary[Constants.FirebaseDatabase.reviewDescription] as? String ?? ""
        
        let secondsFrom1970 = dictionary[Constants.FirebaseDatabase.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
