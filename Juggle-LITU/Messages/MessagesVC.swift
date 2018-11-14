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
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        tableView.refreshControl = refreshController
        
        // Register table view cell
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: Constants.TableViewCellIds.messageTableViewCell)
        
        
        observeUserMessages()
    }
    
    @objc fileprivate func handleRefresh() {
        observeUserMessages()
    }
    
    fileprivate func observeUserMessages() {
        print("Observe user messages")
    }
    
    //MARK: Table view delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIds.messageTableViewCell, for: indexPath) as! MessageTableViewCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    //FIXME: Implement functionality to delete rows below
    
    func disableAndAnimate(_ bool: Bool) {
        DispatchQueue.main.async {
            if bool {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
                self.tableView.refreshControl?.endRefreshing()
            }
            self.tableView.isUserInteractionEnabled = !bool
        }
    }
}
