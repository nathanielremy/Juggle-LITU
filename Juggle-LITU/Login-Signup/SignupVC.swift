//
//  SignupVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 07/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class SignupVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
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
        
        var attributedText = NSMutableAttributedString(string: "Accept ", attributes: [.foregroundColor : UIColor.gray])
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
        print("Handling terms and conditions")
    }
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.3)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    @objc fileprivate func handleSignup() {
        print("Handleing Signup")
    }
    
    let switchToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Login.", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.mainBlue()]))
        
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
