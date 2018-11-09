//
//  MapViewDelegate.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 09/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import Foundation
import MapKit

extension TaskLocationVC: MKMapViewDelegate {
    
    func placePinAt(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        self.mapView.centerCoordinate = coordinate
        
        if let oldAnnotation = self.previousAnnotation {
            self.mapView.removeAnnotation(oldAnnotation)
            self.previousAnnotation = annotation
        } else {
            self.previousAnnotation = annotation
        }
    }
    
    //Delegate methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseIdentifier = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        
        if let pinView = pinView {
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView!.pinTintColor = UIColor.mainBlue()
        }
        return pinView
    }
}
