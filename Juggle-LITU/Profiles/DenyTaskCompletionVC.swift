//
//  DenyTaskCompletionVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 2019-12-11.
//  Copyright © 2019 Nathaniel Remy. All rights reserved.
//

import Foundation
import Firebase

class DenyTaskCompletionVC: UIViewController {
    
    //MARK: Stored properties
    var task: Task?
    
    let explenationLabel: UILabel = {
        let label = UILabel()
        label.text = "We are sorry to here that your task did not go as planned. Leave us your phone number and email address so we can get in touch with you as soon as possible and fix this issue."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.mainBlue()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    let phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Phone Number"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.mainBlue()
        
        return label
    }()
    
    lazy var phoneNumberTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "+34 123 456 789"
        tf.keyboardType = .phonePad
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(handleTextFieldDoneButton))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        tf.inputAccessoryView = toolBar
        
        return tf
    }()
    
    let emailAddressLabel: UILabel = {
        let label = UILabel()
        label.text = "Email Address"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.mainBlue()
        
        return label
    }()
    
    lazy var emailAddressTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "support@juggle.es"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        
        return tf
    }()
    
    lazy var reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue()
        button.setTitle("Report", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        
        return button
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "Report Problem"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(handleReport))
        
        setupViews()
        setupActivityIndicator()
    }
    
    fileprivate func setupActivityIndicator() {
        view.addSubview(self.activityIndicator)
        self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setupViews() {
        view.addSubview(explenationLabel)
        explenationLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 34, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(phoneNumberLabel)
        phoneNumberLabel.anchor(top: explenationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 34, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        view.addSubview(phoneNumberTextField)
        phoneNumberTextField.anchor(top: phoneNumberLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(emailAddressLabel)
        emailAddressLabel.anchor(top: phoneNumberTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 34, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        view.addSubview(emailAddressTextField)
        emailAddressTextField.anchor(top: emailAddressLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(reportButton)
        reportButton.anchor(top: emailAddressTextField.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 35, paddingLeft: 45, paddingBottom: 0, paddingRight: -45, width: 200, height: 50)
        reportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reportButton.layer.cornerRadius = 20
    }
    
    @objc fileprivate func handleReport() {
        self.animateAndShowActivityIndicator(true)
        
        guard let inputs = verifyInputs() else {
            self.animateAndShowActivityIndicator(false)
            return
        }

        guard let task = self.task, let mutuallyAcceptedBy = task.mutuallyAcceptedBy else {
            self.animateAndShowActivityIndicator(false)
            self.navigationController?.popViewController(animated: true)
            return
        }

        let values = [Constants.FirebaseDatabase.isTaskDenied : 1]
        let usersRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(task.id)
        usersRef.updateChildValues(values) { (err, _) in
            if let error = err {
                self.animateAndShowActivityIndicator(false)
                print("DenyTaskCompleteVC updating task values error: \(error)")
                self.navigationController?.popViewController(animated: true)
                return
            }

            let denialValues: [String : Any] = [
                Constants.FirebaseDatabase.creationDate : Date().timeIntervalSince1970,
                Constants.FirebaseDatabase.userId : task.userId,
                Constants.FirebaseDatabase.jugglerId : mutuallyAcceptedBy,
                Constants.FirebaseDatabase.phoneNumber : inputs.phoneNumber,
                Constants.FirebaseDatabase.emailAddress : inputs.emailAddress
            ]

            let deniedTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.deniedTasksRef).child(task.id)
            deniedTasksRef.updateChildValues(denialValues) { (err, _) in
                if let error = err {
                    self.animateAndShowActivityIndicator(false)
                    print("DenyTaskCompleteVC updating denialTasksRef error: \(error)")
                    self.navigationController?.popViewController(animated: true)
                    return
                }

                self.animateAndShowActivityIndicator(false)
                UserProfileVC.didRecentlyDenyTask =  true
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    fileprivate func verifyInputs() -> (phoneNumber: String, emailAddress: String)? {
        guard let phoneNumber = phoneNumberTextField.text, phoneNumber.count > 11, phoneNumber.count < 16, phoneNumber.first == "+" else {
            let alert = UIView.okayAlert(title: "Invalid Phone Number", message: "Make sure phone number is in the following format '+34 123 456 789'")
            self.present(alert, animated: true, completion: nil)
            
            return nil
        }
        
        guard let emailAddress = emailAddressTextField.text, emailAddress.contains("@"), emailAddress.count > 7 else {
            let alert = UIView.okayAlert(title: "Invalid Email Address", message: "Please enter a correct email address.")
            self.present(alert, animated: true, completion: nil)
            
            return nil
        }
        
        return (phoneNumber, emailAddress)
    }
}

//MARK: UITextFieldDelegate Methods
extension DenyTaskCompletionVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // When done button is clicked on keyboard input accessory view
    @objc func handleTextFieldDoneButton() {
        view.endEditing(true)
    }
}
