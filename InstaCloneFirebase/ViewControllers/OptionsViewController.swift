//
//  OptionsViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 30.11.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit
import Firebase


class OptionsViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn: UIButton!
    
    var buttonNames = [String]()
    var ID = [String]()
    var choosenImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
    }
    @objc func dismissOnTapOutside(){
        self.view.removeFromSuperview()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath) as! OptionsCell
        cell.buttonLabel.setTitle(buttonNames[indexPath.row], for: .normal)
        if cell.buttonLabel.titleLabel!.text == "Stop Following"{
            cell.buttonLabel.setTitleColor(.red, for: .normal)
        }
        cell.buttonLabel.tag = indexPath.row
        cell.buttonLabel.addTarget(self, action: #selector(OptionsViewController.optionsButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
   
    @objc func optionsButtonTapped(_ sender:UIButton!){
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if buttonNames[indexPath!.row] == "Delete"{
             UIApplication.shared.beginIgnoringInteractionEvents()
            let fireBaseData = Firestore.firestore()

            fireBaseData.collection("Posts").document(self.ID[0]).collection("Likes").getDocuments { (snapshot, error) in
                
                for document in snapshot!.documents{
          fireBaseData.collection("Posts").document(self.ID[0]).collection("Likes").document(document.documentID).delete()
                }
            }//Delete Likes
            
            fireBaseData.collection("Posts").document(self.ID[0]).collection("Comments").getDocuments { (snapshot, error) in
                
                for document in snapshot!.documents{
                    fireBaseData.collection("Posts").document(self.ID[0]).collection("Comments").document(document.documentID).delete()
                }
            }//Delete Comments
            fireBaseData.collection("Posts").document(self.ID[0]).delete()//Delete Post
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
             self.view.removeFromSuperview()
                 UIApplication.shared.beginIgnoringInteractionEvents()
            }
        }
        if buttonNames[indexPath!.row] == "More"{
            print("More")
    }
        if buttonNames[indexPath!.row] == "Remove Profile Picture"{
            let fireBaseData = Firestore.firestore()
            
            fireBaseData.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["profilePicture" : FieldValue.delete()]) { (error) in
                for post in self.ID{
                    fireBaseData.collection("Posts").document(post).updateData(["userPP" : ""], completion: { (error) in
                        fireBaseData.collection("Posts").document(post).collection("Likes").getDocuments(completion: { (snapshot, error) in
                            for document in snapshot!.documents{
                                fireBaseData.collection("Posts").document(post).collection("Likes").document(document.documentID).updateData(["userPP" : ""], completion: { (error) in
                                    fireBaseData.collection("Posts").document(post).collection("Comments").getDocuments(completion: { (snapshot, error) in
                                        for commentDocument in snapshot!.documents{
                                            fireBaseData.collection("Posts").document(post).collection("Comments").document(commentDocument.documentID).updateData(["userPP" : ""], completion: { (error) in
                                                
                                                fireBaseData.collection("Posts").document(post).collection("Comments").document(commentDocument.documentID).collection("Likes").getDocuments(completion: { (snapshot, error) in
                                                    for document in snapshot!.documents{
                                                        fireBaseData.collection("Posts").document(post).collection("Comments").document(commentDocument.documentID).collection("Likes").document(document.documentID).updateData(["userPP" : ""], completion: { (error) in
                                                        })
                                                     
                                                    }
                                                })
                                            })
                                        }
                                    })
                                })
                            }
                        })
                    })
                }
            
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "settingsNotif"), object: nil)
            self.view.removeFromSuperview()
            }
        }
        if buttonNames[indexPath!.row] == "Change Profile Picture"{
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            present(pickerController,animated: true)
            NotificationCenter.default.addObserver(self, selector: #selector(dismissView), name: NSNotification.Name(rawValue: "dismissOptions"), object: nil)
        }
        if buttonNames[indexPath!.row] == "Stop Following"{
           let firestoreDatabase = Firestore.firestore()
            firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Follows").document(ID[0]).delete()
            firestoreDatabase.collection("Users").document(ID[0]).collection("Followers").document(Auth.auth().currentUser!.uid).delete()
            
            
            print("takibi bırak")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SearchProfileViewController"), object: nil)
            self.view.removeFromSuperview()
        }
       
}
    @objc func dismissView()  {
       self.view.removeFromSuperview()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tp: UIImage = info[.originalImage] as! UIImage
            self.choosenImage = tp
            picker.dismiss(animated: true){
            self.performSegue(withIdentifier: "toPic", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPic" {
            let viewController = segue.destination as! ProfilePicApproveViewController
            viewController.newImage = choosenImage
        }
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
    }
    
}
