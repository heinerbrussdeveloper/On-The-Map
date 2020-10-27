//
//  StudentInformation.swift
//  On The Map
//
//  Created by Heiner Bruß on 28.05.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import Foundation


struct StudentInformation: Codable {
    
    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Float
    let longitude: Float
    let mapString: String
    let mediaURL: String
    let objectID: String
    let uniqueKey: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case firstName
        case lastName
        case latitude
        case longitude
        case mapString
        case mediaURL
        case objectID = "objectId"
        case uniqueKey
        case updatedAt 
        
    }
}


