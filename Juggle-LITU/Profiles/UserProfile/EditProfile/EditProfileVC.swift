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
    var profileImageDidChanged = false
    var profileImageUpdated = true
    
    var firstNameDidChange = false
    var firstNameUpdated = true
    
    var lastNameDidChange = false
    var lastNameUpdated = true
    
    var user: User? {
        didSet {
            guard let user = user else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            profileImageView.loadImage(from: user.profileImageURLString)
            firstNameTextField.text = user.firstName
            lastNameTextField.text = user.lastName
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
    
    let firstNameLabel: UILabel = {
        let label = UILabel()
        label.text = "First Name:"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        
        return label
    }()
    
    let lastNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Last Name:"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        
        return label
    }()
    
    lazy var firstNameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChanges), for: .editingChanged)
        
        return tf
    }()
    
    lazy var lastNameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChanges), for: .editingChanged)
        
        return tf
    }()
    
    @objc fileprivate func handleTextFieldChanges() {
        if firstNameTextField.text == self.user?.firstName {
            self.firstNameDidChange = false
        } else {
            self.firstNameDidChange = true
        }
        
        if lastNameTextField.text == self.user?.lastName {
            self.lastNameDidChange = false
        } else {
            self.lastNameDidChange = true
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
        
        scrollView.addSubview(firstNameLabel)
        firstNameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 90, height: 50)
        
        scrollView.addSubview(firstNameTextField)
        firstNameTextField.anchor(top: profileImageView.bottomAnchor, left: firstNameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        firstNameTextField.centerYAnchor.constraint(equalTo: firstNameLabel.centerYAnchor).isActive = true
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .black
        
        scrollView.addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: firstNameTextField.leftAnchor, bottom: firstNameTextField.bottomAnchor, right: firstNameTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
        
        scrollView.addSubview(lastNameLabel)
        lastNameLabel.anchor(top: firstNameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 90, height: 50)
        
        scrollView.addSubview(lastNameTextField)
        lastNameTextField.anchor(top: firstNameTextField.bottomAnchor, left: lastNameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        lastNameTextField.centerYAnchor.constraint(equalTo: lastNameLabel.centerYAnchor).isActive = true

        let seperatorView2 = UIView()
        seperatorView2.backgroundColor = .black

        scrollView.addSubview(seperatorView2)
        seperatorView2.anchor(top: nil, left: lastNameTextField.leftAnchor, bottom: lastNameTextField.bottomAnchor, right: lastNameTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
        
        scrollView.addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc fileprivate func handleDone() {
        self.disableAndAnimate(bool: true)
        
        if !profileImageDidChanged && !firstNameDidChange && !lastNameDidChange {
            self.disableAndAnimate(bool: false)
            navigationController?.popViewController(animated: true)
        }
        
        if profileImageDidChanged {
            updateProfileImage()
        }
        
        if firstNameDidChange {
            updateFirstName()
        }
        
        if lastNameDidChange {
            updateLastName()
        }
    }
    
    fileprivate func updateFirstName() {
        guard let user = self.user, let firstName = firstNameTextField.text else {
            self.firstNameUpdated = true
            self.verifyFinish()
            return
        }

        let values: [String : Any] = [Constants.FirebaseDatabase.firstName : firstName]

        let databaseRef = Database.database().reference().child(Constants.FirebaseDatabase.usersRef).child(user.uid)
        databaseRef.updateChildValues(values) { (err, _) in
            if let error = err {
                print("Error updating user's firstName: ", error)
                self.firstNameUpdated = true
                self.verifyFinish()
                return
            }

            self.firstNameUpdated = true
            self.verifyFinish()
        }
    }
    
    fileprivate func updateLastName() {
        guard let user = self.user, let lastName = lastNameTextField.text else {
            self.lastNameUpdated = true
            self.verifyFinish()
            return
        }
        
        let values: [String : Any] = [Constants.FirebaseDatabase.lastName : lastName]
        
        let databaseRef = Database.database().reference().child(Constants.FirebaseDatabase.usersRef).child(user.uid)
        databaseRef.updateChildValues(values) { (err, _) in
            if let error = err {
                print("Error updating user's lastName: ", error)
                self.firstNameUpdated = true
                self.verifyFinish()
                return
            }
            
            self.firstNameUpdated = true
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
        
        if profileImageUpdated && firstNameUpdated && lastNameUpdated {
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
        firstNameTextField.isUserInteractionEnabled = !bool
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
