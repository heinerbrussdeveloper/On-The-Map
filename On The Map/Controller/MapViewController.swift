//
//  MapViewController.swift
//  On The Map
//
//  Created by Heiner Bruß on 30.05.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadMapView(animated)
    }
    
    
    //MARK:- Adding new Location
    
    @IBAction func addNewLocation(_ sender: UIBarButtonItem) {
        let alertVC = UIAlertController(title: "Whait a second", message: "You already put a pin on the map. \nWould you like to set a new pin?", preferredStyle: .alert)
        
        UdacityAPIClient.getStudentLocation(singleStudent: false, completion: { (data, error) in
            guard let data = data else {
                print(error?.localizedDescription ?? "")
                return
            }
            if data.count > 0 {
                alertVC.addAction(UIAlertAction(title: "Let's do it!", style: .default, handler: { [unowned self] (_) in
                    self.performSegue(withIdentifier: "mapToAddNewLocation", sender: (true, data))
                }))
                
                alertVC.addAction(UIAlertAction(title: "No thanks!", style: .default, handler: nil))
                
                self.present(alertVC, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "mapToAddNewLocation", sender: (false, []))
            }
        })
        
        
    }
    //MARK:- Loading new Map View
    
    @IBAction func reloadMapView(_ sender: Any) {
        getData()
    }
    
    //MARK:- Logout Button Pressed
    
    @IBAction func loggingOut(_ sender: UIBarButtonItem) {
        print("logout pressed")
        UdacityAPIClient.logout {(success: Bool, error: Error?) in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
            
            print(error?.localizedDescription ?? "")
        }
    }
    
    
    // MARK:- Getting Student Locations
    
    func getData() {
        UdacityAPIClient.getStudentLocation(singleStudent: false, completion:{ (data, error) in
            
            guard let data = data else {
                print(error?.localizedDescription ?? "")
                return
            }
            DispatchQueue.main.async {
                StudentsLocationData.studentsData = data
                self.copyData()
            }
        })
    }
    
    //MARK:- Copying Data
    func copyData() {
        self.annotations.removeAll()
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        for value in StudentsLocationData.studentsData {
            self.annotations.append(value.getMapAnnotation())
        }
        self.mapView.addAnnotations(self.annotations)
        
        
    }
    
    //MARK:- Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToAddNewLocation" {
            let destinationVC = segue.destination as? AddNewLocationViewController
            let updateStudentInfo = sender as? (Bool, [StudentInformation])
            destinationVC?.updatePin = updateStudentInfo?.0
            destinationVC?.studentArray = updateStudentInfo?.1
        }
    }
    //MARK:- Alert
    func alert( title: String, messageBody: String) {
        
        let alert = UIAlertController(title: title, message: messageBody, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- MapView Delegate Methods
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        _ = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseableIdent = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseableIdent) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseableIdent)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .green
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            guard let annotation = view.annotation else {
                return
            }
            guard var subtitle = annotation.subtitle else {
                return
            }
            if subtitle!.isValidURL {
                if subtitle!.starts(with: "www") {
                    subtitle! = "https://" + subtitle!
                }
                let url = URL(string: subtitle!)
                UIApplication.shared.open(url!)
            } else {
                
                alert(title: "No URL", messageBody: "There's no URL to open")
            }
        }
    }
}


extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}




extension StudentInformation  {
    func getMapAnnotation() -> MKPointAnnotation {
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        mapAnnotation.title = "\(firstName) \(lastName)"
        mapAnnotation.subtitle = "\(mediaURL)"
        
        return mapAnnotation
    }
}
