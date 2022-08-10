//
//  UploadViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 8.11.2019.
//  Copyright © 2019 Bulut. All rights reserved.
//

import UIKit
import Firebase
class UploadViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var userPP = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        

        
        let firestoreDatabase =  Firestore.firestore()
        firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if let document = snapshot, document.exists{
                if let picture = snapshot!.get("profilePicture") as? String{
                self.userPP = picture
                }
            }
        }
        
    }
    
    @objc func chooseImage(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController,animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert,animated: true)
    }
    @IBAction func actionButtonClicked(_ sender: Any) {
   
    let storage = Storage.storage()
        let storageReferance = storage.reference()
        let mediaFolder = storageReferance.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            
            let uuid = UUID().uuidString
            
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            imageReferance.putData(data, metadata: nil) { (metadata, error) in
                if error != nil{
                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                }
                else{
                    
                    imageReferance.downloadURL(completion: { (url, error) in
                    if error == nil {
                        let imageUrl = url?.absoluteString
                        let firestoreDatabase =  Firestore.firestore()
                        firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                            if let document = document, document.exists{
                                let firestorePost = ["imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser!.displayName!,"postComment" : self.commentText.text!,"date": FieldValue.serverTimestamp(),"userPP": self.userPP,"Active": true] as [String : Any]
                                
                                    firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                        if error != nil{
                                            self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                                        }
                                        else{
                                      UIApplication.shared.beginIgnoringInteractionEvents()
                                            self.imageView.image = UIImage(named: "indir")
                                            self.commentText.text = ""
                                           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
                                            self.tabBarController?.selectedIndex = 0
                                        }
                                    })
                                }
                            }
                        }
                    })
                }
            }
        }
    }
}
