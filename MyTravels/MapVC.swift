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
    var selectedID : UUID?
    var annotationName = ""
    var annotationNote = ""
    var annotationLat = Double()
    var annotationLon = Double()
    
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
        
        if selectedID != nil{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyPlaces")
            let idString = selectedID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count>0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            annotationName = name
                            if let note = result.value(forKey: "note") as? String {
                                annotationNote = note
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLat = latitude
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLon = longitude
                                        
                                        //add annotation to map
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationName
                                        annotation.subtitle = annotationNote
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLat, longitude: annotationLon)
                                        annotation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationName
                                        noteText.text = annotationNote
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }catch{
                print("There is an error MapVC viewDidLoad")
            }
        }
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
        if selectedID == nil {
            //get my location
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            //create zoom values
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            //show in map
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "MyPlaces", into: context)
        
        if nameText.text != "" && noteText.text != "" {
            newPlace.setValue(nameText.text, forKey: "name")
            newPlace.setValue(noteText.text, forKey: "note")
            newPlace.setValue(selectedLon, forKey: "longitude")
            newPlace.setValue(selectedLat, forKey: "latitude")
            newPlace.setValue(UUID(), forKey: "id")
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
            
            //update tableView in ViewController
            NotificationCenter.default.post(name: NSNotification.Name("newPlaceAdded"), object: nil)
            navigationController?.popViewController(animated: true)
        }catch {
            print("There is an error here")
        }
    }
    
    // costumize annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            print("buradayım")
            return nil
        }
        
        let reuseID = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView
        if pinView == nil {
            print("buradayım2")
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.blue
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            print("buradayım3")
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //for annotation button clicked
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedID != nil {
            var requestLocation = CLLocation(latitude: annotationLat, longitude: annotationLon)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placeMarks, error) in
                if placeMarks!.count > 0 {
                    let newPlaceMark = MKPlacemark(placemark: placeMarks![0])
                    let item = MKMapItem(placemark: newPlaceMark)
                    item.name = self.annotationName
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        }
    }
}

