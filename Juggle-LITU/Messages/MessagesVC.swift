//
//  MessagesVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 09/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class MessagesVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Messages"
        tableView.backgroundColor = .blue
        print("Messages VC loaded")
    }
    
}
