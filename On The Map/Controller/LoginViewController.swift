//
//  ViewController.swift
//  On The Map
//
//  Created by Heiner Bruß on 30.05.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpNewUserButton: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.isHidden = true
        emailTextField.becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK:- Logging in User
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        activityView.isHidden = false
        activityView.startAnimating()
        UdacityAPIClient.login(email: emailTextField.text!, password: passwordTextField.text!, completion: handleLoginResponse(success:error:))
    }
    
    
    // MARK:- Register new User profile
    
    @IBAction func registerNewUserPressed(_ sender: UIButton) {
        let signUpUrl = URL(string: "https://auth.udacity.com/sign-up")!
        UIApplication.shared.open(signUpUrl, options: [:], completionHandler: nil)
    }

    func handleLoginResponse(success: Bool, error: Error?) {
        if success {
            performSegue(withIdentifier: "loginToTabBar", sender: nil)
            activityView.stopAnimating()
            activityView.isHidden = true
        }
        else {
            showUserLoginError(message: error?.localizedDescription ?? "Please enter a valid email and password")
            activityView.stopAnimating()
            activityView.isHidden = true
        }
    }
    // MARK:- Show Login Error Message
    
    func showUserLoginError(message: String) {
        let alertVC = UIAlertController(title: "Your Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
}

// MARK:- Dismiss Keyboard when Tapped outside

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
}
