//
//  User.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 09/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let firstName: String
    let lastName: String
    let emailAddress: String
    let profileImageURLString: String
    
    init(uid: String, dictionary: [String : Any]) {
        
        self.uid = uid
        self.firstName = dictionary[Constants.FirebaseDatabase.firstName] as? String ?? "firstName"
        self.lastName = dictionary[Constants.FirebaseDatabase.lastName] as? String ?? "lastName"
        self.emailAddress = dictionary[Constants.FirebaseDatabase.emailAddress] as? String ?? "No email"
        self.profileImageURLString = dictionary[Constants.FirebaseDatabase.profileImageURLString] as? String ?? ""
    }
}
