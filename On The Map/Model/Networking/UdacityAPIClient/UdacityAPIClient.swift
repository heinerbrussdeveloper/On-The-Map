//
//  APIClient.swift
//  On The Map
//
//  Created by Heiner Bruß on 27.05.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import Foundation


class UdacityAPIClient {
    struct Auth {
        static var keyAccount = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/"
        case postStudentLocation
        case logout
        case updateStudentLocation(String)
        case getUserData
        case getStudentLocation
        case createSessionId
        
        
        var urlString: String {
            switch self {
            case .postStudentLocation: return Endpoints.base + "StudentLocation"
            case .logout: return Endpoints.base + "session"
            case .updateStudentLocation(let objectID): return Endpoints.base + "StudentLocation/\(objectID)"
            case .getUserData: return Endpoints.base + "users/" + Auth.keyAccount
            case .getStudentLocation: return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .createSessionId: return Endpoints.base + "session"
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    // MARK: - Logging in User
    
    class func login(email: String, password: String, completion: @escaping (Bool, Error?) -> ()){
        var request = URLRequest(url: Endpoints.createSessionId.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    return completion(false, error)
                }
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range)
            print(String(data: newData, encoding: .utf8)!)
            do {
                let responseObject = try JSONDecoder().decode(LoginResponse.self, from: newData)
                DispatchQueue.main.async {
                    self.Auth.sessionId = responseObject.session.id
                    self.Auth.keyAccount = responseObject.account.key
                    completion(true, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    //MARK:- Logging out User
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie}
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
        task.resume()
    }
    
    //MARK:-Getting Student Location
    
    class func getStudentLocation(singleStudent: Bool, completion: @escaping ([StudentInformation]?, Error?) -> Void) {
        let request = URLRequest(url: Endpoints.getStudentLocation.url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    return completion([], error)
                }
                return
            }
            do {
                let requestObject = try JSONDecoder().decode(StudentsLocation.self, from: data)
                DispatchQueue.main.async {
                    completion(requestObject.results, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
        task.resume()
    }
    //MARK:- Getting User Data
    
    class func gettingUserData(completion: @escaping (UdacityUserProfile?, Error?) -> Void) {
        let request = URLRequest(url: Endpoints.getUserData.url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            print(String(data: newData, encoding: .utf8)!)
            do {
                let requestObject = try JSONDecoder().decode(UdacityUserProfile.self, from: newData)
                DispatchQueue.main.async {
                    print(requestObject)
                    completion(requestObject, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    
    //MARK:- Putting Student Location
    
    class func putStudentLocation(objectID: String, postingLocation: PostLocation, completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.updateStudentLocation(objectID).url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = postingLocation
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    return completion(false, error)
                }
                return
            }
            print(String(data: data, encoding: .utf8)!)
            
            do {
                let responseObject = try JSONDecoder().decode(PutLocationResponse.self, from: data)
                DispatchQueue.main.async {
                    print(responseObject)
                    completion(true, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    //MARK:- Posting Student Location
    
    class func postStudentLocation(postingLocation: PostLocation, completion: @escaping (PostLocationResponse?, Error?) -> Void) {
        
        var request = URLRequest(url: Endpoints.postStudentLocation.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = postingLocation
        request.httpBody = try! JSONEncoder().encode(body)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let data = data else { // Handle error…
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            print(String(data: data, encoding: .utf8)!)
            do {
                let responseObject = try JSONDecoder().decode(PostLocationResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
}




