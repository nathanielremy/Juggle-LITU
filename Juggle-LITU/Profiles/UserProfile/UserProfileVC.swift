//
//  UserProfileVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 09/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: Stored properties
    var user: User?
    
    var allTasks = [Task]()
    var pendingTasks = [Task]()
    
    var acceptedTasks = [Task]()
    var acceptedJugglers = [String : [Task]]()
    
    var completedTasks = [Task]()
    var completedJugglers = [String : [Task]]()
    
    // currentHeaderButton values
    // 0 == pendingButton
    // 1 == acceptedButton
    // 2 == completedButton
    var currentHeaderButton = 0
    
    let noResultsView: UIView = {
        let view = UIView.noResultsView(withText: "No Results Found.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate func showNoResultsFoundView() {
        self.collectionView?.reloadData()
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.collectionView?.addSubview(self.noResultsView)
            self.noResultsView.centerYAnchor.constraint(equalTo: (self.collectionView?.centerYAnchor)!).isActive = true
            self.noResultsView.centerXAnchor.constraint(equalTo: (self.collectionView?.centerXAnchor)!).isActive = true
        }
    }
    
    fileprivate func removeNoResultsView() {
        self.collectionView?.reloadData()
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.noResultsView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        // Register all collection view cells
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.userProfileHeaderCell)
        collectionView.register(PendingTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.pendingTaskCell)
        collectionView.register(AcceptedTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.acceptedTaskCell)
        collectionView.register(CompletedTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.completedTaskCell)
        
        collectionView?.alwaysBounceVertical = true
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshController
        
        guard let userId = Auth.auth().currentUser?.uid else { fatalError() }
        self.fetchUser(forUserId: userId)
        self.fetchUsersTasks(forUserId: userId)
        self.fetchAcceptedTasks(forUserId: userId)
        self.fetchCompletedTasks(forUserId: userId)
    }
    
    @objc fileprivate func handleRefresh() {
        guard let userId = Auth.auth().currentUser?.uid else { fatalError() }
        self.fetchUser(forUserId: userId)
        
        if self.currentHeaderButton == 0 {
            self.fetchUsersTasks(forUserId: userId)
        } else if self.currentHeaderButton == 1 {
            self.fetchAcceptedTasks(forUserId: userId)
        } else if self.currentHeaderButton == 2 {
            self.fetchCompletedTasks(forUserId: userId)
        }
    }
    
    //Fetch user to populate UI and fetch appropriate data.
    fileprivate func fetchUser(forUserId userId: String) {
        self.fetchUsersTasks(forUserId: userId)
        
        Database.fetchUserFromUserID(userID: userId) { (user) in
            if let user = user {
                self.user = user
                DispatchQueue.main.async {
                    self.navigationItem.title = user.fullName
                    self.user = user
                    self.setupSettingsBarButton()
                    self.collectionView.reloadData()
                }
            } else {
                // Crash the app if no user is returned from the above function call.
                fatalError("Could not load user in UserProfileVC...")
            }
        }
    }
    
    fileprivate func setupSettingsBarButton() {
        let settingsBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(handleSettingsBarButton))
        settingsBarButton.tintColor = UIColor.mainBlue()
        navigationItem.rightBarButtonItem = settingsBarButton
    }
    
    @objc fileprivate func handleSettingsBarButton() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                let loginVC = LoginVC()
                let signupNavController = UINavigationController(rootViewController: loginVC)
                self.present(signupNavController, animated: true, completion: nil)
                
            } catch let signOutError {
                print("Unable to sign out: \(signOutError)")
                let alert = UIView.okayAlert(title: "Unable to Log out", message: "You are unnable to log out at this moment.")
                self.display(alert: alert)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Retrieve tasks for user
    fileprivate func fetchUsersTasks(forUserId userId: String) {
        let tasksRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(userId)
        tasksRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let snapshotDictionary = snapshot.value as? [String : Any] else {
                self.allTasks.removeAll()
                self.showNoResultsFoundView()
                return
            }
            
            // Empty arrays and dictionaries to allow new values to be stored
            self.allTasks.removeAll()
            self.pendingTasks.removeAll()
            
            snapshotDictionary.forEach({ (key, value) in
                guard let postDictionary = value as? [String : Any] else { self.showNoResultsFoundView(); return }
                
                let task = Task(id: key, dictionary: postDictionary)
                
                self.allTasks.append(task)
                
                if task.status == 0 {
                    self.pendingTasks.append(task)
                }
                
                // Rearrange the allTasks and pendingTasks array to be from most recent to oldest
                self.allTasks.sort(by: { (task1, task2) -> Bool in
                    return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                })
                self.pendingTasks.sort(by: { (task1, task2) -> Bool in
                    return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                })
            })
            
            if self.allTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            }
            
            // currentHeaderButton values
            // 0 == pendingButton
            // 1 == acceptedButton
            // 2 == completedButton
            
            if self.currentHeaderButton == 0 {
                if self.pendingTasks.isEmpty {
                    self.showNoResultsFoundView()
                } else {
                    self.removeNoResultsView()
                }
            }
        }) { (error) in
            self.showNoResultsFoundView()
            print("UserProfileVC/fetchUsersTasks(): Error fetching user's tasks: ", error)
        }
    }
    
    // Fetch accepted tasks
    fileprivate func fetchAcceptedTasks(forUserId userId: String) {
        let acceptedTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.acceptedTasks).child(userId)
        acceptedTasksRef.observeSingleEvent(of: .value, with: { (snapshot1) in
            
            // Empty arrays and dictionaries to allow new values to be stored
            self.acceptedTasks.removeAll()
            self.acceptedJugglers.removeAll()
            
            if let dictionary = snapshot1.value as? [String: Any] {
                for task in self.allTasks {
                    dictionary.forEach({ (key, value) in
                        if let valueDictionary = value as? [String : Any], valueDictionary[task.id] != nil {
                            
                            // Append jugglers and accepted tasks simultaneously
                            // Can retrieve key for value when loading collectionView
                            if let _ = self.acceptedJugglers[key] {
                                self.acceptedJugglers[key]?.append(task)
                            } else {
                                self.acceptedJugglers[key] = [task]
                            }
                            
                            self.acceptedTasks.append(task)
                        }
                    })
                }
            } else {
                if self.currentHeaderButton == 1 {
                    self.showNoResultsFoundView()
                }
            }
            
            // Rearrange the acceptedTasks array to be from most recent to oldest
            self.acceptedTasks.sort(by: { (task1, task2) -> Bool in
                return task1.creationDate.compare(task2.creationDate) == .orderedDescending
            })
            
            if self.currentHeaderButton == 1 {
                if self.acceptedTasks.isEmpty {
                    self.showNoResultsFoundView()
                } else {
                    self.removeNoResultsView()
                }
            }
        }) { (error) in
            if self.currentHeaderButton == 1 {
                self.showNoResultsFoundView()
            }
            print("UserProfileVC/fetchUsersTasks(): Error fetching user's accepted tasks: ", error)
        }
    }
    
    // Fetch completed tasks
    fileprivate func fetchCompletedTasks(forUserId userId: String) {
        let completedTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.completedTasks).child(userId)
        completedTasksRef.observeSingleEvent(of: .value, with: { (snapshot1) in
            
            // Empty arrays and dictionaries to allow new values to be stored
            self.completedTasks.removeAll()
            self.completedJugglers.removeAll()
            
            if let dictionary = snapshot1.value as? [String: Any] {
                for task in self.allTasks {
                    dictionary.forEach({ (key, value) in
                        if let valueDictionary = value as? [String : Any], valueDictionary[task.id] != nil {
                            
                            // Append jugglers and accepted tasks simultaneously
                            // Can retrieve key for value when loading collectionView
                            if let _ = self.completedJugglers[key] {
                                self.completedJugglers[key]?.append(task)
                            } else {
                                self.completedJugglers[key] = [task]
                            }
                            
                            self.completedTasks.append(task)
                        }
                    })
                }
            } else {
                if self.currentHeaderButton == 2 {
                    self.showNoResultsFoundView()
                }
            }
            
            // Rearrange the completedTasks array to be from most recent to oldest
            self.completedTasks.sort(by: { (task1, task2) -> Bool in
                return task1.creationDate.compare(task2.creationDate) == .orderedDescending
            })
            
            if self.currentHeaderButton == 2 {
                if self.completedTasks.isEmpty {
                    self.showNoResultsFoundView()
                } else {
                    self.removeNoResultsView()
                }
            }
        }) { (error) in
            if self.currentHeaderButton == 1 {
                self.showNoResultsFoundView()
            }
            print("UserProfileVC/fetchUsersTasks(): Error fetching user's accepted tasks: ", error)
        }
    }
    
    //MARK: UserProfileHeaderCell Methods
    // Add section header for collectionView a supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CollectionViewCellIds.userProfileHeaderCell, for: indexPath) as? UserProfileHeader else { fatalError("Unable to dequeue UserProfileHeaderCell")}
        
        headerCell.delegate = self
        headerCell.user = self.user
        
        return headerCell
    }
    
    // Need to provide a size or the header will not render out
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 248)
    }
    
    //MARK: Collection view methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if currentHeaderButton == 0 {
            if self.pendingTasks.count == 0 {
                self.showNoResultsFoundView()
                return 0
            } else {
                self.removeNoResultsView()
                return self.pendingTasks.count
            }
        } else if currentHeaderButton == 1 {
            if self.acceptedJugglers.count == 0 {
                self.showNoResultsFoundView()
                return 0
            } else {
                self.removeNoResultsView()
                return self.acceptedTasks.count
            }
        } else {
            if self.completedTasks.count == 0 {
                self.showNoResultsFoundView()
                return 0
            } else {
                self.removeNoResultsView()
                return self.completedTasks.count
            }
        }
    }
    
    // What's the vertical spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if currentHeaderButton == 0 { // Use PendingTaskCell
            if self.pendingTasks.count >= indexPath.item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.pendingTaskCell, for: indexPath) as! PendingTaskCell
                
                cell.task = self.pendingTasks[indexPath.item]
                cell.profileImageView.loadImage(from: self.user?.profileImageURLString ?? "")
                cell.user = self.user
                
                return cell
            }
        } else if currentHeaderButton == 1 { // Use AcceptedTaskCell
            if self.acceptedTasks.count >= indexPath.item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.acceptedTaskCell, for: indexPath) as! AcceptedTaskCell
                
                let task = self.acceptedTasks[indexPath.item]
                
                // Match the correct task with the correct Juggler
                self.acceptedJugglers.forEach { (key, value) in
                    for val in value {
                        if task.id == val.id {
                            cell.jugglerId = key
                        }
                    }
                }
                
                cell.task = task
                
                return cell
            }
        } else if currentHeaderButton == 2 { // Use CompletedTaskCell
            if self.completedTasks.count >= indexPath.item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.completedTaskCell, for: indexPath) as! CompletedTaskCell
                
                let task = self.completedTasks[indexPath.item]
                
                // Match the correct task with the correct Juggler
                self.completedJugglers.forEach { (key, value) in
                    for val in value {
                        if task.id == val.id {
                            cell.jugglerId = key
                        }
                    }
                }
                
                // Cell's task property MUST be set before cell's isUser property
                cell.task = task
                cell.delegate = self
                cell.shouldShowReviews = true
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    fileprivate func display(alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: UserProfileHeaderCellDelegate methods
extension UserProfileVC: UserProfileHeaderCellDelegate {
    func toolBarValueChanged(fromButton button: Int) {
        if self.currentHeaderButton != button {
            self.currentHeaderButton = button
            self.collectionView.reloadData()
        }
    }
}

//MARK: CompleteTaskCellDelegate methods
extension UserProfileVC: CompleteTaskCellDelegate {
    func review(jugglerId: String?, forTask task: Task?) {
        guard let jugglerId = jugglerId, let task = task else {
            let alert = UIView.okayAlert(title: "Unable to Review Juggler", message: "We are currently unable to review this user. Please try again.")
            self.display(alert: alert)
            
            return
        }
        
        let reviewProfileVC = ReviewProfileVC()
        reviewProfileVC.jugglerId = jugglerId
        reviewProfileVC.task = task
        
        navigationController?.pushViewController(reviewProfileVC, animated: true)
    }
}
