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
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.lightGray
        label.text = "One of our trusted employees will contact you as soon as possible!"
        
        return label
    }()
    
    lazy var finishButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue()
        button.setTitle("Finish", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleFinishButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleFinishButton() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func createSuccesLabelText(forTitle title: String) {
        succesLabel.text = "Congratulations! Your task \"\(title)\" has been sent to our employees."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.hidesBackButton = true
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(infoLabel)
        infoLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 60, paddingBottom: 0, paddingRight: -60, width: 0, height: 64)
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(succesLabel)
        succesLabel.anchor(top: nil, left: view.leftAnchor, bottom: infoLabel.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 122)
        
        view.addSubview(finishButton)
        finishButton.anchor(top: infoLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 45, paddingBottom: 0, paddingRight: -45, width: nil, height: 50)
        finishButton.layer.cornerRadius = 25
    }
}
