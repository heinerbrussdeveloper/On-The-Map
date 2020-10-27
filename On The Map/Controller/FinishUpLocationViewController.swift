//
//  PinViewController.swift
//  On The Map
//
//  Created by Heiner Bruß on 30.05.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class FinishUpLocationViewController: UIViewController{
    @IBOutlet weak var mapView: MKMapView!
    
    
    var location: String!
    var coordinate: CLLocationCoordinate2D!
    var updatePin: Bool!
    var url: String!
    var studentLocationArray: [StudentInformation]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let coordinate = coordinate else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        addNewSpot(coordinate: coordinate)
    }
    //MARK:- Finish Location Button pressed and Dismiss Controller
    
    @IBAction func finishUpLocation(_ sender: Any) {
        
        UdacityAPIClient.gettingUserData {(userData, error) in
            
            guard let userData = userData else {
                return }
            let firstName: String = "Bruce"
            let lastName: String = "Wayne"
            let studentLocationRequest = PostLocation(uniqueKey: userData.key, firstName: firstName, lastName: lastName, mapString: self.location, mediaURL: self.url, latitude: Float(self.coordinate.latitude), longitude: Float(self.coordinate.longitude))
            
            self.updatePin ? self.updateOldPin(postLocationData: studentLocationRequest) : self.postSpot(postLocationData: studentLocationRequest)
        }
        
    }
    //MARK: Posting Spot
    
    func postSpot(postLocationData: PostLocation) {
        UdacityAPIClient.postStudentLocation(postingLocation: postLocationData) {(success,error) in
            if error != nil {
                self.showAlert(title: "We couldn't stick your Pin on the map", message: "Error message :\n\(error?.localizedDescription ?? "couldn't post pin")")
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
    }
    //MARK:- update old pin
    
    func updateOldPin(postLocationData: PostLocation) {
        if studentLocationArray.isEmpty {
            return }
        UdacityAPIClient.putStudentLocation(objectID: studentLocationArray[0].objectID, postingLocation: postLocationData) {(success, error) in
            if error != nil {
                self.showAlert(title: "Couldn't post new pin", message: "Error message :\n\(error?.localizedDescription ?? "couldn't post pin")")
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
    }
    
}
extension FinishUpLocationViewController: MKMapViewDelegate {
    
    func addNewSpot(coordinate: CLLocationCoordinate2D){
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = coordinate
        mapAnnotation.title = location
        
        let mapRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(mapAnnotation)
            self.mapView.setRegion(mapRegion, animated: true)
            self.mapView.regionThatFits(mapRegion)
        }
    }
    
}
