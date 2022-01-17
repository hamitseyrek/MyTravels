//
//  ViewController.swift
//  MyTravels
//
//  Created by Hamit Seyrek on 17.01.2022.
//

import UIKit
import MapKit
// For location
import CoreLocation

class HomeVC: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    //variables
    //Location Manager
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //MapView define to viewController
        mapView.delegate = self
        
        //Location Manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //get location when user auth
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Mark in map
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectedLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    //Mark in map
    @objc func selectedLocation(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let touchCoordinates = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            //Mark = annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinates
            annotation.title = "My Location"
            annotation.subtitle = "Hamit Seyrek"
            mapView.addAnnotation(annotation)
        }
    }
    
    //get update locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get my location
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        //create zoom values
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        //show in map
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
}

