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
    var filteredTasks = [Task]()
    
    let noResultsView: UIView = {
        let view = UIView.noResultsView(withText: "No Tasks at the Moment.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
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
        
        fetchTaskFor(category: self.currentCategory)
    }
    
    @objc fileprivate func handleRefresh() {
        self.filteredTasks.removeAll()
        self.allTasks.removeAll()
        fetchTaskFor(category: self.currentCategory)
    }
    
    fileprivate func fetchTaskFor(category: String) {
        let databaseRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef)
        databaseRef.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let snapshotDictionary = dataSnapshot.value as? [String : Any] else {
                self.showNoResultsFoundView()
                print("fetchUserTasks(): Unable to convert to [String:Any]"); return
            }
            
            snapshotDictionary.forEach({ (_, values) in
                guard let value = values as? [String : Any] else {
                    self.showNoResultsFoundView()
                    
                    return
                }
                value.forEach({ (key, value) in
                    guard let dictionary = value as? [String : Any] else {
                        self.showNoResultsFoundView()
                        return
                    }
                    let task = Task(id: key, dictionary: dictionary)
                    
                    // Status of 0 means that the task is pending
                    // Status of 1 means that the task has been accepted
                    // Status of 2 means that the task is completed
                    if task.status == 0 {
                        self.allTasks.append(task)
                    }
                    // Rearrange the tasks array to be from most recent to oldest
                    self.allTasks.sort(by: { (task1, task2) -> Bool in
                        return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                    })
                })
            })
            
            if self.allTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            } else {
                if self.currentCategory == Constants.TaskCategories.all {
                    self.removeNoResultsView()
                } else {
                    self.filterTasksFor(category: self.currentCategory)
                }
            }
        }) { (error) in
            self.showNoResultsFoundView()
            print("fetchTaskFor(category: String): Error fetching tasks: ", error)
        }
    }
    
    fileprivate func filterTasksFor(category: String) {
        if category == Constants.TaskCategories.all {
            self.removeNoResultsView()
            return
        }
        
        for task in self.allTasks {
            if task.category == category {
                self.filteredTasks.append(task)
                // Rearrange the tasks array to be from most recent to oldest
                self.filteredTasks.sort(by: { (task1, task2) -> Bool in
                    return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                })
            }
        }
        
        if self.filteredTasks.isEmpty {
            self.showNoResultsFoundView()
        } else {
            self.removeNoResultsView()
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
        self.currentCategory = category
        self.filteredTasks.removeAll()
        self.filterTasksFor(category: category)
    }
}
