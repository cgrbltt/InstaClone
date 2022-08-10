//
//  DeleteCommentsViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 8.12.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit
import Firebase
class DeleteCommentsViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
 
    @IBOutlet weak var tableView: UITableView!
    var postID = String()
    var selectedComments = [String]()
    var commentID = [String]()
    var usernames = [String]()
    var comments = [String]()
    var profilePic = [String]()
    var likes = [[String]]()
   
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell", for: indexPath) as! DeleteCommentCell
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
        let attributedString = NSMutableAttributedString(string:usernames[indexPath.row], attributes:attrs)
        let normalString = NSMutableAttributedString(string:comments[indexPath.row])
        attributedString.append(normalString)
        cell.comment.attributedText = attributedString
        cell.commentID.text = commentID[indexPath.row]
        cell.postID.text = postID
        cell.profilePic.sd_setImage(with: URL(string: self.profilePic[indexPath.row]))
        if likes[indexPath.row].count == 0{
            cell.likeslbl.isHidden = true
        }
        else if likes[indexPath.row].count == 1{
            cell.likeslbl.setTitle(String("See \(likes[indexPath.row].count) like"), for: .normal)
            cell.likeslbl.isHidden = false
        }
        else{
            cell.likeslbl.setTitle(String("See \(likes[indexPath.row].count) likes"), for: .normal)
            cell.likeslbl.isHidden = false
        }
        if selectedComments.contains(commentID[indexPath.row]){
            cell.backgroundColor = UIColor.init(red: 0.67, green: 0.84, blue: 0.90, alpha: 1)
        }

        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        var exist = false
        
            
    
        
        
        let selectedID = commentID[indexPath.row]
        for id in selectedComments {
            if id == selectedID {
                selectedComments.remove(at: selectedComments.firstIndex(of: id)!)
                exist = true
                cell?.backgroundColor = .white
                tableView.reloadData()
            }
        }
        if exist == false{
            selectedComments.append(selectedID)
            cell?.backgroundColor = UIColor.init(red: 0.67, green: 0.84, blue: 0.90, alpha: 1)
            tableView.reloadData()
        }
    }
    
    
    
    
    
    @IBAction func controlAction(_ sender: Any) {
        
        let firebaseDataStore = Firestore.firestore()
        for id in selectedComments{
            firebaseDataStore.collection("Posts").document(postID).collection("Comments").document(id).collection("Likes").getDocuments { (snapshot, error) in
                
                for document in snapshot!.documents{
            firebaseDataStore.collection("Posts").document(self.postID).collection("Comments").document(id).collection("Likes").document(document.documentID)
                }
            }
            firebaseDataStore.collection("Posts").document(postID).collection("Comments").document(id).delete()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "commentViewNotif"), object: nil)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        selectedComments.removeAll()
        commentID.removeAll()
        usernames.removeAll()
        comments.removeAll()
        profilePic.removeAll()
        likes.removeAll()
        self.dismiss(animated: false, completion: nil)
    }
}
