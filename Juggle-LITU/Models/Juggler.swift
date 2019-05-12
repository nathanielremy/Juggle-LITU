//
//  Juggler.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 15/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import Foundation

struct Juggler {

    let uid: String
    let firstName: String
    let lastName: String
    let emailAddress: String
    let profileImageURLString: String
    let accepted: Int

    init(uid: String, dictionary: [String : Any]) {

        self.uid = uid
        self.firstName = dictionary[Constants.FirebaseDatabase.firstName] as? String ?? "firstName"
        self.lastName = dictionary[Constants.FirebaseDatabase.lastName] as? String ?? "lastName"
        self.emailAddress = dictionary[Constants.FirebaseDatabase.emailAddress] as? String ?? "No email"
        self.profileImageURLString = dictionary[Constants.FirebaseDatabase.profileImageURLString] as? String ?? ""
        self.accepted = dictionary[Constants.FirebaseDatabase.userAccepted] as? Int ?? 0
    }
}
