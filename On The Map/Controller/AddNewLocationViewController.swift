//
//  AddNewLocationViewController.swift
//  On The Map
//
//  Created by Heiner Bruß on 30.05.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import UIKit
import MapKit

class AddNewLocationViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var userLocationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    
    var studentArray: [StudentInformation]!
    var updatePin: Bool!
    var mediaUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        geocoding(isActive: false)
    }
    
    //MARK:- Search for Location on Map
    
    @IBAction func searchingForLocation(_ sender: Any) {
        guard let location = userLocationTextField.text else {
            return }
        if location == "" {
            showAlert(title: "Location field is empty", message: "Enter a valid Location")
        }
        else {
            guard let urlText = urlTextField.text else {
                return }
            guard urlText != "" else {
                showAlert(title: "We couldn't find your URL", message: "Please insert a valid URL-Adress.")
                return
            }
            mediaUrl = urlText.prefix(7).lowercased().contains("http://") || urlText.prefix(8).lowercased().contains("https://") ? urlText : "https://" + urlText
        }
        findLocation(location)
    }
    
    func geocoding(isActive: Bool) {
        activityView.isHidden = !isActive
        isActive ? activityView.startAnimating() : activityView.stopAnimating()
    }
    //MARK:- Find Location
    
    func findLocation(_ location: String) {
        self.geocoding(isActive: true)
        CLGeocoder().geocodeAddressString(location) { (placemark, error) in
            
            guard error == nil else {
                self.showAlert(title: "We couldn't find your location", message: "Please enter a valid location: \(location)")
                return
            }
            let coordinate = placemark?.first!.location!.coordinate
            
            print(coordinate?.latitude ?? 0)
            print(coordinate?.longitude ?? 0)
            
            
            self.performSegue(withIdentifier: "addNewLocationToFinishUp", sender: (location, coordinate))
            self.geocoding(isActive: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewLocationToFinishUp" {
            let controller = segue.destination as! FinishUpLocationViewController
            let locationDetails = sender as!  (String, CLLocationCoordinate2D)
            controller.location = locationDetails.0
            controller.coordinate = locationDetails.1
            controller.updatePin = updatePin
            controller.studentLocationArray = studentArray
            controller.url = mediaUrl
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
