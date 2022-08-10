//
//  ViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 7.11.2019.
//  Copyright © 2019 Bulut. All rights reserved.
//

import UIKit
import Firebase
class SignInViewController: UIViewController {
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textUserName: UITextField!
    @IBOutlet weak var textPassword: UITextField!


    var usernames = [String]()
    var taken = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true


    }
    override func viewDidAppear(_ animated: Bool) {
        let fireStoreDatabase = Firestore.firestore()
        self.usernames.removeAll()
        fireStoreDatabase.collection("Users").addSnapshotListener { (snapshot, error) in
            if error != nil {

            }
            else {

                if snapshot?.isEmpty == false {


                    for document in snapshot!.documents {
                        if let username = document.get("username") as? String {
                            self.usernames.append(username)
                        }
                    }
                }
            }
        }//saveUserNames
    }




    @IBAction func signInClicked(_ sender: Any) {


        if textEmail.text != "" && textPassword.text != "" {
            Auth.auth().signIn(withEmail: textEmail.text!, password: textPassword.text!) { (autodata, error) in
                if error != nil {
                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                }
                else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        }
        else {
            makeAlert(titleInput: "Error!", messageInput: "Username/Password?")
        }

    }





    @IBAction func signUpClicked(_ sender: Any) {
        if textEmail.text != "" && textPassword.text != "" && textUserName.text != "" {
            Auth.auth().createUser(withEmail: textEmail.text!, password: textPassword.text!) { (auto, error) in
                if error != nil {
                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                }
                else {

                    let firestoreDatabase = Firestore.firestore()
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()

                    for i in self.usernames {
                        if self.textUserName.text == i {
                            self.makeAlert(titleInput: "Error", messageInput: "Username is taken")
                            self.taken = true

                            let user = Auth.auth().currentUser!

                            user.delete(completion: { (error) in })

                        }
                    }
                    if self.taken == false {
                        changeRequest?.displayName = self.textUserName.text!
                        changeRequest?.commitChanges(completion: { (error) in
                            if error != nil {
                                self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                            }
                            else {
                                let user = ["email": Auth.auth().currentUser!.email!, "username": Auth.auth().currentUser!.displayName!] as [String: Any]
                                firestoreDatabase.collection("Users").document(Auth.auth().currentUser?.uid ?? "error").setData(user)
                                
                                self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                            }
                        })
                    }

                }

            }
            self.taken = false
        }
        else {
            makeAlert(titleInput: "Error!", messageInput: "All tabs must be filled")
        }
    }




    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}

