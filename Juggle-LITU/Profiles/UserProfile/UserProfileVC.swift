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
    var acceptedTasks = [String : Task]()
    var completedTasks = [String : Task]()
    
    var currentHeaderButton = 0
    
    let noResultsView: UIView = {
        let view = UIView.noResultsView(withText: "You Currently Have no Tasks.")
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
        
        collectionView?.alwaysBounceVertical = true
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshController
        
        fetchUser()
    }
    
    @objc fileprivate func handleRefresh() {
        fetchUser()
    }
    
    //Fetch user to populate UI and fetch appropriate data.
    fileprivate func fetchUser() {
        let userIdForFetch = Auth.auth().currentUser?.uid ?? ""
        
        Database.fetchUserFromUserID(userID: userIdForFetch) { (user) in
            if let user = user {
                self.user = user
                self.fetchUsersTasks()
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
    fileprivate func fetchUsersTasks() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("UserProfileVC/fetchTasks: No userId")
            return
        }
        
        let tasksRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(userId)
        tasksRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let snapshotDictionary = snapshot.value as? [String : Any] else {
                self.allTasks.removeAll()
                self.showNoResultsFoundView()
                return
            }
            
            self.allTasks.removeAll()
            self.pendingTasks.removeAll()
            self.acceptedTasks.removeAll()
            self.completedTasks.removeAll()
            
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
            } else {
                self.showNoResultsFoundView()
            }
        }) { (error) in
            self.showNoResultsFoundView()
            print("UserProfileVC/fetchUsersTasks(): Error fetching user's tasks: ", error)
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
        
        // REMEMBER to show noResultsView if array.count == 0
        self.removeNoResultsView()
        
        if currentHeaderButton == 0 {
            if self.pendingTasks.count == 0 {
                self.showNoResultsFoundView()
                return 0
            } else {
                return self.pendingTasks.count
            }
        } else {
            return self.allTasks.count
        }
    }
    
    // What's the vertical spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if currentHeaderButton == 0 {
            if self.pendingTasks.count >= indexPath.item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.pendingTaskCell, for: indexPath) as! PendingTaskCell
                cell.task = self.pendingTasks[indexPath.item]
                cell.profileImageView.loadImage(from: self.user?.profileImageURLString ?? "")
                return cell
            }
        } else {
            if self.allTasks.count >= indexPath.item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.pendingTaskCell, for: indexPath) as! PendingTaskCell
                cell.task = self.allTasks[indexPath.item]
                cell.profileImageView.loadImage(from: self.user?.profileImageURLString ?? "")
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

extension UserProfileVC: UserProfileHeaderCellDelegate {
    func toolBarValueChanged(fromButton button: Int) {
        self.currentHeaderButton = button
        self.collectionView.reloadData()
    }
}
