//
//  MainTabBarController.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 09/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if Auth.auth().currentUser == nil {
            // Show LogInVC if user is not signed in
            DispatchQueue.main.async {
                let logInVC = LoginVC()
                let navController = UINavigationController(rootViewController: logInVC)
                self.present(navController, animated: true, completion: nil)
                return
            }
        } else {
            // Set up TabBarViewControllers if user is signed in
            setupViewControllers()
        }
    }
    
    func setupViewControllers() {
        // User profile
        let userNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_unselected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // Messages VC
        let messagesNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "comment"), selectedImage: #imageLiteral(resourceName: "comment"), rootViewController: MessagesVC())
        
        // TaskCategoryPicker VC
        let taskCategoryNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: TaskCategoryPickerVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        tabBar.tintColor = UIColor.mainBlue()
        self.viewControllers = [
            taskCategoryNavController,
            messagesNavController,
            userNavController
        ]
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let vC = rootViewController
        let navVC = UINavigationController(rootViewController: vC)
        navVC.tabBarItem.image = unselectedImage
        navVC.tabBarItem.selectedImage = selectedImage
        
        return navVC
    }
}
