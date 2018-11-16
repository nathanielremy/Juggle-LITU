//
//  ChatLogVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 15/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class ChatLogVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: Stored properties
    var taskId: String?
    var taskOwnerId: String?
    var shouldShowCancel: Bool = false
    var containerViewBottomAnchor: NSLayoutConstraint?
    var messages = [Message]()
    
    var data: (Juggler?, Task?) {
        didSet {
            guard let juggler = data.0 else {
                print("No user for chatLogVC")
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            if let task = data.1 {
                self.setupNavigationTitle(forTitle: task.title)
                if taskId == nil {
                    self.taskId = task.id
                }
                if taskOwnerId == nil {
                    self.taskOwnerId = task.userId
                }
            } else {
                self.setupNavigationTitle(forTitle: "Task Deleted")
            }
            
            self.observeMessages(forJuggler: juggler)
        }
    }
    
    //MARK: Views
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.mainBlue()
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleSendButton() {
        self.disableAndAnimate(true)
        guard let text = self.inputTextField.text else {
            self.disableAndAnimate(false); return
        }
        
        // Below function located above viewDidLoad
        sendMessage(withText: text)
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter message..."
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChanges), for: .editingChanged)
        
        return tf
    }()
    
    @objc fileprivate func handleTextFieldChanges() {
        if let text = inputTextField.text, text != "" {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
    
    fileprivate func sendMessage(withText text: String) {
        self.disableAndAnimate(true)
        // Make sure task is not nil
        if self.data.1 == nil {
            self.disableAndAnimate(false)
            let alert = UIView.okayAlert(title: "Task has beenn deleted", message: "You cannot send a message because the user has deleted this task.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Make sure to have all necessary data to update database
        guard let toId = self.data.0?.uid, let fromId = Auth.auth().currentUser?.uid, let taskId = self.taskId, let taskOwnerId = self.taskOwnerId else {
            self.disableAndAnimate(false)
            let alert = UIView.okayAlert(title: "Unable to Send Message", message: "There was an error while trying to send your message. Please quit and try again.")
            self.present(alert, animated: true) {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        let values: [String : Any] = [Constants.FirebaseDatabase.text : text, Constants.FirebaseDatabase.toId : toId, Constants.FirebaseDatabase.fromId : fromId, Constants.FirebaseDatabase.timeStamp : Date().timeIntervalSince1970, Constants.FirebaseDatabase.taskId : taskId, Constants.FirebaseDatabase.taskOwnerId : taskOwnerId]
        
        // Store message under /messages/randomId
        let databaseRef = Database.database().reference().child(Constants.FirebaseDatabase.messagesRef)
        let childRef = databaseRef.childByAutoId()
        childRef.updateChildValues(values) { (err, _) in
            if let error = err {
                print("Error pushing message node to database: ", error)
                DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                    let alert = UIView.okayAlert(title: "Unable to Send Message", message: "There was an error while trying to send your message. Please quit and try again.")
                    self.present(alert, animated: true) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
        }
        
        // Store a reference to message in database for the sender
        let messageId = childRef.key
        let userMessagesRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(fromId).child(toId)
        userMessagesRef.updateChildValues([messageId : 1]) { (err, _) in
            if let error = err {
                print("Error: ", error)
                DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                    let alert = UIView.okayAlert(title: "Unable to Send Message", message: "There was an error while trying to send your message. Please quit and try again.")
                    self.present(alert, animated: true) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
        }
        
        // Store a reference to message in database for the receiver
        let recipientRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(toId).child(fromId)
        recipientRef.updateChildValues([messageId: 1]) { (err, _) in
            if let error = err {
                print("ERROR: ", error)
                DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                    let alert = UIView.okayAlert(title: "Unable to Send Message", message: "There was an error while trying to send your message. Please quit and try again.")
                    self.present(alert, animated: true) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
        }
        self.disableAndAnimate(false)
        self.inputTextField.text = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        if shouldShowCancel {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets.init(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 58, right: 0)
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.chatMessageCellId)
        
        setupInputComponents()
    }
    
    // When view is presented
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // When view is pushed on to stack
    @objc func handleDone() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupNavigationTitle(forTitle title: String) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        
        let containerView = UIView()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        self.navigationItem.titleView = titleView
        
        titleView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: title, attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.black])
        titleLabel.attributedText = attributedText
        
        containerView.addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 50, paddingBottom: 0, paddingRight: -50, width: nil, height: 40)
        titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyBoardObservers()
    }
    
    // Never forget to remove observers
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyBoardWillShow(notifaction: NSNotification) {
        //Get the height of the keyBoard
        let keyBoardFrame = (notifaction.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyBoardDuration: Double = (notifaction.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        if let height = keyBoardFrame?.height {
            self.containerViewBottomAnchor?.constant = -height + view.safeAreaInsets.bottom
            //Animate the containerView going up
            UIView.animate(withDuration: keyBoardDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyBoardWillHide(notifaction: NSNotification) {
        //Move the keyboard back down
        let keyBoardDuration: Double = (notifaction.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        self.containerViewBottomAnchor?.constant = 0
        //Animate the containerView going down
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func observeMessages(forJuggler juggler: Juggler) {
        self.disableAndAnimate(true)
        
        // User to fetch messages for
        guard let userId = Auth.auth().currentUser?.uid else { print("No current user id"); self.disableAndAnimate(false); return }
        // User to fetch messages from
        let chatPartnerId = juggler.uid
        
        let userMessagesRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(userId).child(chatPartnerId)
        
        self.disableAndAnimate(false)
        
        // The below function gets executed everytime a new value is added to the path above
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child(Constants.FirebaseDatabase.messagesRef).child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : Any] else { DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                    }; return }
                let message = Message(key: snapshot.key, dictionary: dictionary)
                
                if self.taskId == nil {
                    self.taskId = message.taskId
                } else if self.taskOwnerId == nil {
                    self.taskOwnerId = message.taskOwnerId
                }
                
                if message.chatPartnerId() == self.data.0?.uid {
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.disableAndAnimate(false)
                        self.collectionView?.reloadData()
                        //Make collectionView scroll to bottom when message is sent and/or recieved
                        self.collectionView?.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            }, withCancel: { (error) in
                print("Error observing messages")
                DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                }
                return
            })
        }) { (error) in
            print("Error fetching user-messages for user: \(userId): ", error)
            self.disableAndAnimate(true)
            return
        }
    }
    
    fileprivate func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        containerView.addSubview(sendButton)
        sendButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: nil)
        
        containerView.addSubview(inputTextField)
        inputTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .black
        
        containerView.addSubview(seperatorView)
        seperatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    func disableAndAnimate(_ bool: Bool) {
        DispatchQueue.main.async {
            if bool {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
            
            self.navigationItem.leftBarButtonItem?.isEnabled = !bool
            self.inputTextField.isEnabled = !bool
            self.collectionView?.isUserInteractionEnabled = !bool
            
            if let text = self.inputTextField.text, text == "" {
                self.sendButton.isEnabled = false
            } else {
                self.sendButton.isEnabled = !bool
            }
        }
    }
    
    //MARK: UICollectionView methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.chatMessageCellId, for: indexPath) as! ChatMessageCell
        
        let message = self.messages[indexPath.item]
        
        cell.textView.text = message.text
        
        setupChatMessageCell(cell: cell, message: message)
        
        //Modifyig the chat bubble's width
        let text = self.messages[indexPath.item].text
        cell.chatBubbleWidth?.constant = estimatedFrameForChatBubble(fromText: text).width + 32
        
        cell.delegate = self
        
        return cell
    }
    
    fileprivate func setupChatMessageCell(cell: ChatMessageCell, message: Message) {
        
        if let profileImageURLString = self.data.0?.profileImageURLString {
            cell.profileImageView.loadImage(from: profileImageURLString)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //Display blue chatBubble
            cell.chatBubble.backgroundColor = UIColor.mainBlue()
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.chatBubbleLeftAnchor?.isActive = false
            cell.chatBubbleRightAnchor?.isActive = true
        } else {
            //Display gray chatBubble
            cell.chatBubble.backgroundColor = UIColor.chatBubbleGray()
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.chatBubbleLeftAnchor?.isActive = true
            cell.chatBubbleRightAnchor?.isActive = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        //Modifying the chat bubble's height
        let text = self.messages[indexPath.item].text
        height = self.estimatedFrameForChatBubble(fromText: text).height + 20
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    fileprivate func estimatedFrameForChatBubble(fromText text: String) -> CGRect {
        // height must be something really tall and width is the same as chatBubble in ChatMessageCell
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
}

extension ChatLogVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension ChatLogVC: ChatMessageCellDelegate {
    func handleProfileImageView() {
        //FIXME: Show jugglers profile page
        print("Handle Profile Image View")
    }
}
