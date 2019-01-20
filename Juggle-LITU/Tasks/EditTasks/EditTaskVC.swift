//
//  EditTaskVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 23/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class EditTaskVC: UIViewController {
    
    //MARK: Stored properties
    var previousViewController: TaskDetailsVC?
    var didChangeTitle = false
    var didChangeDuration = false
    var didChangeBudget = false
    var didChangeDescription = false
    var task: Task? {
        didSet {
            guard let task = task else {
                self.navigationController?.popViewController(animated: true)
                
                return
            }
            
            self.taskTitleTextField.placeholder = task.title
            self.taskDescriptionTextView.text = task.description
            self.durationTextField.placeholder = "\(task.duration)"
            self.budgetTextField.placeholder = "\(task.budget)"
        }
    }
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = true
        sv.backgroundColor = .white
        
        return sv
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Task Title"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.mainBlue()
        
        return label
    }()
    
    lazy var taskTitleTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChanges), for: .editingChanged)
        
        return tf
    }()
    
    let taskDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        var attributedText = NSMutableAttributedString(string: "Description\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 18), .foregroundColor : UIColor.mainBlue()])
        attributedText.append(NSAttributedString(string: "(Minimum 25 charcaters, max 250 characters)", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.mainBlue()]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var taskDescriptionTextView: UITextView = {
        let tv = UITextView()
        tv.tintColor = UIColor.mainBlue()
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isUserInteractionEnabled = true
        tv.textColor = UIColor.lightGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handletaskDescriptionTextView))
        tv.addGestureRecognizer(tapGesture)
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(handleTextFieldDoneButton))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        tv.inputAccessoryView = toolBar
        
        return tv
    }()
    
    @objc fileprivate func handletaskDescriptionTextView() {

        didChangeDescription = true
        
        self.taskDescriptionTextView.becomeFirstResponder()
        
        guard let task = self.task else {
            return
        }

        if self.taskDescriptionTextView.text == task.description {
            self.taskDescriptionTextView.text = ""
            self.taskDescriptionTextView.textColor = UIColor.black
        }
    }
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "Estimated Duration\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 18), .foregroundColor : UIColor.mainBlue()])
        attributedText.append(NSAttributedString(string: "(How long will it take to complete this task, in hours?)", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.mainBlue()]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var durationTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .decimalPad
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChanges), for: .editingChanged)
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(handleTextFieldDoneButton))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        tf.inputAccessoryView = toolBar
        
        return tf
    }()
    
    let budgetLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "Budget $\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 18), .foregroundColor : UIColor.mainBlue()])
        attributedText.append(NSAttributedString(string: "(How much you are willing to pay for this task to be accomplished)", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.mainBlue()]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var budgetTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .numberPad
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChanges), for: .editingChanged)
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(handleTextFieldDoneButton))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        tf.inputAccessoryView = toolBar
        
        return tf
    }()
    
    @objc fileprivate func handleTextInputChanges(_ textField: UITextField) {
        if textField == taskTitleTextField {
            didChangeTitle = true
        } else if textField == budgetTextField {
            didChangeBudget = true
        } else if textField == durationTextField {
            didChangeDuration = true
        }
    }
    
    lazy var deleteTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Task", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(handleDeleteButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleDeleteButton() {
        guard let task = self.task, task.status == 0 else {
            let alert = UIView.okayAlert(title: "Cannot Delete This Task", message: "You're task has been accepted. Only pending tasks can be deleted.")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.delete(task)
        }
        
        let deleteAlert = UIAlertController(title: "Delete This Task?", message: "This will permenantly delete this task.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.disableAndAnimate(false)
            return
        }
        
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    fileprivate func delete(_ task: Task) {
        self.disableAndAnimate(true)
        let taskRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(task.userId).child(task.id)
        taskRef.removeValue { (err, _) in
            if let error = err {
                print("Error deleting task: \(error)")
                self.disableAndAnimate(false)
                let alert = UIView.okayAlert(title: "Cannot Delete This Task", message: "We are unable to delete this task. Please try again later.")
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            self.disableAndAnimate(false)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.setupDoneButton()
        self.setupViews()
    }
    
    @objc fileprivate func handleDoneButton() {
        self.disableAndAnimate(true)
        
        guard let task = self.task else {
            self.disableAndAnimate(false)
            let alert = UIView.okayAlert(title: "Cannot Edit This Task", message: "We are currently unable to edit your task. Please try again later.")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard let userValues = self.fetchValues() else {
            // UIAlert with error info already shown to user. Simply need to return here
            self.disableAndAnimate(false)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let taskRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(task.userId).child(task.id)
        taskRef.updateChildValues(userValues) { (err, databaseReference) in
            if let error = err {
                self.disableAndAnimate(false)
                print("Error editing task: \(error)")
                let alert = UIView.okayAlert(title: "Cannot Edit This Task", message: "We are currently unable to edit your task. Please try again later.")
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            self.fetchNewTask(forTask: task)
        }
    }
    
    fileprivate func fetchNewTask(forTask task: Task) {
        let taskRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(task.userId).child(task.id)
        taskRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String : Any], let prevViewController = self.previousViewController else {
                
                self.disableAndAnimate(false)
                let alert = UIView.okayAlert(title: "Cannot Edit This Task", message: "We are currently unable to edit your task. Please try again later.")
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            self.disableAndAnimate(false)
            
            let task = Task(id: snapshot.key, dictionary: dictionary)
            
            prevViewController.task = task
            self.navigationController?.popToViewController(prevViewController, animated: true)
            
            
            
        }) { (error) in
            self.disableAndAnimate(false)
            print("Error editing task: \(error)")
            let alert = UIView.okayAlert(title: "Cannot Edit This Task", message: "We are currently unable to edit your task. Please try again later.")
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func areInputsValid() -> (title: String?, description: String?, duration: Double?, budget: Int?) {
        
        var newTitle: String? = nil
        var newDescription: String? = nil
        var newDuration: Double? = nil
        var newBudget: Int? = nil
        
        if didChangeTitle {
            if let title = taskTitleTextField.text, title.count > 9, title.count < 41 {
                newTitle = title
            } else {
                let alert = UIView.okayAlert(title: "Error with title", message: "Title must be between 10-40 characters.")
                present(alert, animated: true, completion: nil)
            }
        }
        
        if didChangeDescription {
            if let description = taskDescriptionTextView.text, description.count > 24, description.count < 251 {
                newDescription = description
            } else {
                let alert = UIView.okayAlert(title: "Error with description", message: "Description must be between 25-250 characters.")
                present(alert, animated: true, completion: nil)
            }
        }
        
        if didChangeDuration {
            if let duration = Double(durationTextField.text!) {
                newDuration = duration
            } else {
                let alert = UIView.okayAlert(title: "Error with estimated duration", message: "Please enter how much time you think it will take to accomplish this task.")
                present(alert, animated: true, completion: nil)
            }
        }
        
        if didChangeBudget {
            if let budget = Int(budgetTextField.text!) {
                newBudget = budget
            } else {
                let alert = UIView.okayAlert(title: "Error with budget", message: "Please enter integer values for your budget.")
                present(alert, animated: true, completion: nil)
            }
        }
        
        return (newTitle, newDescription, newDuration, newBudget)
    }
    
    fileprivate func fetchValues() -> [String : Any]? {

        var userValues = [String : Any]()

        let inputs = self.areInputsValid()
        
        if let title = inputs.title {
            userValues[Constants.FirebaseDatabase.taskTitle] = title
        }
        
        if let description = inputs.description {
            userValues[Constants.FirebaseDatabase.taskDescription] = description
        }
        
        if let duration = inputs.duration {
            userValues[Constants.FirebaseDatabase.taskDuration] = duration
        }
        
        if let budget = inputs.budget {
            userValues[Constants.FirebaseDatabase.taskBudget] = budget
        }
        
        if userValues.isEmpty {
            return nil
        } else {
            return userValues
        }
    }
    
    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1050)
        
        scrollView.addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: scrollView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        
        scrollView.addSubview(taskTitleTextField)
        taskTitleTextField.anchor(top: taskTitleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        
        scrollView.addSubview(taskDescriptionLabel)
        taskDescriptionLabel.anchor(top: taskTitleTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 25, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        
        scrollView.addSubview(taskDescriptionTextView)
        taskDescriptionTextView.anchor(top: taskDescriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 200)
        
        scrollView.addSubview(durationLabel)
        durationLabel.anchor(top: taskDescriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 25, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 60)
        
        scrollView.addSubview(durationTextField)
        durationTextField.anchor(top: durationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        
        scrollView.addSubview(budgetLabel)
        budgetLabel.anchor(top: durationTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 25, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 60)
        
        scrollView.addSubview(budgetTextField)
        budgetTextField.anchor(top: budgetLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        
        scrollView.addSubview(deleteTaskButton)
        deleteTaskButton.anchor(top: budgetTextField.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 50)
        deleteTaskButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func setupDoneButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneButton))
    }
    
    fileprivate func disableAndAnimate(_ bool: Bool) {
        DispatchQueue.main.async {
            if bool {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
        
        self.taskTitleTextField.isEnabled = !bool
        self.taskDescriptionTextView.isUserInteractionEnabled = !bool
        self.budgetTextField.isEnabled = !bool
        self.scrollView.isUserInteractionEnabled = !bool
        self.deleteTaskButton.isEnabled = !bool
    }
}

//MARK: UITextFieldDelegate Methods
extension EditTaskVC: UITextFieldDelegate {
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
