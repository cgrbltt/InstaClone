//
//  Post.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 27.12.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import Foundation
import Firebase
class Post {
    var postID:String
    var postedBy:String
    var userPPlink:String
    var date:Date
    var postedImagelink:String
    var postcomment:String

    
    init(postID:String,postedBy:String,userPPlink:String,date:Date,postedImagelink:String,postcomment:String){
        self.postID = postID
        self.postedBy = postedBy
        self.userPPlink = userPPlink
        self.date = date
        self.postedImagelink = postedImagelink
        self.postcomment = postcomment
    }

}
