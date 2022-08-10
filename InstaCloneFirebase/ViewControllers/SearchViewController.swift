//
//  SearchViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 20.12.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//
import UIKit
import SDWebImage
import Firebase
class SearchViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate,UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Bar: UISearchBar!
    
    var profiles : [User] = []
    var filteredID : [String] = []
    var filteredNames: [String] = []
    var filteredPics: [String] = []
    
    // Segue
    var userID = String()
    var username = String()
    var profilePicUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        Bar.delegate = self
        
        
        
        let firestoreDatabase = Firestore.firestore()
            firestoreDatabase.collection("Users").getDocuments { (snapshot, error) in
            for document in snapshot!.documents{
                if let picture = document.get("profilePicture") as? String{
                    let user = User(userID: document.documentID, userEmail: "", userName: document.get("username") as! String, userProfilePicture: picture)
                    self.profiles.append(user)
                }
                else{
                    let user = User(userID: document.documentID, userEmail: "", userName: document.get("username") as! String, userProfilePicture: "")
                    self.profiles.append(user)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        cell.userName.text = filteredNames[indexPath.row]
        cell.userID.text = filteredID[indexPath.row]
        if  filteredPics[indexPath.row] == ""{
            cell.profilePic.image = UIImage(named: "profilePic")
        }
        else{
            cell.profilePic.sd_setImage(with: URL(string: filteredPics[indexPath.row]))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNames.count
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNames = []
        filteredPics = []
        filteredID = []
        for profile in profiles{
            if profile.userName.lowercased().contains(searchText.lowercased()){
                filteredNames.append(profile.userName)
                filteredPics.append(profile.userProfilePicture)
                filteredID.append(profile.userID)
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        cell.userName.text = filteredNames[indexPath.row]
        cell.userID.text = filteredID[indexPath.row]
        if filteredPics[indexPath.row] == ""{
            cell.profilePic.image = UIImage(named: "profilePic")
            self.profilePicUrl = ""
        }
        else{
            cell.profilePic.sd_setImage(with: URL(string: filteredPics[indexPath.row]))
            self.profilePicUrl = filteredPics[indexPath.row]
        }
        self.username = cell.userName.text!
        
        self.userID = cell.userID.text!
        self.performSegue(withIdentifier: "toSearchProfile", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchProfile"{
            let destination = segue.destination as! SearchedProfileViewController
            destination.username = self.username
            destination.userID = self.userID
            if  self.profilePicUrl == ""{
                destination.profilePicUrl = ""
            }
            else{
                destination.profilePicUrl = self.profilePicUrl
            }
            if self.username == Auth.auth().currentUser!.displayName{
                destination.selfProfile = true
            }
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
}

