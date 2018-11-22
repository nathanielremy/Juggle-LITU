//
//  MessageTableViewCell.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 14/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

protocol MessageTableViewCellDelegate {
    func handleProfileImageView(forJuggler juggler: Juggler?)
    func handleViewTaskButton(forTask task: Task?)
    func handleAcceptJuggler(forTask task: Task?, juggler: Juggler?, completion: @escaping (Bool) -> Void)
}

class MessageTableViewCell: UITableViewCell {
    
    //MARK: Stored properties
    var delegate: MessageTableViewCellDelegate?
    
    var task: Task? {
        didSet {
            if let task = task {
                self.taskTitleLabel.text = task.title
                displayTaskStatus(forStatus: task.status)
                return
            } else {
                self.taskTitleLabel.text = "Task Deleted"
                print("Task property is nil")
                return
            }
        }
    }
    
    fileprivate func displayTaskStatus(forStatus status: Int) {
        if status == 1 { // Task is sccepted
            acceptButton.setTitle("Accepted", for: .normal)
            acceptButton.isEnabled = false
        } else if status == 2 { // Task is completed
            acceptButton.setTitle("Completed", for: .normal)
            acceptButton.isEnabled = false
        } else { // Task is pending
            acceptButton.setTitle("Accept Juggler", for: .normal)
            acceptButton.isEnabled = true
        }
    }
    
    var message: (Message?, Juggler?) {
        didSet {
            guard let theMessage = message.0, let juggler = message.1 else {
                print("No message or user"); return
            }
            
            profileImageView.loadImage(from: juggler.profileImageURLString)
            fetchTaskFor(userId: theMessage.taskOwnerId, taskId: theMessage.taskId)
            nameLabel.text = juggler.fullName
            messageTextLabel.text = theMessage.text
            timeLabel.text = theMessage.timeStamp.timeAgoDisplay()
        }
    }
    
    fileprivate func fetchTaskFor(userId: String, taskId: String) {
        let taskRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(userId).child(taskId)
        taskRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String : Any] else {
                self.task = nil
                print("Could not convert snapshot to [String : Any]"); return
            }
            
            let task = Task(id: snapshot.key, dictionary: dictionary)
            self.task = task
            
        }) { (error) in
            print("Error fetching task: ", error); return
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    @objc fileprivate func handleProfileImageView() {
        self.delegate?.handleProfileImageView(forJuggler: self.message.1)
    }
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.mainBlue()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    let messageTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        
        return label
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Accept Juggler", for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleAcceptedButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleAcceptedButton() {
        self.acceptButton.isEnabled = false
        self.acceptButton.setTitle("Loading...", for: .normal)
        
        delegate?.handleAcceptJuggler(forTask: self.task, juggler: self.message.1, completion: { (success) in
            
            if !success {
                // If accepting Juggler fails
                self.displayTaskStatus(forStatus: self.task?.status ?? 0)
            } else {
                // If accepting Juggler Succeeds
                
                // Task status values
                // 0 == pendingButton
                // 1 == acceptedButton
                // 2 == completedButton
                
                self.displayTaskStatus(forStatus: (self.task?.status ?? 0) + 1)
            }
            
            self.acceptButton.isEnabled = true
        })
    }
    
    lazy var viewTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Task", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleViewTaskButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleViewTaskButton() {
        delegate?.handleViewTaskButton(forTask: self.task)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50/2
        
        //Add button over profileImageView to view user's profile
        let button = UIButton()
        button.backgroundColor = nil
        addSubview(button)
        button.anchor(top: profileImageView.topAnchor, left: profileImageView.leftAnchor, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        button.layer.cornerRadius = 50/2
        button.addTarget(self, action: #selector(handleProfileImageView), for: .touchUpInside)
        
        // Setup buttons on right.
        let stackView = UIStackView(arrangedSubviews: [acceptButton, viewTaskButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        acceptButton.layer.cornerRadius = 12
        viewTaskButton.layer.cornerRadius = 12
        
        addSubview(stackView)
        stackView.anchor(top: nil, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -4, paddingRight: -8, width: 112, height: 55)
        
        addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 22)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: taskTitleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: stackView.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 20)
        
        addSubview(messageTextLabel)
        messageTextLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: stackView.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 20)
        
        addSubview(timeLabel)
        timeLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: stackView.leftAnchor, paddingTop: 5, paddingLeft: 8, paddingBottom: -4, paddingRight: -8, width: nil, height: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
