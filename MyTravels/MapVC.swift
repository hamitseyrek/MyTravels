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
import CoreData

class MapVC: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var noteText: UITextField!
    
    //variables
    //Location Manager
    var locationManager = CLLocationManager()
    var selectedLat = Double()
    var selectedLon = Double()
    
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
            
            selectedLat = touchCoordinates.latitude
            selectedLon = touchCoordinates.longitude
            
            //Mark = annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinates
            if nameText.text != "" && noteText.text != "" {
                annotation.title = nameText.text
                annotation.subtitle = noteText.text
            }else{
                let alert = UIAlertController(title: "Alert!", message: "Name or Note area can not be null", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
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
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        if nameText.text != "" && noteText.text != "" {
            newPlace.setValue(nameText.text, forKey: "name")
            newPlace.setValue(noteText.text, forKey: "note")
            newPlace.setValue(selectedLon, forKey: "longitude")
            newPlace.setValue(selectedLat, forKey: "latitude")
        }else{
            let alert = UIAlertController(title: "Alert!", message: "Name or Note area can not be null", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        do {
            try context.save()
            let alert = UIAlertController(title: "Success :)", message: "Registration was successful.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }catch {
            print("There is an error here")
        }
    }
}

