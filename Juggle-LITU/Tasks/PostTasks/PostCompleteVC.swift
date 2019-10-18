//
//  PostCompleteVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 10/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit

class PostCompleteVC: UIViewController {
    
    //MARK: Stored properties
    var task: Task? {
        didSet {
            guard let task = task else {
                navigationController?.popToRootViewController(animated: true)
                return
            }
            createSuccesLabelText(forTitle: task.title)
        }
    }
    
    let succesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.mainBlue()
        
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.lightGray
        label.text = "Now sit back, relax & leave it to us!"
        
        return label
    }()
    
    lazy var finishButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue()
        button.setTitle("Finish", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleFinishButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleFinishButton() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func createSuccesLabelText(forTitle title: String) {
        let attributedString = NSMutableAttributedString(string: "Your task", attributes: [.font : UIFont.systemFont(ofSize: 18), .foregroundColor : UIColor.mainBlue()])
        attributedString.append(NSAttributedString(string: "\n\"\(title)\"", attributes: [.font : UIFont.boldSystemFont(ofSize: 18), .foregroundColor : UIColor.mainBlue()]))
        attributedString.append(NSAttributedString(string: "\nHas been sent to Jugglers!", attributes: [.font : UIFont.systemFont(ofSize: 18), .foregroundColor : UIColor.mainBlue()]))
        
        succesLabel.attributedText = attributedString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Congratulations!"
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finish", style: .plain, target: self, action: #selector(handleFinishButton))
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(infoLabel)
        infoLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: 0, height: nil)
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(succesLabel)
        succesLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: infoLabel.topAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 25, paddingBottom: -20, paddingRight: -25, width: nil, height: nil)
        
        view.addSubview(finishButton)
        finishButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -35, paddingRight: 0, width: 200, height: 50)
        finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        finishButton.layer.cornerRadius = 20
    }
}
