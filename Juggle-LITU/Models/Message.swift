//
//  Message.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 15/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

struct Message {
    
    let messageKey: String
    let taskId: String
    let fromId: String
    let toId: String
    let text: String
    let timeStamp: Date
    let taskOwnerId: String
    
    func chatPartnerId() -> String? {
        return self.toId == Auth.auth().currentUser?.uid ? self.fromId : self.toId
    }
    
    init(key: String, dictionary: [String : Any]) {
        self.messageKey = key
        self.taskId = dictionary[Constants.FirebaseDatabase.taskId] as? String ?? ""
        self.fromId = dictionary[Constants.FirebaseDatabase.fromId] as? String ?? ""
        self.toId = dictionary[Constants.FirebaseDatabase.toId] as? String ?? ""
        self.text = dictionary[Constants.FirebaseDatabase.text] as? String ?? ""
        self.taskOwnerId = dictionary[Constants.FirebaseDatabase.taskOwnerId] as? String ?? ""
        
        let secondsFrom1970 = dictionary[Constants.FirebaseDatabase.timeStamp] as? Double ?? 0
        self.timeStamp = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
