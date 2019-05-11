//
//  TermsAndConditions.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 02/12/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit

class TermsAndConditionsVC: UIViewController {
    
    //MARK: Stored properties
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = true
        sv.backgroundColor = .white
        
        return sv
    }()
    
    let termsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkText
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.navigationItem.title = "Terms and Conditions"
        
        setupViews()
        setupLabelInformation()
    }
    
    @objc fileprivate func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupViews() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        
        scrollView.addSubview(termsLabel)
        termsLabel.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: -8, paddingRight: -8, width: view.frame.width - 16, height: nil)
    }
    
    fileprivate func setupLabelInformation() {
        guard let fileURL = Bundle.main.path(forResource: "terms-and-conditions", ofType: "txt") else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        // Attempt to read file
        do {
            
            let fileContent = try String(contentsOfFile: fileURL, encoding: .utf8)
            self.termsLabel.text = fileContent
            
        } catch let error as NSError {
            print("Catch Block Error: \(error)")
            self.dismiss(animated: true, completion: nil)
            return
        }
    }
}
