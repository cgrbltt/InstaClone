//
//  SettingsViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 8.11.2019.
//  Copyright © 2019 Bulut. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class SettingsViewController: UIViewController {
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var EmailAdressLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var UserNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    var userPPLink = String()
    var username = String()
    var useremail = String()
    
    
    var usernames = [String]()
    var taken = false
    var oldname = String()
    var newlikes = [String]()
    var documentID = [String]()
    
    var fromSearchVC = false
   
    
    override func viewDidLoad() {
        UIApplication.shared.endIgnoringInteractionEvents()
        super.viewDidLoad()
        profilePic.layer.cornerRadius = profilePic.bounds.width / 2
        profilePic.clipsToBounds = true
        profilePic.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        profilePic.addGestureRecognizer(gestureRecognizer)
        if userPPLink == ""{
            profilePic.image = UIImage(named: "profilePic")
        }
        else{
              profilePic.sd_setImage(with: URL(string: userPPLink))
        }
        UserNameLabel.text = username
        EmailAdressLabel.text = useremail
        
        if fromSearchVC == true{
            setNavigationBar()
        }
        /*
        NotificationCenter.default.addObserver(self, selector: #selector(getPhoto), name: NSNotification.Name(rawValue: "settingsNotif"), object: nil)
 */
    }
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 30, width: screenSize.width, height: 44))
        let navItem = UINavigationItem(title: "")
        let doneItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction))
       
        navItem.leftBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
    }
    
    @objc func backAction() {
        self.dismiss(animated: false, completion: nil)
    }
    /*
    @objc func getPhoto(){
         let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            
                if let profilePicture = snapshot!.get("profilePicture") as? String{
                    self.profilePic.sd_setImage(with: URL(string: profilePicture))
                }
            else{
                self.profilePic.image = UIImage(named: "profilePic")
            }
        }
    }
   */
  
   
    @objc func chooseImage(){
        let popOptionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popOptions") as! OptionsViewController
        popOptionsVC.buttonNames.append("Change Profile Picture")
        popOptionsVC.buttonNames.append("Remove Profile Picture")
        self.addChild(popOptionsVC)
        popOptionsVC.view.frame = self.view.frame
        self.view.addSubview(popOptionsVC.view)
        popOptionsVC.didMove(toParent: self)
        
        let fireBaseData = Firestore.firestore()
            fireBaseData.collection("Posts").whereField("postedBy", isEqualTo: Auth.auth().currentUser!.displayName!).getDocuments { (snapshot, error) in
                for document in snapshot!.documents{
                    popOptionsVC.ID.append(document.documentID)
                }
            }
       
        
       
    }
    @IBAction func logoutClicked(_ sender: Any) {
        do{
          try Auth.auth().signOut()
            performSegue(withIdentifier: "toViewController", sender: nil)
            
        }
        catch{
            print("Error")
        }
    }
    
    @IBAction func SaveChangesButton(_ sender: Any) {
    
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("Users").getDocuments { (snapshot, error) in
            if snapshot?.isEmpty == false {
                    for document in snapshot!.documents {
                        if let username = document.get("username") as? String {
                            self.usernames.append(username)
                        }
                    }
                }
        }//getUserNames
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        if self.UserNameText.text! != ""  {
                for name in self.usernames {
                    if self.UserNameText.text == name {
                        self.makeAlert(titleInput: "Error", messageInput: "Username is taken")
                        self.taken = true
                    }
                }
        if self.taken == false{
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    self.oldname = Auth.auth().currentUser!.displayName!
                    
                    changeRequest.displayName = self.UserNameText.text
                    changeRequest.commitChanges { (error) in
                
                            fireStoreDatabase.collection("Posts").getDocuments(completion: { (snapshot, error) in
                      
                                for postDocument in snapshot!.documents{
                                    if postDocument.get("postedBy") as! String == self.oldname{
                                    postDocument.reference.updateData(["postedBy" : Auth.auth().currentUser!.displayName!])
                                    }
                                    fireStoreDatabase.collection("Posts").document(postDocument.documentID).collection("Comments").getDocuments(completion: { (snapshot, error) in
                                        
                                        for document in snapshot!.documents{
                                            if document.get("username") as! String == self.oldname{
                                                document.reference.updateData(["username" : Auth.auth().currentUser!.displayName!])
                                            }
                                            fireStoreDatabase.collection("Posts").document(postDocument.documentID).collection("Comments").document(document.documentID).collection("Likes").getDocuments(completion: { (snapshot, error) in
                                                
                                                for document in snapshot!.documents{
                                                    if document.get("username") as! String == self.oldname{
                                                        document.reference.updateData(["username" : Auth.auth().currentUser!.displayName!])
                                                    }
                                                }
                                            })
   
                                        }
                                    })
                                    fireStoreDatabase.collection("Posts").document(postDocument.documentID).collection("Likes").getDocuments(completion: { (snapshot, error) in
                                        
                                        for document in snapshot!.documents{
                                            
                                            if document.get("username") as! String == self.oldname{
                                                document.reference.updateData(["username" : Auth.auth().currentUser!.displayName!])
                                                
                                            }

                                            
                                        }
                                        
                                    })
                                }
                            })
                        let user = ["username" : Auth.auth().currentUser!.displayName!] as [String : Any]
                        fireStoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).setData(user, merge: true)
                            self.makeAlert(titleInput: "Success", messageInput: "Username has been change to \(self.UserNameText.text!)")
                            self.UserNameLabel.text! = "Username: \(self.UserNameText.text!)"
                            self.UserNameText.text = ""
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            UIApplication.shared.beginIgnoringInteractionEvents()
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
                            
                        }
                        
                    }
                    
                }
                self.taken = false
                self.usernames.removeAll()
            }//ChangeUserName
        }
        
        if emailText.text! != ""  {
                Auth.auth().currentUser!.updateEmail(to: emailText.text!) { (error) in
                    if error != nil{
                        self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                    }else{
                        
                    
                    let firestoreDatabase =  Firestore.firestore()
                    let user = ["email" : Auth.auth().currentUser!.email!] as [String : Any]
                    firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).setData(user, merge: true)
                        self.EmailAdressLabel.text! = "Email: \(self.emailText.text!)"
                        self.emailText.text! = ""
                    }
                }
    
        }// ChangeEmail
       
       
    
  
        
        
}//SaveChangeButton
    
    func makeAlert(titleInput: String, messageInput:String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
        alert.addAction(okAction)
        self.present(alert,animated: true)
    }

}
