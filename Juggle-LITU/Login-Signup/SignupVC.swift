//
//  SignupVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 07/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class SignupVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Stored properties
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = true
        sv.backgroundColor = .white
        
        return sv
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        
        return ai
    }()
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.tintColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        
        return button
    }()
    
    // Present the image picker
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // Set the selected image from image picker as profile picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        // Make button perfectly round
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.mainBlue().cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        // Dismiss image picker view
        picker.dismiss(animated: true, completion: nil)
    }
    
    lazy var firstNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "First Name"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChanges), for: .editingChanged)
        
        return tf
    }()
    
    lazy var lastNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Last Name"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChanges), for: .editingChanged)
        
        return tf
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email Address"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChanges), for: .editingChanged)
        
        return tf
    }()
    
    lazy var passwordOneTextField: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.placeholder = "Password (atleast 6 characters)"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChanges), for: .editingChanged)
        
        return tf
    }()
    
    lazy var passwordTwoTextField: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.placeholder = "Re-enter Password"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChanges), for: .editingChanged)
        
        return tf
    }()
    
    @objc func handleTextFieldChanges() {
        
        let isFormValid = verifyInputFields()
        if isFormValid {
            self.signUpButton.isEnabled = true
            self.signUpButton.backgroundColor = UIColor.mainBlue().withAlphaComponent(1)
        } else {
            self.signUpButton.isEnabled = false
            self.signUpButton.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.3)
        }
    }
    
    fileprivate func verifyInputFields() -> Bool {
        guard firstNameTextField.text?.count ?? 0 > 0 else { return false }
        guard lastNameTextField.text?.count ?? 0 > 0 else { return false }
        guard emailTextField.text?.count ?? 0 > 0 else { return false }
        guard passwordOneTextField.text?.count ?? 0 > 5 else { return false }
        guard passwordTwoTextField.text?.count ?? 0 > 5 else { return false }
        guard termsAndConditionsSwitch.isOn else { return false }
        
        return true
    }
    
    lazy var termsAndConditionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        
        var attributedText = NSMutableAttributedString(string: "Accept ", attributes: [.foregroundColor : UIColor.lightGray])
        attributedText.append(NSAttributedString(string: "Terms and Conditions", attributes: [.foregroundColor : UIColor.mainBlue()]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(handleTermsAndConditions), for: .touchUpInside)
        
        return button
    }()
    
    lazy var termsAndConditionsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.tintColor = UIColor.mainBlue()
        toggle.onTintColor = UIColor.mainBlue()
        toggle.addTarget(self, action: #selector(handleTextFieldChanges), for: .valueChanged)
        
        return toggle
    }()
    
    @objc fileprivate func handleTermsAndConditions() {
        let termsAndConditionsVC = TermsAndConditionsVC()
        let navigationController = UINavigationController(rootViewController: termsAndConditionsVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.3)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    @objc fileprivate func handleSignup() {
        disableAndAnimate(true)
        
        if !verifyInputFields() {
            disableAndAnimate(false)
            self.display(alert: UIView.okayAlert(title: "Invalid Forms", message: "Please re-enter your information in the textfields and try again."))
            return
        }
        
        guard let textFields = approveInputFields() else {
            self.disableAndAnimate(false)
            return
        }
        
        Auth.loginUser(withEmail: textFields.email, passcode: textFields.password) { (usr, err) in
            if let _ = usr {
                let alert = UIView.okayAlert(title: "Account Already Exists", message: "If you already have a Juggle/Juggler account, please use the login.")
                
                let action = UIAlertAction(title: "Login", style: .default) { (_) in
                    self.handleSwitchToLogin()
                }
                
                alert.addAction(action)
                //Display error alert message, stop animating activity indicator and return.
                self.disableAndAnimate(false)
                self.display(alert: alert)
            }
            
            self.createUser(fromtextFields: textFields)
        }
    }
    
    fileprivate func createUser(fromtextFields textFields: (email: String, password: String, firstName: String, lastName: String)) {
        Auth.auth().createUser(withEmail: textFields.email, password: textFields.password) { (newUser, err) in
            
            //Checking for error codes to return the correct error message
            if let error = err {
                
                var alertController: UIAlertController?
                
                if error.localizedDescription == Constants.ErrorDescriptions.unavailableEmail {
                    let alert = UIView.okayAlert(title: "Email Unavailable", message: "The email address is already in use by another user.")
                    alertController = alert
                    
                } else if error.localizedDescription == Constants.ErrorDescriptions.networkError {
                    let alert = UIView.okayAlert(title: "Network Connection Error", message: "Please try connectig to a better network.")
                    alertController = alert
                    
                } else {
                    let alert = UIView.okayAlert(title: "Error Creating Account", message: "Please verify that you have entered the correct credentials.")
                    alertController = alert
                }
                
                //Display error alert message, stop animating activity indicator and return.
                self.disableAndAnimate(false)
                if let alert = alertController {
                    self.display(alert: alert)
                }
                return
            }
            
            guard let user = newUser else {
                DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                }
                return
            }
            
            //Get correct profile image for user and compress it.
            guard let imageData = self.approveProfileImage().jpegData(compressionQuality: 0.2) else {
                DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                }
                return
            }
            
            // create a random file name to add profile image to Firebase storage
            let randomFile = UUID().uuidString
            let storageRef = Storage.storage().reference().child(Constants.FirebaseStorage.profileImages).child(randomFile)
            storageRef.putData(imageData, metadata: nil, completion: { (metaData, err) in
                //Check for error
                if let error = err {
                    print("Error uploading profileImage to storage: ", error)
                    DispatchQueue.main.async {
                        self.disableAndAnimate(false)
                    }
                    return
                }
                
                guard let profileImageURLString = metaData?.downloadURL()?.absoluteString else {
                    print("Could not return profileImageURL from storage")
                    DispatchQueue.main.async {
                        self.disableAndAnimate(false)
                    }
                    return
                }
                
                let userValues: [String : Any] = [
                    Constants.FirebaseDatabase.emailAddress : textFields.email,
                    Constants.FirebaseDatabase.firstName : textFields.firstName,
                    Constants.FirebaseDatabase.lastName : textFields.lastName,
                    Constants.FirebaseDatabase.profileImageURLString : profileImageURLString,
                    Constants.FirebaseDatabase.isJuggler : 0
                ]
                let values = [user.uid : userValues]
                
                let databaseRef = Database.database().reference().child(Constants.FirebaseDatabase.usersRef)
                
                databaseRef.updateChildValues(values, withCompletionBlock: { (err, _) in
                    if let error = err {
                        print("Error saving user info to database: ", error)
                        DispatchQueue.main.async {
                            self.disableAndAnimate(false)
                        }
                        return
                    }
                    
                    // Delete and refresh info in mainTabBar controllers
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { fatalError() }
                    mainTabBarController.setupViewControllers()
                    
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    fileprivate func approveProfileImage() -> UIImage {
        var image = UIImage()
        
        guard let plusPhotoImage = self.plusPhotoButton.imageView?.image else {
            image = #imageLiteral(resourceName: "default_profile_image")
            return image
        }
        
        if plusPhotoImage == #imageLiteral(resourceName: "plus_photo") {
            image = #imageLiteral(resourceName: "default_profile_image")
            return image
        } else {
            image = plusPhotoImage
            return image
        }
    }
    
    fileprivate func approveInputFields() -> (email: String, password: String, firstName: String, lastName: String)? {
        guard let password1 = passwordOneTextField.text, let password2 = passwordTwoTextField.text else { return nil }
        
        if password1 != password2 {
            let alert = UIView.okayAlert(title: "Re-enter passwords", message: "Both password text fields must be identical and atleast 6 characters long.")
            self.display(alert: alert); return nil
        }
        
        guard let email = emailTextField.text else { return nil }
        guard let firstName = firstNameTextField.text else { return nil }
        guard let lastName = lastNameTextField.text else { return nil }
        if !termsAndConditionsSwitch.isOn {
            return nil
        }
        
        return (email, password1, firstName, lastName)
    }
    
    let switchToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Log in.", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.mainBlue()]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleSwitchToLogin), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleSwitchToLogin() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.hidesBackButton = true
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 150)
        
        scrollView.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: scrollView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        let termsAndConditionsStackView = UIStackView(arrangedSubviews: [
            termsAndConditionsSwitch,
            termsAndConditionsButton
            ])
        
        termsAndConditionsStackView.axis = .horizontal
        termsAndConditionsStackView.distribution = .fill
        termsAndConditionsStackView.spacing = 4
        
        let stackView = UIStackView(arrangedSubviews: [
            firstNameTextField,
            lastNameTextField,
            emailTextField,
            passwordOneTextField,
            passwordTwoTextField,
            termsAndConditionsStackView,
            signUpButton
            ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        scrollView.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: nil, height: 292)
        
        scrollView.addSubview(switchToLoginButton)
        switchToLoginButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
    }
    
    func disableAndAnimate(_ bool: Bool) {
        
        DispatchQueue.main.async {
            if bool {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
        
        scrollView.isUserInteractionEnabled = !bool
        plusPhotoButton.isEnabled = !bool
        firstNameTextField.isEnabled = !bool
        lastNameTextField.isEnabled = !bool
        emailTextField.isEnabled = !bool
        passwordOneTextField.isEnabled = !bool
        passwordTwoTextField.isEnabled = !bool
        termsAndConditionsSwitch.isEnabled = !bool
        termsAndConditionsButton.isEnabled = !bool
        signUpButton.isEnabled = !bool
        switchToLoginButton.isEnabled = !bool
    }
    
    fileprivate func display(alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: UITextFieldDelegate Methods
extension SignupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
}
