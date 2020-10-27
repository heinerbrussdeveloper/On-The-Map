//
//  ListViewController.swift
//  On The Map
//
//  Created by Heiner Bruß on 30.05.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UITableViewController {
    
    @IBOutlet weak var refreshList: UIBarButtonItem!
    @IBOutlet weak var addNewLocation: UIBarButtonItem!
    @IBOutlet var studentLocationsTableView: UITableView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var studentLocationArray = [StudentInformation]()
    var number: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.number = StudentsLocationData.studentsData.count
        refreshListPressed(animated)
    }
    
    //MARK:- Adding new Location
    @IBAction func addNewLocationButtonPressed(_ sender: Any) {
        let alertVC = UIAlertController(title: "Whait a second", message: "You already put a pin on the map. \nWould you like to set a new pin?", preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Let's do it!", style: .default, handler: { [unowned self] (_) in
            self.performSegue(withIdentifier: "listToAddNewLocation", sender: (true, self.studentLocationArray))
        }))
        
        alertVC.addAction(UIAlertAction.init(title: "No thanks!", style: .default, handler: nil))
        
        present(alertVC, animated: true, completion: nil)
    }
    
    //MARK:- Getting Student Data
    
    func getStudentData() {
        UdacityAPIClient.getStudentLocation(singleStudent: false, completion:{ (data, error) in
            
            DispatchQueue.main.async {
                guard let data = data else {
                    print(error?.localizedDescription ?? "")
                    return
                }
                StudentsLocationData.studentsData = data
                self.studentLocationArray.removeAll()
                self.studentLocationArray.append(contentsOf: StudentsLocationData.studentsData.sorted(by: {$0.updatedAt > $1.updatedAt}))
                self.tableView.reloadData()
                
            }
        })
    }
    
    //MARK:- Refreshing Pin List
    
    @IBAction func refreshListPressed(_ sender: Any) {
        UdacityAPIClient.getStudentLocation(singleStudent: false, completion: { (data, error) in
            guard let data = data else {
                return
            }
            StudentsLocationData.studentsData = data
            self.studentLocationArray.removeAll()
            self.studentLocationArray.append(contentsOf: StudentsLocationData.studentsData.sorted(by: {$0.updatedAt > $1.updatedAt}))
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        })
    }
    
    // MARK:- Logging out User
    
    @IBAction func loggingOut(_ sender: UIBarButtonItem) {
        print("logout pressed")
        UdacityAPIClient.logout {(success: Bool, error: Error?) in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
            print(error?.localizedDescription ?? "")
        }
    }
    
    
    // MARK:- prepare segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listToAddNewLocation" {
            let controller = segue.destination as! AddNewLocationViewController
            let updatePin = sender as? (Bool, [StudentInformation])
            controller.updatePin = updatePin?.0
            controller.studentArray = updatePin?.1
        }
    }
    
    // MARK:- Table View Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")!
        cell.textLabel?.text = studentLocationArray[indexPath.row].firstName + " " + studentLocationArray[indexPath.row].lastName
        cell.detailTextLabel?.text = studentLocationArray[indexPath.row].mediaURL
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocationArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        if let mediaUrl = URL(string: studentLocationArray[indexPath.row].mediaURL) {
            app.open(mediaUrl, options: [:], completionHandler: nil)
        }
    }
}


