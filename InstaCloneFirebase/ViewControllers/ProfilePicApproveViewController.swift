//
//  ProfilePicApprove.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 13.07.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ProfilePicApproveViewController: UIViewController {
    var oldImage = String()
    @IBOutlet weak var picture: UIImageView!
    var newImage: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        picture.image = newImage
        
        let menu_button_ = UIBarButtonItem(title: "Approve",
                                           style: UIBarButtonItem.Style.plain ,
                                           target: self, action: Selector("Approve"))
        self.navigationItem.rightBarButtonItem = menu_button_
        
       
        
        
       
         let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists{
                if let profilePicture = document.get("profilePicture") as? String{
                    
                    self.oldImage = profilePicture
        
                }
            }
        }//SavePicture
        
        
        
        

        
        
        
    }
   
    
    @objc func Approve(){
        
        
            if self.picture.image != UIImage(named: "profilePic"){
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let storage = Storage.storage()
            let storageReferance = storage.reference()
            let mediaFolder = storageReferance.child("profilePictures")
            
                if let data = self.picture.image?.jpegData(compressionQuality: 0.5){
                
                let uuid = UUID().uuidString
                let imageReferance = mediaFolder.child("\(uuid).jpg")
                imageReferance.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil{
                        self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                    }
                    else{
                        
                        imageReferance.downloadURL(completion: { (url, error) in
                            if error == nil {
                              let  imageUrl = url?.absoluteString
                                
                                let firestoreDatabase = Firestore.firestore()
                            
                                
                                
                                
                                let user = ["profilePicture" : imageUrl!] as [String : Any]
                                
                          
                                firestoreDatabase.collection("Posts").getDocuments(completion: { (snapshot ,error) in
                                    
                                    for document in snapshot!.documents{
                                        if Auth.auth().currentUser!.displayName! == document.get("postedBy") as? String{
                                        document.reference.updateData([
                                            "userPP": imageUrl!
                                            ])
                                        }
                                        
                                        firestoreDatabase.collection("Posts").document(document.documentID).collection("Comments").getDocuments(completion: { (snapshot, error) in
                                            
                                            for commentDocument in snapshot!.documents{
                                                 if Auth.auth().currentUser!.displayName! == commentDocument.get("username") as? String{
                                                commentDocument.reference.updateData([
                                                    "userPP": imageUrl!
                                                    ])
                                                }
                                            
                                                firestoreDatabase.collection("Posts").document(document.documentID).collection("Comments").document(commentDocument.documentID).collection("Likes").getDocuments(completion: { (snapshot, error) in
                                                    
                                                    for document in snapshot!.documents{
                                                        if Auth.auth().currentUser!.displayName! == document.get("username") as? String{
                                                            document.reference.updateData([
                                                                "userPP": imageUrl!
                                                                ])
                                                        }
                                                    }
                                                    
                                                })
                                            }
                                        })
                                        
                                        firestoreDatabase.collection("Posts").document(document.documentID).collection("Likes").getDocuments(completion: { (snapshot, error) in
                                            
                                            for document in snapshot!.documents{
                                                 if Auth.auth().currentUser!.displayName! == document.get("username") as? String{
                                                    document.reference.updateData([
                                                        "userPP": imageUrl!
                                                        ])
                                                }
                                            }
                                            
                                        })
                                    
                                    }
                                    
                                })
                            
                                
                                
                                firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).setData(user, merge: true)
                                
                              
                             
                                
                                self.navigationController?.popViewController(animated: true)
                             
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "settingsNotif"), object: nil)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissOptions"), object: nil)
                                }
                                
                                
                                
                            }
                        })
                        
                        
                        
                    }
                }
            }
             
               
        }
            
        
    }//Approve
   

   
    
    
    
    

    func makeAlert(titleInput: String, messageInput:String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
        alert.addAction(okAction)
        self.present(alert,animated: true)
    }
}
