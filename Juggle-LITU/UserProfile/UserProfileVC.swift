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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .orange
        
        fetchUser()
    }
    
    fileprivate func fetchUser() {
        let userIdForFetch = Auth.auth().currentUser?.uid ?? ""
        
        Database.fetchUserFromUserID(userID: userIdForFetch) { (user) in
            if let user = user {
                self.user = user
                DispatchQueue.main.async {
                    self.navigationItem.title = user.fullName
                    self.user = user
                    self.setupSettingsBarButton()
                }
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
    
    fileprivate func display(alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
