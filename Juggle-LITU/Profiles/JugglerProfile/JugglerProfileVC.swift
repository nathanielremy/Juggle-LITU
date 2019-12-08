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
            
            if canFetchTasks && self.currentHeaderButton != 2 {
                //Empty all temp arrays to allow new values to be stored
                self.tempAcceptedTasks.removeAll()
                self.tempCompletedTasks.removeAll()
                
                self.fetchJuggerTasks(forJugglerId: jugglerId)
            } else if self.currentHeaderButton == 2 {
                //Empty all temp arrays to allow new values to be stored
                self.tempReviews.removeAll()
                
                self.fetchReviews(forJugglerId: jugglerId)
            }
        }
    }
    
    var rating: Double?
    var reviews = [Review]()
    var tempReviews = [Review]()
    
    var acceptedTasks = [Task]()
    var tempAcceptedTasks = [Task]()
    
    var completedTasks = [Task]()
    var tempCompletedTasks = [Task]()
    
    // currentHeaderButton values
    // 0 == acceptedButton
    // 1 == completedButton
    // 2 == reviewsButton
    var currentHeaderButton = 0
    var canFetchTasks = true
    
    // Display when first loading profile
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    func animateAndShowActivityIndicator(_ bool: Bool) {
        if bool {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }
    
    let noResultsView: UIView = {
        let view = UIView.noResultsView(withText: "No Results Found.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate func showNoResultsFoundView(andReload reload: Bool) {
        if reload {
            self.collectionView?.refreshControl?.endRefreshing()
            self.collectionView?.reloadData()
        }
        DispatchQueue.main.async {
            self.collectionView?.addSubview(self.noResultsView)
            self.noResultsView.centerYAnchor.constraint(equalTo: (self.collectionView?.centerYAnchor)!).isActive = true
            self.noResultsView.centerXAnchor.constraint(equalTo: (self.collectionView?.centerXAnchor)!).isActive = true
        }
    }
    
    fileprivate func removeNoResultsView() {
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.noResultsView.removeFromSuperview()
            self.collectionView?.reloadData()
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
        
        self.setupActivityIndicator()
        self.animateAndShowActivityIndicator(true)
        
        //Also fetch reviews when first time loading profile
        guard let jugglerId = Auth.auth().currentUser?.uid else { fatalError() }
        self.fetchReviews(forJugglerId: jugglerId)
    }
    
    fileprivate func setupActivityIndicator() {
        view.addSubview(self.activityIndicator)
        self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    // Re-fetch data when collection view is refreshed.
    @objc fileprivate func handleRefresh() {
        guard let jugglerId = self.juggler?.uid else { return }
        fetchJuggler(forJugglerId: jugglerId)
    }
    
    fileprivate func fetchJuggler(forJugglerId jugglerId: String) {
        Database.fetchJuggler(userID: jugglerId) { (usr) in
            if let juggler = usr, juggler.isJuggler {
                // After setting self.juggler, the Juggler's tasks and reviews get fetched
                self.juggler = juggler
                self.navigationItem.title = juggler.firstName + " " + juggler.lastName
            }
        }
    }
    
    // Retrieve tasks related to juggler
    fileprivate func fetchJuggerTasks(forJugglerId jugglerId: String) {
        if !canFetchTasks {
            return
        }
        
        self.canFetchTasks = false
        
        let tasksRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).queryOrdered(byChild: Constants.FirebaseDatabase.mutuallyAcceptedBy).queryEqual(toValue: jugglerId)
        tasksRef.observeSingleEvent(of: .value, with: { (tasksSnapshot) in
            
            guard let snapshotDictionary = tasksSnapshot.value as? [String : [String : Any]] else {
                self.acceptedTasks.removeAll()
                self.completedTasks.removeAll()
                self.canFetchTasks = true
                self.showNoResultsFoundView(andReload: true)
                self.animateAndShowActivityIndicator(false)
                return
            }
            
            var tasksCreated = 0
            snapshotDictionary.forEach { (taskId, taskDictionary) in
                let task = Task(id: taskId, dictionary: taskDictionary)
                tasksCreated += 1
                
                // task.status values
                // 0 == pendingButton
                // 1 == acceptedButton
                // 2 == completedButton
                if task.status == 1 { // Accepted
                    self.tempAcceptedTasks.append(task)
                } else if task.status == 2 { // Completed
                    self.tempCompletedTasks.append(task)
                }
                
                // Re-arrange all task arrays from youngest to oldest
                self.tempAcceptedTasks.sort(by: { (task1, task2) -> Bool in
                    return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                })
                self.tempCompletedTasks.sort(by: { (task1, task2) -> Bool in
                    return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                })
                
                if tasksCreated == snapshotDictionary.count {
                    self.acceptedTasks = self.tempAcceptedTasks
                    self.completedTasks = self.tempCompletedTasks
                    self.removeNoResultsView()
                    self.canFetchTasks = true
                    self.animateAndShowActivityIndicator(false)
                    return
                }
            }
        }) { (error) in
            self.acceptedTasks.removeAll()
            self.completedTasks.removeAll()
            self.showNoResultsFoundView(andReload: true)
            self.animateAndShowActivityIndicator(false)
            self.canFetchTasks = true
            print("Error fetching jugglerTasksRef: \(error)")
        }
    }
    
    fileprivate func fetchReviews(forJugglerId jugglerId: String) {
        if self.canFetchTasks || self.currentHeaderButton == 2 {
            self.showNoResultsFoundView(andReload: true)
        }
        print("Fetching Reviews... Not really 😂")
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
        // currentHeaderButton values
        // 0 == acceptedButton
        // 1 == completedButton
        // 2 == reviewsButton
        if currentHeaderButton == 0 {
            if self.acceptedTasks.count == 0 {
                self.showNoResultsFoundView(andReload: false)
                return 0
            } else {
                return self.acceptedTasks.count
            }
        } else if currentHeaderButton == 1 {
            if self.completedTasks.count == 0 {
                self.showNoResultsFoundView(andReload: false)
                return 0
            } else {
                return self.completedTasks.count
            }
        } else if currentHeaderButton == 2 {
            if self.reviews.count == 0 {
                self.showNoResultsFoundView(andReload: false)
                return 0
            } else {
                return self.reviews.count
            }
        }
        
        self.showNoResultsFoundView(andReload: false)
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
        self.noResultsView.removeFromSuperview()
        
        if self.currentHeaderButton != button {
            self.currentHeaderButton = button
            self.collectionView.reloadData()
        }
    }
}
