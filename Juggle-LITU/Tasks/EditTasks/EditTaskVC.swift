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
    var task: Task? {
        didSet {
            guard let task = task else {
                self.navigationController?.popViewController(animated: true)
                
                return
            }
            
            print(task.title)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .yellow
        
        let button: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = .red
            button.setTitle("Back", for: .normal)
            button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            return button
        }()
        
        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func handleButton() {
        guard let task = self.task, let prevViewController = self.previousViewController else {
            return
        }
        
        prevViewController.task = task
        navigationController?.popToViewController(prevViewController, animated: true)
    }
}
