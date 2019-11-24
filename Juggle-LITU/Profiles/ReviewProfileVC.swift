//
//  ReviewProfileVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 18/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class ReviewProfileVC: UIViewController {
    
    //MARK: Stored properties
    var intRating: Int = 0
    var isReviewDone = false
    var isTaskUpdated = false
    var jugglerId: String? {
        didSet {
            guard let jugglerId = jugglerId else { navigationController?.popViewController(animated: true); return }
            
            Database.fetchJuggler(userID: jugglerId) { (jglr) in
                guard let juggler = jglr else {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                self.profileImageView.loadImage(from: juggler.profileImageURLString)
                self.fullNameLabel.text = juggler.firstName + " " + juggler.lastName
            }
        }
    }
    
    var task: Task? {
        didSet {
            guard let _ = task else {
                self.navigationController?.popViewController(animated: true)
                return
            }
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
    
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.backgroundColor = .lightGray
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.mainBlue().cgColor
        image.layer.borderWidth = 1.5
        
        return image
    }()
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        
        return label
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "Select rating"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = UIColor.mainBlue()
        
        return label
    }()
    
    lazy var star1: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 1
        button.setImage(#imageLiteral(resourceName: "emptyStar").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(changeRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var star2: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 2
        button.setImage(#imageLiteral(resourceName: "emptyStar").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(changeRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var star3: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 3
        button.setImage(#imageLiteral(resourceName: "emptyStar").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(changeRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var star4: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 4
        button.setImage(#imageLiteral(resourceName: "emptyStar").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(changeRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var star5: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 5
        button.setImage(#imageLiteral(resourceName: "emptyStar").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(changeRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func changeRating(_ button: UIButton) {
        intRating = button.tag
        
        star1.setImage(#imageLiteral(resourceName: "emptyStar").withRenderingMode(.alwaysOriginal), for: .normal)
        star2.setImage(#imageLiteral(resourceName: "emptyStar").withRenderingMode(.alwaysOriginal), for: .normal)
        star3.setImage(#imageLiteral(resourceName: "emptyStar").withRenderingMode(.alwaysOriginal), for: .normal)
        star4.setImage(#imageLiteral(resourceName: "emptyStar").withRenderingMode(.alwaysOriginal), for: .normal)
        star5.setImage(#imageLiteral(resourceName: "emptyStar").withRenderingMode(.alwaysOriginal), for: .normal)
        
        if button.tag == 1 {
            star1.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
        } else if button.tag == 2 {
            star1.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
            star2.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
        } else if button.tag == 3 {
            star1.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
            star2.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
            star3.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
        } else if button.tag == 4 {
            star1.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
            star2.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
            star3.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
            star4.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
        } else if button.tag == 5 {
            star1.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
            star2.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
            star3.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
            star4.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
            star5.setImage(#imageLiteral(resourceName: "fullStar").withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    let reviewDescriptionLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "Detailed review\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.mainBlue()])
        attributedText.append(NSAttributedString(string: "(Minimum 10 charcaters, max 250 characters)", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.mainBlue()]))
        
        label.attributedText = attributedText
        label.textAlignment = .left
        label.numberOfLines = 2
        
        return label
    }()
    
    lazy var reviewTextView: UITextView = {
        let tv = UITextView()
        tv.tintColor = UIColor.mainBlue()
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(handleTextFieldDoneButton))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        tv.inputAccessoryView = toolBar
        
        return tv
    }()
    
    @objc func handleTextFieldDoneButton() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if jugglerId == nil {
            navigationController?.popViewController(animated: true)
        }
        view.backgroundColor = .white
        navigationItem.title = "Review"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDoneButton))
        
        setupViews()
    }
    
    func verifyReview() -> (success: Bool, review: String?) {
        guard let description = reviewTextView.text, description.count > 9, description.count < 251 else {
            return (false, nil)
        }
        return (true, description)
    }
    
    @objc fileprivate func handleDoneButton() {
        self.updateTask()
        self.disableAndAnimate(true)
        
        if !verifyReview().success {
            self.disableAndAnimate(false)
            let alert = UIView.okayAlert(title: "Invalid review", message: "Review must be between 10 and 250 characters.")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let reviewString = verifyReview().review, let userId = self.task?.userId else {
            self.disableAndAnimate(false)
            let alert = UIView.okayAlert(title: "Unable to review user", message: "There has been a problem, please try again.")
            present(alert, animated: true, completion: nil)
            return
        }

        let values: [String : Any] = [Constants.FirebaseDatabase.rating : intRating, Constants.FirebaseDatabase.userId : userId, Constants.FirebaseDatabase.reviewDescription : reviewString, Constants.FirebaseDatabase.creationDate : Date().timeIntervalSince1970]

        addReviewToDatabase(withValues: values)
    }

    fileprivate func addReviewToDatabase(withValues values: [String : Any]) {

        guard let jugglerId = self.jugglerId else {
            self.disableAndAnimate(false)
            let alert = UIView.okayAlert(title: "Unable to review user", message: "There has been a problem, please try again.")
            present(alert, animated: true, completion: nil)
            
            return
        }

        let reviewsRef = Database.database().reference().child(Constants.FirebaseDatabase.reviewsRef).child(jugglerId)
        let autoRef = reviewsRef.childByAutoId()
        
        autoRef.updateChildValues(values) { (err, _) in
            if let error = err {
                print("ReviewProfileVC/addReviewToDatabase: Error: ", error)
                
                DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                    let alert = UIView.okayAlert(title: "Unable to review user", message: "There has been a problem, please try again.")
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
            }
            
            self.disableAndAnimate(false)
            
            self.isReviewDone = true
            if self.isTaskUpdated {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    fileprivate func updateTask() {
        guard let task = self.task else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        // Update user's task to have a status of 1. Which means it has been accepted
        let userValues = [Constants.FirebaseDatabase.isTaskReviewed : 1]
        let usersRef =  Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(task.userId).child(task.id)
        usersRef.updateChildValues(userValues) { (err, _) in
            
            if let error = err {
                print("ReviewProfileVC/updateTask: Error: ", error)
                
                DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                    let alert = UIView.okayAlert(title: "Unable to review user", message: "There has been a problem, please try again.")
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            
            self.disableAndAnimate(false)
            
            self.isTaskUpdated = true
            if self.isReviewDone {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 110)
        
        
        scrollView.addSubview(profileImageView)
        profileImageView.anchor(top: scrollView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileImageView.layer.cornerRadius = 100/2
        profileImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(fullNameLabel)
        fullNameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        
        scrollView.addSubview(ratingLabel)
        ratingLabel.anchor(top: fullNameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: nil)
        
        let stackView = UIStackView(arrangedSubviews: [star1, star2, star3, star4, star5])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        scrollView.addSubview(stackView)
        stackView.anchor(top: ratingLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 50, paddingBottom: 0, paddingRight: -50, width: nil, height: 60)
        
        let topSeperatorView = UIView()
        topSeperatorView.backgroundColor = UIColor.lightGray
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = UIColor.lightGray
        
        scrollView.addSubview(topSeperatorView)
        topSeperatorView.anchor(top: ratingLabel.topAnchor, left: ratingLabel.leftAnchor, bottom: nil, right: ratingLabel.rightAnchor, paddingTop: -8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
        scrollView.addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: ratingLabel.leftAnchor, bottom: stackView.bottomAnchor, right: ratingLabel.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: nil, height: 0.5)
        
        scrollView.addSubview(reviewDescriptionLabel)
        reviewDescriptionLabel.anchor(top: stackView.bottomAnchor, left: ratingLabel.leftAnchor, bottom: nil, right: ratingLabel.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
        
        scrollView.addSubview(reviewTextView)
        reviewTextView.anchor(top: reviewDescriptionLabel.bottomAnchor, left: ratingLabel.leftAnchor, bottom: nil, right: ratingLabel.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 150)
        
        scrollView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    func disableAndAnimate(_ bool: Bool) {
        if bool {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = !bool
        star1.isEnabled = !bool
        star2.isEnabled = !bool
        star3.isEnabled = !bool
        star4.isEnabled = !bool
        star5.isEnabled = !bool
        reviewTextView.isUserInteractionEnabled = !bool
        scrollView.isUserInteractionEnabled = !bool
    }
}
