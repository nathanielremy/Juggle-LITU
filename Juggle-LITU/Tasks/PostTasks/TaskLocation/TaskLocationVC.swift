//
//  TaskLocationVC.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 09/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class TaskLocationVC: UIViewController {
    
    //MARK: Stored properties
    var taskCategory: String?
    var taskTitle: String?
    var taskDescription: String?
    var taskDuration: Double?
    var taskBudget: Double?
    var isTaskOnline = false
    
    // MKMapView's previous annotation
    var previousAnnotation: MKAnnotation?
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = true
        sv.backgroundColor = .white
        
        return sv
    }()
    
    let activityIndicator2: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    let onlineTaskLabel: UILabel = {
        let label = UILabel()
        label.text = "Can the task be completed online or by phone?"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.mainBlue()
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var onlineSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.tintColor = UIColor.mainBlue()
        toggle.onTintColor = UIColor.mainBlue()
        toggle.addTarget(self, action: #selector(handleOnlineSwitch), for: .valueChanged)
        
        return toggle
    }()
    
    @objc fileprivate func handleOnlineSwitch() {
        if onlineSwitch.isOn {
            isTaskOnline = true
            mapView.isUserInteractionEnabled = false
            mapView.alpha = 0.5
            locationLabel.textColor = UIColor.mainBlue().withAlphaComponent(0.3)
            locationTextField.isUserInteractionEnabled = false
        } else {
            isTaskOnline = false
            mapView.isUserInteractionEnabled = true
            mapView.alpha = 1
            locationLabel.textColor = UIColor.mainBlue()
            locationTextField.isUserInteractionEnabled = true
        }
    }
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Task Location"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.mainBlue()
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var locationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Location"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.mainBlue()
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        
        return tf
    }()
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        
        return map
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue()
        button.setTitle("Done", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "Task Location"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        
        setupViews()
    }
    
    @objc fileprivate func handleDone() {
        if isTaskOnline {
            verifyTask()
        } else {
            if mapView.annotations.isEmpty {
                let alert = UIView.okayAlert(title: "No location provided", message: "Please specify the location for where your needed service will take place.")
                present(alert, animated: true, completion: nil)

            } else {
                verifyTask()
            }
        }
    }
    
    fileprivate func verifyTask() {
        disableAndAnimate(true)

        var userValues = [String : Any]()

        if !isTaskOnline {
            let latitude = mapView.annotations[0].coordinate.latitude as Double
            let longitude = mapView.annotations[0].coordinate.longitude as Double

            guard let locationString = locationTextField.text else {
                let alert = UIView.okayAlert(title: "Invalid Credentials", message: "Please make sure that all credentials for your task are filled out correctly.")
                present(alert, animated: true, completion: nil)
                disableAndAnimate(false)
                return
            }
            userValues[Constants.FirebaseDatabase.latitude] = latitude
            userValues[Constants.FirebaseDatabase.longitude] = longitude
            userValues[Constants.FirebaseDatabase.stringLocation] = locationString
        }

        guard let title = taskTitle, let description = taskDescription, let duration = taskDuration, let budget = taskBudget, let category = taskCategory else {

            let alert = UIView.okayAlert(title: "Invalid Credentials", message: "Please make sure that all credentials for your task are filled out correctly.")
            present(alert, animated: true, completion: nil)
            disableAndAnimate(false)
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            let alert = UIView.okayAlert(title: "Unable to Post Task", message: "Sorry we are unable to post your task at the moment. Please come back later and try again.")
            present(alert, animated: true, completion: nil)
            disableAndAnimate(false)
            return
        }

        userValues[Constants.FirebaseDatabase.taskTitle] = title
        userValues[Constants.FirebaseDatabase.taskDescription] = description
        userValues[Constants.FirebaseDatabase.taskDuration] = duration
        userValues[Constants.FirebaseDatabase.taskBudget] = budget
        userValues[Constants.FirebaseDatabase.taskStatus] = 0
        userValues[Constants.FirebaseDatabase.isTaskReviewed] = 0
        userValues[Constants.FirebaseDatabase.taskCategory] = category
        userValues[Constants.FirebaseDatabase.isTaskOnline] = isTaskOnline ? 1 : 0
        userValues[Constants.FirebaseDatabase.userId] = userId
        userValues[Constants.FirebaseDatabase.creationDate] = Date().timeIntervalSince1970
        userValues[Constants.FirebaseDatabase.isJugglerComplete] = 0
        userValues[Constants.FirebaseDatabase.isUserComplete] = 0

        postTask(from: userValues)
    }

    fileprivate func postTask(from userValues: [String : Any]) {
        
        let tasksRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef)
        let autoRef = tasksRef.childByAutoId()

        autoRef.updateChildValues(userValues) { (err, _) in
            if let error = err {
                print("PostTask(): Error udating to Firebase: ", error)
                DispatchQueue.main.async {
                    let alert = UIView.okayAlert(title: "Unable to post task", message: "Please try connecting to a better network or try again later.")
                    self.present(alert, animated: true, completion: nil)
                    self.disableAndAnimate(false)
                    return
                }
            }

            self.disableAndAnimate(false)
            let postCompleteNavVC = PostCompleteVC()
            let task = Task(id: "PLACEHOLDER STRING", dictionary: userValues)
            postCompleteNavVC.task = task
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(postCompleteNavVC, animated: true)
            }
        }
    }

    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 665)
        
        scrollView.addSubview(onlineTaskLabel)
        onlineTaskLabel.anchor(top: scrollView.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: (view.frame.width * 0.7), height: 50)

        scrollView.addSubview(onlineSwitch)
        onlineSwitch.anchor(top: nil, left: onlineTaskLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -25, width: nil, height: nil)
        onlineSwitch.centerYAnchor.constraint(equalTo: onlineTaskLabel.centerYAnchor).isActive = true
        
        scrollView.addSubview(locationLabel)
        locationLabel.anchor(top: onlineTaskLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        
        scrollView.addSubview(locationTextField)
        locationTextField.anchor(top: locationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: -4, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)

        scrollView.addSubview(mapView)
        mapView.anchor(top: locationTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 350)
        mapView.layer.cornerRadius = 20

        mapView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        scrollView.addSubview(activityIndicator2)
        activityIndicator2.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        activityIndicator2.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true

        scrollView.addSubview(doneButton)
        doneButton.anchor(top: mapView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 35, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doneButton.layer.cornerRadius = 20

        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)

        scrollView.addSubview(seperatorView)
        seperatorView.anchor(top: onlineTaskLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 0.5)
    }
    
    func verifyCoordinates(from string: String?) {
        if let coordinateString = string, coordinateString != "" {
            activityIndicator.startAnimating()
            getCoordinates(from: coordinateString, completionHandlerForCoordinates: { (success, coordinate) in
                if success {
                    guard let coordinate = coordinate else {
                        DispatchQueue.main.async {
                            let alert = UIView.okayAlert(title: "Invalid Location", message: "This is an invalid location. We could not geolocate this area.")
                            self.present(alert, animated: true, completion: nil)
                            self.activityIndicator.stopAnimating()
                        }
                        self.activityIndicator.stopAnimating()
                        return
                    }
                    
                    let latitude = coordinate.latitude as Double
                    let longitude = coordinate.longitude as Double
                    
                    if (latitude > Constants.BarcalonaCoordinates.maximumLatitude) || (latitude < Constants.BarcalonaCoordinates.minimumLatitude) || (longitude > Constants.BarcalonaCoordinates.maximumLongitude) || (longitude < Constants.BarcalonaCoordinates.minimumLongitude) {
                        
                        DispatchQueue.main.async {
                            let alert = UIView.okayAlert(title: "Location Unavailable", message: "This feature is not yet available in your city/area.\n(City of Barcelona, Spain Only)")
                            self.present(alert, animated: true, completion: nil)
                            self.activityIndicator.stopAnimating()
                        }
                        self.activityIndicator.stopAnimating()
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.placePinAt(coordinate: coordinate)
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                    let alert = UIView.okayAlert(title: "Invalid Location", message: "Please enter a valid address.")
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            activityIndicator.stopAnimating()
            let alert = UIView.okayAlert(title: "Invalid Location", message: "Please enter a valid address.")
            present(alert, animated: true, completion: nil)
        }
    }
    
    func getCoordinates(from string: String, completionHandlerForCoordinates: @escaping (_ success: Bool, _ location: CLLocationCoordinate2D?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(string) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                completionHandlerForCoordinates(false, nil)
                return
            }
            completionHandlerForCoordinates(true, location.coordinate)
        }
    }
    
    func disableAndAnimate(_ bool: Bool) {
        DispatchQueue.main.async {
            if bool {
                self.activityIndicator2.startAnimating()
            } else {
                self.activityIndicator2.stopAnimating()
            }

        }
        onlineSwitch.isEnabled = !bool
        locationTextField.isUserInteractionEnabled = !bool
        mapView.isUserInteractionEnabled = !bool
        navigationItem.rightBarButtonItem?.isEnabled = !bool
    }
}

//MARK: UITextFieldDelegate Methods
extension TaskLocationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        if textField == locationTextField {
            verifyCoordinates(from: textField.text)
        }
        
        return true
    }
}
