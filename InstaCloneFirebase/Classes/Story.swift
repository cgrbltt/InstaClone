




import Foundation
import Firebase
class Story {
    var storyId:String
    var postedBy:String
    var userPPlink:String
    var date:Date
    var postedImagelink:String
   
    
    
    init(storyId:String,postedBy:String,userPPlink:String,date:Date,postedImagelink:String){
        self.storyId = storyId
        self.postedBy = postedBy
        self.userPPlink = userPPlink
        self.date = date
        self.postedImagelink = postedImagelink
    }
    init(){
        self.storyId = ""
        self.postedBy = ""
        self.userPPlink = ""
        self.date = Date()
        self.postedImagelink = ""
    }
}
