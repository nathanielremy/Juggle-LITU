//
//  TaskCategoryPickerVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 09/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit

class TaskCategoryPickerVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(TaskCategoryCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.taskCategoryCell)
        
        setUpNavButtons()
    }
    
    //MARK: Collection View Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 75)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.TaskCategories.categoryArray().count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.taskCategoryCell, for: indexPath) as! TaskCategoryCell
        
        cell.categoryTitle = Constants.TaskCategories.categoryArray()[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let taskSpecificationsVC = TaskSpecificationsVC()
        taskSpecificationsVC.taskCategory = Constants.TaskCategories.categoryArray()[indexPath.item]
        navigationController?.pushViewController(taskSpecificationsVC, animated: true)
    }
    
    fileprivate func setUpNavButtons() {
        navigationItem.title = "Category"
    }
}
