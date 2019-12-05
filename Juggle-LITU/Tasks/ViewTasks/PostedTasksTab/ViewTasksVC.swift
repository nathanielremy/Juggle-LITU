//
//  ViewTasksVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 2019-10-19.
//  Copyright © 2019 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class ViewTasksVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: Stored properties
    var currentCategory = Constants.TaskCategories.all
    
    var allTasks = [Task]()
    var tempAllTasks = [Task]()
    
    var filteredTasks = [Task]()
    var tempFilteredTask = [Task]()
    
    var canFetchTasks = true
    
    
    let noResultsView: UIView = {
        let view = UIView.noResultsView(withText: "No Tasks at the Moment.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // Display while changing categories
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Offers"
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        
        // Register all collection view cells
        collectionView?.register(ChooseTaskCategoryHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.ChooseTaskCategoryHeaderCell)
        collectionView?.register(TaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.taskCell)
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.tintColor = UIColor.mainBlue()
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshController
        setupActivityIndicator()
        animateAndShowActivityIndicator(true)
        
        queryAllTasksByDate()
    }
    
    fileprivate func setupActivityIndicator() {
        view.addSubview(self.activityIndicator)
        self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc fileprivate func handleRefresh() {
        if !canFetchTasks {
            return
        }
        
        self.tempAllTasks.removeAll()
        self.tempFilteredTask.removeAll()
        
        if self.currentCategory == Constants.TaskCategories.all {
            queryAllTasksByDate()
        } else {
            self.fetchFilteredTasksFor(category: self.currentCategory)
        }
    }
    
    fileprivate func queryAllTasksByDate() {
        if !canFetchTasks {
            return
        }
        
        self.canFetchTasks = false
        
        let databaseRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef)
        var query = databaseRef.queryOrdered(byChild: Constants.FirebaseDatabase.creationDate)
        
        if self.tempAllTasks.count > 0 {
            let value = self.tempAllTasks.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let tasksJSON = dataSnapshot.value as? [String : [String : Any]] else {
                self.filteredTasks.removeAll()
                self.allTasks.removeAll()
                self.showNoResultsFoundView()
                self.canFetchTasks = true
                self.animateAndShowActivityIndicator(false)
                return
            }
            
            var tasksCreated = 0
            tasksJSON.forEach { (taskId, taskDictionary) in
                let task = Task(id: taskId, dictionary: taskDictionary)
                
                tasksCreated += 1
                
                if task.status == 0 {
                    self.tempAllTasks.append(task)
                }
                
                self.tempAllTasks.sort(by: { (task1, task2) -> Bool in
                    return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                })
                
                if tasksCreated == tasksJSON.count {
                    self.allTasks = self.tempAllTasks
                    self.removeNoResultsView()
                    self.canFetchTasks = true
                    self.animateAndShowActivityIndicator(false)
                    return
                }
            }
        }) { (error) in
            self.showNoResultsFoundView()
            print("queryAllTasksByDate(): Error fetching tasks: ", error)
        }
    }
    
    fileprivate func fetchFilteredTasksFor(category: String) {
        if !canFetchTasks {
            return
        }
        
        self.canFetchTasks = false
        
        let query = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).queryOrdered(byChild: Constants.FirebaseDatabase.taskCategory).queryEqual(toValue: category)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let tasksJSON = snapshot.value as? [String : [String : Any]] else {
                self.filteredTasks.removeAll()
                self.allTasks.removeAll()
                self.showNoResultsFoundView()
                self.canFetchTasks = true
                self.animateAndShowActivityIndicator(false)
                return
            }
            
            var tasksCreated = 0
            tasksJSON.forEach { (taskId, taskDictionary) in
                let task = Task(id: taskId, dictionary: taskDictionary)
                
                tasksCreated += 1
                
                if task.status == 0 {
                    self.tempFilteredTask.append(task)
                }
                
                self.tempFilteredTask.sort(by: { (task1, task2) -> Bool in
                    return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                })
                
                if tasksCreated == tasksJSON.count {
                    self.filteredTasks = self.tempFilteredTask
                    self.removeNoResultsView()
                    self.canFetchTasks = true
                    self.animateAndShowActivityIndicator(false)
                    return
                }
            }
        }) { (error) in
            self.showNoResultsFoundView()
            self.animateAndShowActivityIndicator(false)
            print("fetchFilteredTasksFor(category \(category): Error fetching tasks: ", error)
        }
    }
    
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
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.noResultsView.removeFromSuperview()
            self.collectionView?.reloadData()
        }
    }
    
    //MARK: UserProfileHeaderCell Methods
    // Add section header for collectionView a supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CollectionViewCellIds.ChooseTaskCategoryHeaderCell, for: indexPath) as? ChooseTaskCategoryHeaderCell else { fatalError("Unable to dequeue UserProfileHeaderCell")}
        
        headerCell.delegate = self
        headerCell.scrollView.flashScrollIndicators()
        
        return headerCell
    }
    
    // Need to provide a size or the header will not render out
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 50)
    }
    
    //MARK: CollectionView methods
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.taskCell, for: indexPath) as! TaskCell
        
        if self.currentCategory == Constants.TaskCategories.all {
            if self.allTasks.count >= indexPath.item {
                cell.task = self.allTasks[indexPath.item]
            }
        } else {
            if self.filteredTasks.count >= indexPath.item {
                cell.task = self.filteredTasks[indexPath.item]
            }
        }
        
        //Fetch again more tasks if collectionView hits bottom
        if indexPath.item == self.allTasks.count - 1 {
            if self.currentCategory == Constants.TaskCategories.all {
                self.queryAllTasksByDate()
            }
        }
        
        return cell
    }
    
    // What's the vertical spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.currentCategory == Constants.TaskCategories.all {
            return self.allTasks.count
        } else {
            return self.filteredTasks.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 110)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let taskDetailsVC = TaskDetailsVC()
        
        var chosenTask: Task?
        
        if self.currentCategory == Constants.TaskCategories.all {
            let task = self.allTasks[indexPath.item]
            chosenTask = task
        } else {
            let task = self.filteredTasks[indexPath.item]
            chosenTask = task
        }
        
        guard let selectedTask = chosenTask else {
            let alert = UIView.okayAlert(title: "Unable to load task", message: "This task is currently unavailable. Please try again.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        taskDetailsVC.task = selectedTask
        
        self.navigationController?.pushViewController(taskDetailsVC, animated: true)
    }
}

extension ViewTasksVC: ChooseTaskCategoryHeaderCellDelegate {
    func didChangeCategory(to category: String) {
        if category == self.currentCategory {
            return
        }
        
        self.animateAndShowActivityIndicator(true)
        
        self.currentCategory = category
        self.filteredTasks.removeAll()
        self.collectionView.reloadData()
        
        if category == Constants.TaskCategories.all {
            self.queryAllTasksByDate()
        } else {
            self.fetchFilteredTasksFor(category: category)
        }
    }
}
