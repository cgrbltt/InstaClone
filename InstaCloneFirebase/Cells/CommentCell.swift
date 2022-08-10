//
//  CommentCell.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 9.10.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit
import Firebase
class CommentCell: UITableViewCell {

    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var allLikesButton: UIButton!
    @IBOutlet weak var commentID: UILabel!
    @IBOutlet weak var postID: UILabel!
    var likePPLink = String()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        comment.sizeToFit()
        picture.clipsToBounds = true
        picture.layer.cornerRadius = picture.bounds.width / 2
        
        let Firebase = Firestore.firestore()
        
        Firebase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if let picture = snapshot?.get("profilePicture") as? String{
                self.likePPLink = picture
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeButton(_ sender: Any) {
        let fireStoreDatabase = Firestore.firestore()
      fireStoreDatabase.collection("Posts").document(postID.text!).collection("Comments").document(commentID.text!).collection("Likes").getDocuments { (snaphot, error) in
            
            let currenUserName = Auth.auth().currentUser!.displayName!
            var exist = false
            
            for document in snaphot!.documents{
                
                if document.get("username") as! String == currenUserName{
                    exist = true
                }
            
            }
            if exist == false{
                let firestorePost = ["username" : Auth.auth().currentUser!.displayName!,"userPP" : self.likePPLink] as [String : Any]
                fireStoreDatabase.collection("Posts").document(self.postID.text!).collection("Comments").document(self.commentID.text!).collection("Likes").addDocument(data: firestorePost)
            }
            else{
                
                fireStoreDatabase.collection("Posts").document(self.postID.text!).collection("Comments").document(self.commentID.text!).collection("Likes").getDocuments(completion: { (snapshot, error) in
                    
                    for document in snapshot!.documents{
                        if document.get("username") as? String == Auth.auth().currentUser!.displayName{
                            fireStoreDatabase.collection("Posts").document(self.postID.text!).collection("Comments").document(self.commentID.text!).collection("Likes").document(document.documentID).delete()
                        }
                     }
                    
                })
            }
        }
          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "commentViewNotif"), object: nil)
    }
}
