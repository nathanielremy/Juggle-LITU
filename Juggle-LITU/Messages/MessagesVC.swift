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
    
    //MARK: Stored properties
    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    var timer: Timer?
    
    let noResultsView: UIView = {
        let view = UIView.noResultsView(withText: "No New Messages.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate func showNoResultsFoundView() {
        DispatchQueue.main.async {
            self.tableView?.addSubview(self.noResultsView)
            self.noResultsView.centerYAnchor.constraint(equalTo: (self.tableView?.centerYAnchor)!).isActive = true
            self.noResultsView.centerXAnchor.constraint(equalTo: (self.tableView?.centerXAnchor)!).isActive = true
        }
    }
    
    fileprivate func removeNoResultsView() {
        DispatchQueue.main.async {
            self.noResultsView.removeFromSuperview()
        }
    }
    
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
        
        // Register table view cell
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: Constants.TableViewCellIds.messageTableViewCell)
        
        // Manualy refresh the tableView
        let refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        tableView.refreshControl = refreshController
        tableView.alwaysBounceVertical = true
        
        observeUserMessages()
    }
    
    @objc fileprivate func handleRefresh() {
        observeUserMessages()
    }
    
    fileprivate func observeUserMessages() {
        self.disableAndAnimate(true)
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { print("Could not fetch currentUserId"); self.disableAndAnimate(false); return }
        
        // Fetch the references to message objects in database
        let ref = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(currentUserId)
        
        ref.observe(.childAdded, with: { (snapShot) in
            
            self.disableAndAnimate(true)
            
            let userId = snapShot.key
            
            // From reference fetch message objects
            let userRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(currentUserId).child(userId)
            
            self.disableAndAnimate(false)
            
            userRef.observe(.childAdded, with: { (snapshot2) in
                
                self.disableAndAnimate(true)
                
                let messageId = snapshot2.key
                self.fetchMessage(withMessageId: messageId)
                
            }, withCancel: { (error) in
                print("Error fetching messages: ", error); self.disableAndAnimate(false); return
            })
        }) { (error) in
            print("ERROR: ", error); self.disableAndAnimate(false); return
        }
        
        ref.observe(.childRemoved, with: { (snapshot3) in
            self.messagesDictionary.removeValue(forKey: snapshot3.key)
            self.attemptReloadTable()
        }) { (error) in
            print("Error fetching data when child removed: ", error); self.disableAndAnimate(false); return
        }
    }
    
    fileprivate func attemptReloadTable() {
        // Solution to only reload the tableView once
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadTableView), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTableView() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (msg1, msg2) -> Bool in
            return Double(msg1.timeStamp.timeIntervalSince1970) > Double(msg2.timeStamp.timeIntervalSince1970)
        })
        
        // Reload table view
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func fetchMessage(withMessageId messageId: String) {
        let messagesRef = Database.database().reference().child(Constants.FirebaseDatabase.messagesRef).child(messageId)
        self.disableAndAnimate(false)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.disableAndAnimate(true)
            guard let dictionary = snapshot.value as? [String : Any] else { print("snapShot not convertible to [String : Any]"); self.disableAndAnimate(false); return }
            
            let message = Message(key: snapshot.key, dictionary: dictionary)
            
            //Grouping all messages per user
            if let chatPartnerId = message.chatPartnerId() {
                self.messagesDictionary[chatPartnerId] = message
            }
            
            //Solution to only reload tableView once
            self.attemptReloadTable()
            self.disableAndAnimate(false)
            
        }, withCancel: { (error) in
            print("ERROR: ", error); self.disableAndAnimate(false); return
        })
    }
    
    fileprivate func prepareChatController(forJuggler juggler: Juggler, indexPath: Int, taskOwner: String) {
        let taskId = self.messages[indexPath].taskId
        
        let taskRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(taskOwner).child(taskId)
        taskRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String : Any] else {
                DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                }
                let alert = UIView.okayAlert(title: "Cannot Load Messages", message: "We are currently unable to load messages for this user.")
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let task = Task(id: snapshot.key, dictionary: dictionary)
            self.showChatController(forTask: task, juggler: juggler)
            
        }) { (error) in
            print("Error fetching task: ", error); return
        }
    }
    
    fileprivate func showChatController(forTask task: Task?, juggler: Juggler) {
        DispatchQueue.main.async {
            self.disableAndAnimate(false)
            let chatLogVC = ChatLogVC(collectionViewLayout: UICollectionViewFlowLayout())
            chatLogVC.data = (juggler, task)
            self.navigationController?.pushViewController(chatLogVC, animated: true)
        }
    }
    
    //MARK: Table view delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.messages.count == 0 {
            self.showNoResultsFoundView()
        } else {
            self.removeNoResultsView()
        }
        
        return self.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIds.messageTableViewCell, for: indexPath) as! MessageTableViewCell
        
        let message = self.messages[indexPath.row]
        
        if self.messages.count >= indexPath.row {
            if let uId = message.chatPartnerId() {
                Database.fetchJuggler(jugglerID: uId) { (jglr) in
                    guard let juggler = jglr else { print("Could not fetch Juggler from Database"); return }
                    DispatchQueue.main.async {
                        cell.message = (message, juggler)
                        cell.delegate = self
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.disableAndAnimate(true)
        let message = self.messages[indexPath.row]
        
        //Select correct user to show in ChatLogVC
        guard let jugglerId = message.chatPartnerId() else {
            self.disableAndAnimate(false)
            print("No chat partner Id"); return
        }
        Database.fetchJuggler(jugglerID: jugglerId) { (jglr) in
            guard let juggler = jglr else {
                let alert = UIView.okayAlert(title: "Cannot Load Messages", message: "We are currently unable to load messages for this user.")
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.prepareChatController(forJuggler: juggler, indexPath: indexPath.row, taskOwner: message.taskOwnerId)
        }
        
    }
    
    //Enable the tableView to delete messages
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //What happens when user hits delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { print("Could not fetch current user Id"); return }
        guard let chatParterId = self.messages[indexPath.row].chatPartnerId() else { print("Could not fetch chatPartnerId"); return }

        let deleteRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(currentUserId).child(chatParterId)
        deleteRef.removeValue { (err, _) in
            if let error = err {
                print("Error deleting value from database: ", error)
                return
            }

            self.messagesDictionary.removeValue(forKey: chatParterId)
            self.attemptReloadTable()
        }
    }
    
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

extension MessagesVC: MessageTableViewCellDelegate {
    // WHat happens when user taps on Juggler's profile image
    func handleProfileImageView(forJuggler juggler: Juggler?) {
        if let juggler = juggler {
            
            let jugglerProfileVC = JugglerProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            jugglerProfileVC.juggler = juggler
            
            navigationController?.pushViewController(jugglerProfileVC, animated: true)
            
        } else {
            
            let alert = UIView.okayAlert(title: "Unable to Load User", message: "Tap the 'Okay' button and try again.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func handleViewTaskButton(forTask task: Task?) {
        if let task = task {
            
            let taskDetailsVC = TaskDetailsVC()
            taskDetailsVC.task = task
            navigationController?.pushViewController(taskDetailsVC, animated: true)
            
        } else {
            let alert = UIView.okayAlert(title: "Unable to Load Task", message: "Tap the 'Okay' button and try again.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func handleAcceptJuggler(forTask task: Task?, juggler: Juggler?, completion: @escaping (Bool) -> Void) {
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            
            let unableAlert = UIView.okayAlert(title: "Unable to Accept Juggler", message: "You are currently unable to accept this Juggler. Please try again later.")
            
            guard let task = task, let juggler = juggler else {
                self.present(unableAlert, animated: true, completion: nil)
                completion(false)
                return
            }
            
            if task.status != 0 {
                let alert = UIView.okayAlert(title: "Task Already Accepted", message: "You have already accepted another Juggler to complete this task.")
                self.present(alert, animated: true, completion: nil)
                completion(false)
                return
            }
            
            // Update user's task to have a status of 1. Which means it has been accepted
            let userValues = [Constants.FirebaseDatabase.taskStatus : 1]
            let usersRef =  Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(task.userId).child(task.id)
            usersRef.updateChildValues(userValues) { (err, _) in
                
                if let error = err {
                    print("MessagesVC/MessageTableViewCellDelegate/handleAcceptJuggler ERROR: ", error)
                    completion(false)
                    return
                }
            }
            
            // Reference to the task
            let taskId = task.id
            
            // Store a reference to Tasks for juggler
            let acceptJugglerRef = Database.database().reference().child(Constants.FirebaseDatabase.acceptedTasks).child(juggler.uid).child(task.userId)
            acceptJugglerRef.updateChildValues([taskId : 1]) { (err, _) in
                
                if let error = err {
                    print("MessagesVC/MessageTableViewCellDelegate/handleAcceptJuggler ERROR: ", error)
                    completion(false)
                    return
                }
            }
            
            // Store a reference to Tasks for user
            let acceptUserRef = Database.database().reference().child(Constants.FirebaseDatabase.acceptedTasks).child(task.userId).child(juggler.uid)
            acceptUserRef.updateChildValues([taskId : 1]) { (err, _) in
                
                if let error = err {
                    print("MessagesVC/MessageTableViewCellDelegate/handleAcceptJuggler ERROR: ", error)
                    completion(false)
                    return
                }
            }
            
            // Succesfuly accepted juggler for task
            completion(true)
            self.tableView.reloadData()
        }
        
        let alert = UIAlertController(title: "Accept Juggler?", message: "Are you sure you want to accept this juggler to complete your task?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(false)
        }
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
