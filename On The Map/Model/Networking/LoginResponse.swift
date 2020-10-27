//
//  LoginResponse.swift
//  On The Map
//
//  Created by Heiner Bruß on 27.05.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import Foundation


struct LoginResponse: Codable {
    
    let account: Account
    let session: Session
}
