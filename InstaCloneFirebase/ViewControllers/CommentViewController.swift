//
//  CommentViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 9.10.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
class CommentViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    
        
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: UITextField!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var profilePicTitle: UIImageView!
    @IBOutlet weak var commentTitleLabel: UILabel!

    var postID = String()
    
    var nameTitle = String()
    var commentTitle = String()
    var pictureTitle = String()
    var commentPP = String()
    
    
    var commentID = [String]()
    var usernames = [String]()
    var comments = [String]()
    var profilePic = [String]()
    var likes = [[String]]()
    
    //Segue
    var like = [String]()
    var pics = [String]()
    var ids = [String]()
   
    
    //
   
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
        let attributedString = NSMutableAttributedString(string:nameTitle, attributes:attrs)
        let normalString = NSMutableAttributedString(string:commentTitle)
        attributedString.append(normalString)
        commentTitleLabel.attributedText = attributedString
        commentTitleLabel.sizeToFit()
        profilePicTitle.clipsToBounds = true
        profilePicTitle.layer.cornerRadius = profilePicTitle.bounds.width / 2
        if pictureTitle == ""{
            profilePicTitle.image = UIImage(named: "profilePic")
        }else{
        profilePicTitle.sd_setImage(with: URL(string: pictureTitle))
        }
        if commentTitleLabel.text == ""{
           profilePicTitle.isHidden = true
        }
        getComments()
        NotificationCenter.default.addObserver(self, selector: #selector(getComments), name: NSNotification.Name(rawValue: "commentViewNotif"), object: nil)

        
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if let document = snapshot, document.exists{
                if let commentPP = document.get("profilePicture") as? String{
                    self.commentPP = commentPP
                }
            }
        }
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
       
    }
    
    
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if indexPath == nil {
    
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "popOptions") as! DeleteCommentsViewController
            
            
            nextViewController.selectedComments.append(commentID[indexPath!.row])
          
            
            nextViewController.postID.append(self.postID)
            
            for value in commentID{
                nextViewController.commentID.append(value)
            }
            for value in usernames{
                nextViewController.usernames.append(value)
            }
            for value in comments{
                nextViewController.comments.append(value)
            }
            for value in profilePic{
                nextViewController.profilePic.append(value)
            }
            for value in likes{
                nextViewController.likes.append(value)
            }
            
            
            
            self.present(nextViewController, animated:false, completion:nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "comendCell", for: indexPath) as! CommentCell
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
        let attributedString = NSMutableAttributedString(string:usernames[indexPath.row], attributes:attrs)
        let normalString = NSMutableAttributedString(string:comments[indexPath.row])
        attributedString.append(normalString)
        cell.comment.attributedText = attributedString
        cell.commentID.text = commentID[indexPath.row]
        cell.postID.text = postID
        if profilePic[indexPath.row] == ""{
            cell.picture.image = UIImage(named: "profilePic")
        }
        else{
        cell.picture.sd_setImage(with: URL(string: self.profilePic[indexPath.row]))
        }
        if likes[indexPath.row].count == 0{
            cell.allLikesButton.isHidden = true
        }
        else if likes[indexPath.row].count == 1{
            cell.allLikesButton.setTitle(String("See \(likes[indexPath.row].count) like"), for: .normal)
            cell.allLikesButton.isHidden = false
        }
        else{
            cell.allLikesButton.setTitle(String("See \(likes[indexPath.row].count) likes"), for: .normal)
            cell.allLikesButton.isHidden = false
        }
 
        cell.allLikesButton.tag = indexPath.row //or value whatever you want (must be Int)
        cell.allLikesButton.addTarget(self, action: #selector(CommentViewController.likesButtonAction(_:)), for: UIControl.Event.touchUpInside)
        
        
        
        return cell
   
    }
  
    
   
   
    
    
    @IBAction func commentButtonAction(_ sender: Any) {
        
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        if commentTextView.text != ""{
        let fireStoreDatabase = Firestore.firestore()
            let fireStoreComments = ["comment" : commentTextView.text!, "username" : Auth.auth().currentUser!.displayName! ,"date":FieldValue.serverTimestamp(),
                                     "userPP": self.commentPP] as [String : Any]
        
        fireStoreDatabase.collection("Posts").document(postID).collection("Comments").addDocument(data: fireStoreComments, completion: { (error) in
            self.getComments()
            self.commentTextView.text! = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
            }
        })
    }
        
    }
    
    @objc func likesButtonAction(_ sender:UIButton!) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        let id = commentID[indexPath!.row]
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Posts").document(postID).collection("Comments").document(id).collection("Likes").getDocuments { (snapshot
            , error) in
            
            for document in snapshot!.documents{
                self.like.append(document.get("username") as! String)
                self.ids.append(document.documentID)
                if document.get("userPP") as! String != ""{
                    self.pics.append(document.get("userPP") as! String)
                }
                else{
                    self.pics.append("")
                }
            }
            self.performSegue(withIdentifier: "toUserListVC", sender: nil)
            self.like.removeAll()
            self.pics.removeAll()
            self.ids.removeAll()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserListVC" {
            let destination = segue.destination as! ListOfUsersViewController
            destination.names = self.like
            destination.images = self.pics
            destination.ids = self.ids
        }
    }
    
    @objc func getComments()  {
        self.commentID.removeAll()
        self.comments.removeAll()
        self.usernames.removeAll()
        self.likes.removeAll()
        self.profilePic.removeAll()
        let firestoreDatabase = Firestore.firestore()
        var count = 0.0
        firestoreDatabase.collection("Posts").document(self.postID).collection("Comments").order(by: "date",    descending: true).getDocuments { (snapshot
            ,error) in
            if snapshot?.isEmpty == false{
            for document in snapshot!.documents{
                self.comments.append(document.get("comment") as! String)
                self.usernames.append("\(document.get("username") as! String) : ")
                if document.get("userPP") as! String != ""{
                      self.profilePic.append(document.get("userPP") as! String)
                }
                else{
                    self.profilePic.append("")
                }
                self.commentID.append(document.documentID)
                
                
                count += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + count) {   firestoreDatabase.collection("Posts").document(self.postID).collection("Comments")        .document(document.documentID).collection("Likes").getDocuments(completion: { (snapshot,        error) in
                        var like = [String]()
                        for i in snapshot!.documents{
                            like.append(i.documentID)
                        }
                            self.likes.append(like)
                            like.removeAll()
                            if self.likes.count == self.commentID.count{
                                self.tableView.reloadData()
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                        })
                    }
                }
            }
        }
    }
}
