//
//  LikesViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 6.12.2019.
//  Copyright © 2019 Bulut. All rights reserved.
//
import SDWebImage
import UIKit
import Firebase
class ListOfUsersViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var images = [String]()
    var names = [String]()
    var ids = [String]()
    
    //Segue
    var choosenId = String()
    var choosenUsername = String()
    var choosenUserPPLink = String()
    var selfProfile = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userListCell", for: indexPath) as! UserListCell
        cell.Name.text = names[indexPath.row]
        cell.userId.text = ids[indexPath.row]
        if images[indexPath.row] == ""{
           cell.picture.image = UIImage(named: "profilePic")
        }
        else{
             cell.picture.sd_setImage(with: URL(string: images[indexPath.row]))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "userListCell", for: indexPath) as! UserListCell
            cell.Name.text = names[indexPath.row]
            cell.userId.text = ids[indexPath.row]
            self.choosenId = ids[indexPath.row]
            self.choosenUsername = names[indexPath.row]
        if images[indexPath.row] == ""{
            cell.picture.image = UIImage(named: "profilePic")
            self.choosenUserPPLink = ""
        }
        else{
            cell.picture.sd_setImage(with: URL(string: images[indexPath.row]))
            self.choosenUserPPLink = images[indexPath.row]
        }
        
        if cell.Name.text == Auth.auth().currentUser?.displayName{
            self.selfProfile = true
           performSegue(withIdentifier: "toSearchedView", sender: nil)
            self.selfProfile = false
        }
        else{
             performSegue(withIdentifier: "toSearchedView", sender: nil)
        }
       
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        if segue.identifier == "toSearchedView"{
          
            let destination = segue.destination as! SearchedProfileViewController
            destination.userID = self.choosenId
            destination.username = self.choosenUsername
            destination.profilePicUrl = self.choosenUserPPLink
            destination.selfProfile = self.selfProfile
        }
       
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    

}
