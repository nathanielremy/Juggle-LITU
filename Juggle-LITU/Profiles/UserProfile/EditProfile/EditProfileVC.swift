//
//  EditProfileVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 24/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Stored properties
    //MARK: Stored properties
    var profileImageDidChanged = false
    var profileImageUpdated = true
    
    var fullNameDidChange = false
    var fullNameUpdated = true
    
    var user: User? {
        didSet {
            guard let user = user else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            profileImageView.loadImage(from: user.profileImageURLString)
            fullNameTextField.text = user.fullName
        }
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = true
        sv.backgroundColor = .white
        
        return sv
    }()
    
    lazy var profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.backgroundColor = .lightGray
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.mainBlue().cgColor
        image.layer.borderWidth = 1.5
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImage)))
        
        return image
    }()
    
    //Present the imagePicker
    @objc fileprivate func handleProfileImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // Set the selected image from image picker as profile picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profileImageView.image = editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            profileImageView.image = originalImage.withRenderingMode(.alwaysOriginal)
        }
        
        self.profileImageDidChanged = true
        self.profileImageUpdated = false
        
        // Dismiss image picker view
        picker.dismiss(animated: true, completion: nil)
    }
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Name:"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        
        return label
    }()
    
    lazy var fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChanges), for: .editingChanged)
        
        return tf
    }()
    
    @objc fileprivate func handleTextFieldChanges() {
        if fullNameTextField.text == self.user?.fullName {
            self.fullNameDidChange = false
        } else {
            self.fullNameDidChange = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Edit Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 100)
        
        scrollView.addSubview(profileImageView)
        profileImageView.anchor(top: scrollView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 100/2
        
        scrollView.addSubview(fullNameLabel)
        fullNameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 90, height: 50)
        
        scrollView.addSubview(fullNameTextField)
        fullNameTextField.anchor(top: profileImageView.bottomAnchor, left: fullNameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        fullNameTextField.centerYAnchor.constraint(equalTo: fullNameLabel.centerYAnchor).isActive = true
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .black
        
        scrollView.addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: fullNameTextField.leftAnchor, bottom: fullNameTextField.bottomAnchor, right: fullNameTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
        
        scrollView.addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc fileprivate func handleDone() {
        self.disableAndAnimate(bool: true)
        
        if profileImageDidChanged && fullNameDidChange {
            updateProfileImage()
            updateFullName()
        } else if profileImageDidChanged {
            updateProfileImage()
        } else if fullNameDidChange {
            updateFullName()
        } else {
            self.disableAndAnimate(bool: false)
            navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func updateFullName() {
        guard let user = self.user, let fullName = fullNameTextField.text else {
            self.fullNameUpdated = true
            self.verifyFinish()
            return
        }
        
        let values: [String : Any] = [Constants.FirebaseDatabase.fullName : fullName]
        
        let databaseRef = Database.database().reference().child(Constants.FirebaseDatabase.usersRef).child(user.uid)
        databaseRef.updateChildValues(values) { (err, _) in
            if let error = err {
                print("Error updating user's fullName: ", error)
                self.fullNameUpdated = true
                self.verifyFinish()
                return
            }
            
            self.fullNameUpdated = true
            self.verifyFinish()
        }
    }
    
    fileprivate func updateProfileImage() {
        guard let user = self.user else {
            self.profileImageUpdated = true
            self.verifyFinish()
            return
        }
        
        let imageRef = Storage.storage().reference(forURL: user.profileImageURLString)
        imageRef.delete { (err) in
            if let error = err {
                print("Error deleting profileImage from storage: ", error)
                self.profileImageUpdated = true
                self.verifyFinish()
                return
            }
            
            guard let newImage = self.profileImageView.image, let imageData = newImage.jpegData(compressionQuality: 0.2) else {
                self.profileImageUpdated = true
                self.verifyFinish()
                return
            }
            
            // create a random file name to add profile image to Firebase storage
            let randomFile = UUID().uuidString
            let storageRef = Storage.storage().reference().child(Constants.FirebaseStorage.profileImages).child(randomFile)
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, err) in
                if let error = err {
                    print("Error uploading image to Firebase storage: ", error)
                    self.profileImageUpdated = true
                    self.verifyFinish()
                    return
                }
                
                guard let profileImageURLString = metadata?.downloadURL()?.absoluteString else {
                    print("Could not return profileImageURL from storage")
                    self.profileImageUpdated = true
                    self.verifyFinish()
                    return
                }
                
                let values: [String : Any] = [Constants.FirebaseDatabase.profileImageURLString : profileImageURLString]
                
                let databaseRef = Database.database().reference().child(Constants.FirebaseDatabase.usersRef).child(user.uid)
                databaseRef.updateChildValues(values, withCompletionBlock: { (err, _) in
                    if let error = err {
                        print("Could not update profileImageURL value in database: ", error)
                        self.profileImageUpdated = true
                        self.verifyFinish()
                        return
                    }
                })
                
                self.profileImageUpdated = true
                self.verifyFinish()
            })
        }
    }
    
    fileprivate func verifyFinish() {
        
        if let userId = self.user?.uid {
            userCache.removeValue(forKey: userId)
        }
        
        if profileImageUpdated && fullNameUpdated {
            self.disableAndAnimate(bool: false)
            navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func disableAndAnimate(bool: Bool) {
        if bool {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        
        scrollView.isUserInteractionEnabled = !bool
        profileImageView.isUserInteractionEnabled = !bool
        fullNameTextField.isUserInteractionEnabled = !bool
    }
}

extension EditProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
