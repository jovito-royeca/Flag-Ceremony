//
//  User.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 17/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation
import Firebase

struct User {
  
    let uid: String?
    let email: String?
    let photoUrl: URL?
    let displayName: String?
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
        photoUrl = authData.photoURL
        displayName = authData.displayName
    }
}
