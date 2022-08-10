//
//  UploadStoryViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 9.02.2021.
//  Copyright © 2021 Bulut. All rights reserved.
//

import UIKit
import Firebase
class UploadStoryViewController: UIViewController {

    @IBOutlet weak var story: UIImageView!
    var storyPic = UIImage()
    var userPP = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        story.image = storyPic
        let firestoreDatabase =  Firestore.firestore()
        firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if let document = snapshot, document.exists{
                if let picture = snapshot!.get("profilePicture") as? String{
                    self.userPP = picture
                }
            }
        }

    }
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: false)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        let storage = Storage.storage()
        let storageReferance = storage.reference()
        let mediaFolder = storageReferance.child("media")
        
        if let data = story.image?.jpegData(compressionQuality: 0.5){
            
            let uuid = UUID().uuidString
            
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            imageReferance.putData(data, metadata: nil) { (metadata, error) in

                    imageReferance.downloadURL(completion: { (url, error) in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            let firestoreDatabase =  Firestore.firestore()
                            firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                                if let document = document, document.exists{
                                    let firestorePost = ["imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser!.displayName!,"date": FieldValue.serverTimestamp(),"userID":Auth.auth().currentUser!.uid,"userPP":self.userPP,"Active":true] as [String : Any]
                                    
                                    firestoreDatabase.collection("Stories").addDocument(data: firestorePost, completion: { (error) in
                                       
                                       self.dismiss(animated: false)
                                            UIApplication.shared.beginIgnoringInteractionEvents()
                                            
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
                                        
                                        
                                    })
                                }
                            }
                        }
                    })
                
            }
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
