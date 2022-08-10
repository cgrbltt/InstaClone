//
//  FeedCell.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 19.11.2019.
//  Copyright © 2019 Bulut. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class FeedCell: UITableViewCell {

    

    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var profilePicture: UIButton!
    @IBOutlet weak var postCommentLabel: UILabel!
    @IBOutlet weak var allCommentsButtonLabel: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likesLabel: UIButton!
    @IBOutlet weak var commentButtonlabel: UIButton!
    @IBOutlet weak var optionsButtonLabel: UIButton!
    @IBOutlet weak var documentIDLabel: UILabel!
  
    
    var likePPLink = String()
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.clipsToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.bounds.width / 2
        optionsButtonLabel.clipsToBounds = true
        optionsButtonLabel.layer.cornerRadius = optionsButtonLabel.bounds.width / 2
        
      let Firebase = Firestore.firestore()
        
        Firebase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if let picture = snapshot?.get("profilePicture") as? String{
                self.likePPLink = picture
            }
        }
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }

    @IBAction func likeActionButton(_ sender: Any) {
        let fireStoreDatabase = Firestore.firestore()

       
        
        fireStoreDatabase.collection("Posts").document(documentIDLabel.text!).collection("Likes").getDocuments { (snapshot, error) in
            
            var exist = false
            
            let currentUserName = Auth.auth().currentUser!.displayName!
            
            for document in snapshot!.documents{
                if document.get("username") as! String == currentUserName{
                    exist = true
                }
            }
            if exist == false{
                
                let fireStoreLikes = ["username" : Auth.auth().currentUser!.displayName!,"userPP" : self.likePPLink] as [String : Any]
                fireStoreDatabase.collection("Posts").document(self.documentIDLabel.text!).collection("Likes").addDocument(data: fireStoreLikes, completion: { (error) in
                
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
                })
            }
            else{
                fireStoreDatabase.collection("Posts").document(self.documentIDLabel.text!).collection("Likes").getDocuments { (snapshot, error) in
                    for document in snapshot!.documents{
                        
                        if document.get("username") as! String == Auth.auth().currentUser!.displayName!{ fireStoreDatabase.collection("Posts").document(self.documentIDLabel.text!).collection("Likes").document(document.documentID).delete()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                print("sinyal algılandı")
                          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
                            }
                        }
                    }
                }
            }
          
        }
    }


    @IBAction func likesActionButton(_ sender: Any) {}
    @IBAction func commentActionButton(_ sender: Any) {}
    @IBAction func allCommentsActionButton(_ sender: Any) {}
    @IBAction func optionsButtonAction(_ sender: Any) {}
    @IBAction func toProfileViewAction(_ sender: Any) {}
    @IBAction func toProfileViewUsernameAction(_ sender: Any) {}
    
    
    
        
    
    
}
