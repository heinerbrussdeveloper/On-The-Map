//
//  UdacityUserProfile.swift
//  On The Map
//
//  Created by Heiner Bruß on 27.05.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import Foundation



struct UdacityUserProfile: Codable {
    let firstName: String
    let lastName: String
    let key: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case key
    }
}
