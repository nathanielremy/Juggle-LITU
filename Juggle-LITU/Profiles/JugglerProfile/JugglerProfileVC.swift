//
//  JugglerProfileVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 15/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class JugglerProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: Stored properties
    var juggler: User? {
        didSet {
            guard let jugglerId = juggler?.uid else {
                print("JugglerProfileVC: No jugglerId")
                return
            }
            
            self.fetchJuggler(forJugglerId: jugglerId)
        }
    }
    
    var reviews = [Review]()
    var rating: Double?
    
    var acceptedTasks = [Task]()
    var completedTasks = [Task]()
    
    // currentHeaderButton values
    // 0 == acceptedButton
    // 1 == completedButton
    // 2 == reviewsButton
    var currentHeaderButton = 0
    var canFetchTasks = true
    
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
        collectionView?.register(JugglerProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.jugglerProfileHeaderCell)
        collectionView.register(AcceptedTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.acceptedTaskCell)
        collectionView.register(CompletedTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.completedTaskCell)
        collectionView.register(ReviewCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.reviewCell)
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.tintColor = UIColor.mainBlue()
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshController
    }
    
    // Re-fetch data when collection view is refreshed.
    @objc fileprivate func handleRefresh() {
        guard let jugglerId = self.juggler?.uid else { return }
        fetchJuggler(forJugglerId: jugglerId)
    }
    
    fileprivate func fetchJuggler(forJugglerId jugglerId: String) {
        Database.fetchJuggler(userID: jugglerId) { (jglr) in
            if let juggler = jglr {
                self.navigationItem.title = juggler.firstName + " " + juggler.lastName
                self.fetchJuggerTasks(forJugglerId: juggler.uid)
                self.collectionView.reloadData()
            }
        }
    }
    
    // Retrieve tasks related to juggler
    fileprivate func fetchJuggerTasks(forJugglerId jugglerId: String) {
        if !canFetchTasks {
            return
        }
        
        self.canFetchTasks = false
        
        let jugglerTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.jugglerTasks).child(jugglerId)
        jugglerTasksRef.observeSingleEvent(of: .value, with: { (jugglerTasks) in
            
            guard let userTasks = jugglerTasks.value as? [String : Any], let userTasksDictionary = userTasks as? [String : [String : Any]] else {
                self.acceptedTasks.removeAll()
                self.completedTasks.removeAll()
                self.showNoResultsFoundView()
                self.canFetchTasks = true
                return
            }
            
            self.fetchTasksForIds(tasksDictionary: userTasksDictionary)
            
        }) { (error) in
            self.acceptedTasks.removeAll()
            self.completedTasks.removeAll()
            self.showNoResultsFoundView()
            self.canFetchTasks = true
            print("Error fetching jugglerTasksRef: \(error)")
        }
    }
    
    fileprivate func fetchTasksForIds(tasksDictionary: [String : [String : Any]]) {
        
        var tempAcceptedTasks = [Task]()
        var tempCompletedTasks = [Task]()
        
        var fetchedUsersCount = 0
        let usersTasksToFetch = tasksDictionary.count
        
        tasksDictionary.forEach { (userId, taskIds) in
            var fetchedTasksCount = 0
            let tasksToFetch = taskIds.count
            taskIds.forEach { (key, _) in
                let taskRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(userId).child(key)
                taskRef.observeSingleEvent(of: .value, with: { (taskJSON) in
                    
                    guard let taskDictionary = taskJSON.value as? [String : Any] else {
                        print("What to do here?"); return
                    }
                    
                    let task = Task(id: key, dictionary: taskDictionary)
                    
                    if task.status == 1 {
                        tempAcceptedTasks.append(task)
                    } else if task.status == 2 {
                        tempCompletedTasks.append(task)
                    }
                    
                    // Rearrange arrays to be from most recent to oldest
                    tempAcceptedTasks.sort(by: { (task1, task2) -> Bool in
                        return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                    })
                    tempCompletedTasks.sort(by: { (task1, task2) -> Bool in
                        return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                    })
                    
                    fetchedTasksCount += 1
                    if fetchedTasksCount == tasksToFetch {
                        fetchedUsersCount += 1
                        if fetchedUsersCount == usersTasksToFetch {
                            self.acceptedTasks = tempAcceptedTasks
                            self.completedTasks = tempCompletedTasks
                            self.removeNoResultsView()
                            self.canFetchTasks = true
                        }
                    }
                }) { (error) in
                    self.acceptedTasks.removeAll()
                    self.completedTasks.removeAll()
                    self.showNoResultsFoundView()
                    self.canFetchTasks = true
                    print("Error fetching jugglerTasksForIds: \(error)")
                }
            }
        }
    }
    
    fileprivate func fetchReviews(forJugglerId jugglerId: String) {
        let reviewsRef = Database.database().reference().child(Constants.FirebaseDatabase.reviewsRef).child(jugglerId)
        reviewsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.reviews.removeAll()
            
            guard let dictionary = snapshot.value as? [String : Any] else {
                self.rating = 0
                if self.currentHeaderButton == 2 {
                    self.showNoResultsFoundView()
                }
                print("fetchReviews(): Unable to convert to [String:Any]"); return
            }
            
            self.reviews.removeAll()
            
            dictionary.forEach({ (key, value) in
                guard let reviewDictionary = value as? [String : Any] else {
                    if self.currentHeaderButton == 2 {
                        self.showNoResultsFoundView()
                    }
                    return
                }
                
                let review = Review(id: key, dictionary: reviewDictionary)
                self.reviews.append(review)
                
                // Rearrange the reviews array to be from most recent to oldest
                self.reviews.sort(by: { (review1, review2) -> Bool in
                    return review1.creationDate.compare(review2.creationDate) == .orderedDescending
                })
            })
            
            if self.reviews.isEmpty {
                self.rating = 0
                
                if self.currentHeaderButton == 2 {
                    self.showNoResultsFoundView()
                }
                
                return
            }
            
            self.calculateRating()
            
        }) { (error) in
            print("JugglerProfileVC/FetchReviews() Error: ", error)
            if self.currentHeaderButton == 2 {
                self.showNoResultsFoundView()
            }
        }
    }
    
    func calculateRating() {
        var totalStars: Double = 0
        
        for review in self.reviews {
            totalStars += Double(review.intRating)
        }
        
        let outOfFive = Double(totalStars/Double(reviews.count))
        self.rating = outOfFive
        
        DispatchQueue.main.async {
            self.removeNoResultsView()
        }
    }
    
    //MARK: UserProfileHeaderCell Methods
    // Add section header for collectionView a supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CollectionViewCellIds.jugglerProfileHeaderCell, for: indexPath) as? JugglerProfileHeaderCell else { fatalError("Unable to dequeue UserProfileHeaderCell")}
        
        headerCell.juggler = self.juggler
        headerCell.delegate = self
        headerCell.rating = self.rating
        
        return headerCell
    }
    
    // Need to provide a size or the header will not render out
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 265)
    }
    
    //MARK: CollectionView cell methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if currentHeaderButton == 0 {
            if self.acceptedTasks.count == 0 {
                self.showNoResultsFoundView()
                return 0
            } else {
                self.removeNoResultsView()
                return self.acceptedTasks.count
            }
        } else if currentHeaderButton == 1 {
            if self.completedTasks.count == 0 {
                self.showNoResultsFoundView()
                return 0
            } else {
                self.removeNoResultsView()
                return self.completedTasks.count
            }
        } else if currentHeaderButton == 2 {
            if self.reviews.count == 0 {
                self.showNoResultsFoundView()
                return 0
            } else {
                self.removeNoResultsView()
                return self.reviews.count
            }
        }
        
        self.showNoResultsFoundView()
        return 0
    }
    
    // What's the vertical spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if currentHeaderButton == 0 { // Accepted tasks
            if self.acceptedTasks.count >= indexPath.item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.acceptedTaskCell, for: indexPath) as! AcceptedTaskCell
                
                let task = self.acceptedTasks[indexPath.item]
                
                cell.userId = task.userId
                cell.task = task
                
                return cell
            }
        } else if currentHeaderButton == 1 { // Completed tasks
            if self.completedTasks.count >= indexPath.item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.completedTaskCell, for: indexPath) as! CompletedTaskCell
                
                let task = self.completedTasks[indexPath.item]
                
                cell.userId = task.userId
                cell.task = task
                
                return cell
            }
        } else if currentHeaderButton == 2 { // Reviews
            if self.reviews.count >= indexPath.item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.reviewCell, for: indexPath) as! ReviewCell
                
                cell.review = self.reviews[indexPath.item]
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.currentHeaderButton == 2 {
            var height: CGFloat = 80
            let review = self.reviews[indexPath.item].reviewString
            
            height = self.estimatedFrameForReviewCell(fromText: review).height + 55
            
            if height < 101 {
                return CGSize(width: view.frame.width, height: 110)
            } else {
                return CGSize(width: view.frame.width, height: height)
            }
        } else {
            
            return CGSize(width: view.frame.width, height: 100)
        }
    }
    
    fileprivate func estimatedFrameForReviewCell(fromText text: String) -> CGRect {
        //Height must be something really tall and width is the same as chatBubble in ChatMessageCell
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedTask: Task?
        
        if currentHeaderButton == 0 { // Accpeted tasks
            selectedTask = self.acceptedTasks[indexPath.item]
        } else if currentHeaderButton == 1 {
            selectedTask = self.completedTasks[indexPath.item]
        } else {
            return
        }
        
        guard let task = selectedTask else { return }
        
        let taskDetailsVC = TaskDetailsVC()
        taskDetailsVC.task = task
        
        navigationController?.pushViewController(taskDetailsVC, animated: true)
    }
    
    fileprivate func display(alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension JugglerProfileVC: JugglerProfileHeaderCellDelegate {
    func toolBarValueChanged(fromButton button: Int) {
        if self.currentHeaderButton != button {
            self.currentHeaderButton = button
            self.collectionView.reloadData()
        }
    }
}
