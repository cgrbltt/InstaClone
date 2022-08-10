//
//  ListOfPostsCell.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 16.01.2021.
//  Copyright © 2021 Bulut. All rights reserved.
//

import UIKit
import Firebase
class ListOfPostsCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var postCommentLabel: UILabel!
    @IBOutlet weak var postedImage: UIImageView!
    @IBOutlet weak var likeButtonLabel: UIButton!
    @IBOutlet weak var commentButtonLabel: UIButton!
    @IBOutlet weak var likesButtonLabel: UIButton!
    @IBOutlet weak var documentID: UILabel!
    @IBOutlet weak var allCommentsButton: UIButton!
    @IBOutlet weak var OptionsButtonLabel: UIButton!
    
    
    var likePPLink = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.clipsToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.bounds.width / 2
        
        
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
    @IBAction func likeActionButton(_ sender: Any) {
        let fireStoreDatabase = Firestore.firestore()
        
        
        
        fireStoreDatabase.collection("Posts").document(documentID.text!).collection("Likes").getDocuments { (snapshot, error) in
            
            var exist = false
            
            let currentUserName = Auth.auth().currentUser!.displayName!
            
            for document in snapshot!.documents{
                if document.get("username") as! String == currentUserName{
                    exist = true
                }
            }
            if exist == false{
                
                let fireStoreLikes = ["username" : Auth.auth().currentUser!.displayName!,"userPP" : self.likePPLink] as [String : Any]
                fireStoreDatabase.collection("Posts").document(self.documentID.text!).collection("Likes").addDocument(data: fireStoreLikes, completion: { (error) in
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: ""), object: nil)
                })
            }
            else{
                fireStoreDatabase.collection("Posts").document(self.documentID.text!).collection("Likes").getDocuments { (snapshot, error) in
                    for document in snapshot!.documents{
                        
                        if document.get("username") as! String == Auth.auth().currentUser!.displayName!{ fireStoreDatabase.collection("Posts").document(self.documentID.text!).collection("Likes").document(document.documentID).delete()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                print("sinyal algılandı")
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ""), object: nil)
                            }
                        }
                    }
                }
            }
            
        }
    }

    @IBAction func commentButtonAction(_ sender: Any) {
    }
    @IBAction func commentsButtonAction(_ sender: Any) {
    }
    @IBAction func optionsButtonAction(_ sender: Any) {
    }
}
