//
//  User.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 24.12.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import Foundation
import Firebase
class User {
    var userID:String
    var userEmail:String
    var userName:String

    var userProfilePicture:String
    
    init(userID: String,userEmail: String,userName: String,userProfilePicture:String){
        self.userID = userID
        self.userEmail = userEmail
        self.userName = userName
        self.userProfilePicture = userProfilePicture
  
    }
    init(){
        self.userID = ""
        self.userEmail = ""
        self.userName = ""
        self.userProfilePicture = ""
    }
    
    

    
    
    
    
    
}
