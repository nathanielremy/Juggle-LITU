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
    var taskBudget: Int?
    var isTaskOnline = false
    
    // MKMapView's previous annotation
    var previousAnnotation: MKAnnotation?
    
    lazy var scrollView: UIScrollView = {
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
            locationLabel.textColor = UIColor.mainBlue().withAlphaComponent(0.3)
            locationTextField.isUserInteractionEnabled = false
        } else {
            isTaskOnline = false
            mapView.isUserInteractionEnabled = true
            locationLabel.textColor = UIColor.mainBlue()
            locationTextField.isUserInteractionEnabled = true
        }
    }
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Task Location"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.mainBlue()
        
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

        guard let title = taskTitle, let description = taskDescription, let budget = taskBudget, let category = taskCategory else {

            let alert = UIView.okayAlert(title: "Invalid Credentials", message: "Please make sure that all credentials for your task are filled out correctly.")
            present(alert, animated: true, completion: nil)
            disableAndAnimate(false)
            return
        }

        userValues[Constants.FirebaseDatabase.taskTitle] = title
        userValues[Constants.FirebaseDatabase.taskDescription] = description
        userValues[Constants.FirebaseDatabase.taskBudget] = budget
        userValues[Constants.FirebaseDatabase.taskStatus] = 0
        userValues[Constants.FirebaseDatabase.taskReviewed] = 0
        userValues[Constants.FirebaseDatabase.taskCategory] = category
        userValues[Constants.FirebaseDatabase.isTaskOnline] = isTaskOnline ? 1 : 0
        userValues[Constants.FirebaseDatabase.userId] = Auth.auth().currentUser?.uid ?? ""
        userValues[Constants.FirebaseDatabase.creationDate] = Date().timeIntervalSince1970

        postTask(from: userValues)
    }

    fileprivate func postTask(from userValues: [String : Any]) {

        guard let userId = Auth.auth().currentUser?.uid else {
            print("PostTask(): No current user id")
            self.disableAndAnimate(false)
            return
        }

        let tasksRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(userId)
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
            let task = Task(id: "", dictionary: userValues)
            postCompleteNavVC.task = task
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(postCompleteNavVC, animated: true)
            }
        }
    }

    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 698)
        
        let stackView = UIStackView(arrangedSubviews: [onlineTaskLabel, onlineSwitch])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .equalCentering
        
        scrollView.addSubview(stackView)
        stackView.anchor(top: scrollView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 25, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 70)
        
        scrollView.addSubview(locationLabel)
        locationLabel.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 25, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        
        scrollView.addSubview(locationTextField)
        locationTextField.anchor(top: locationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 25, paddingBottom: 0, paddingRight: -25, width: nil, height: 50)
        
        scrollView.addSubview(mapView)
        mapView.anchor(top: locationTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 45, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 425)
        mapView.layer.cornerRadius = 20
        
        mapView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
        
        scrollView.addSubview(activityIndicator2)
        activityIndicator2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator2.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
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
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.placePinAt(coordinate: coordinate)
                        self.activityIndicator.stopAnimating()
                    }
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
        scrollView.isUserInteractionEnabled = !bool
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
