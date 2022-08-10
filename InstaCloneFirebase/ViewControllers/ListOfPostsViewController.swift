//
//  ListOfPosts.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 16.01.2021.
//  Copyright © 2021 Bulut. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class ListOfPostsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var postID = String()
    var titleComment = String()
    var titleName = String()
    var titlePicture = String()
    
    
    
    
    var userID = String()
    var posts = [Post]()
    var commentArray = [[String]]()
    var likeArray = [[String]]()
    
    //Segue
    var ids = [String]()
    var likeImages = [String]()
    var likeNames = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Users").document(self.userID).getDocument { (snapshot, error) in
            self.posts.removeAll()
            let name = snapshot!.get("username") as! String
           
            firestoreDatabase.collection("Posts").whereField("postedBy", isEqualTo: name).getDocuments(completion: { (snapshot, error) in
                for document in snapshot!.documents{
                    let post = Post(postID: document.documentID, postedBy: document.get("postedBy") as! String, userPPlink:document.get("userPP") as! String, date: (document.get("date") as! Timestamp).dateValue(), postedImagelink: document.get("imageUrl") as! String, postcomment: document.get("postComment") as! String)
                    
                    self.posts.append(post)
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.getLikes()
                self.getComments()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
              self.tableView.reloadData()
            }
        }//Get Posts of searched profile
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListOfPostsCell", for: indexPath) as! ListOfPostsCell
        cell.userNameLabel.text! = self.posts[indexPath.row].postedBy
        cell.postedImage.sd_setImage(with: URL(string: self.posts[indexPath.row].postedImagelink))
        cell.postCommentLabel.text! = posts[indexPath.row].postcomment
        if posts[indexPath.row].userPPlink == ""{
            cell.profilePicture.image = UIImage(named: "profilePic")
        }
        else{
            cell.profilePicture.sd_setImage(with: URL(string: self.posts[indexPath.row].userPPlink))
        }
        cell.documentID.text = posts[indexPath.row].postID
        cell.likesButtonLabel.tag = indexPath.row
        cell.likesButtonLabel.addTarget(self, action: #selector(likesButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        if likeArray[indexPath.row].count == 0{
            cell.likesButtonLabel.isHidden = true
        }
        else if likeArray[indexPath.row].count == 1{
            cell.likesButtonLabel.setTitle(String("See \(likeArray[indexPath.row].count) like"), for: .normal)
            cell.likesButtonLabel.isHidden = false
        }
        else{
            cell.likesButtonLabel.setTitle(String("See \(likeArray[indexPath.row].count) likes"), for: .normal)
            cell.likesButtonLabel.isHidden = false
        }
        if commentArray[indexPath.row].count == 0{
            cell.allCommentsButton.isHidden = true
        }
        else if commentArray[indexPath.row].count == 1{
            cell.allCommentsButton.setTitle(String("See \(commentArray[indexPath.row].count) comment"), for: .normal)
        }
        else{
            cell.allCommentsButton.setTitle(String("See \(commentArray[indexPath.row].count) comments"), for: .normal)
        }
        cell.commentButtonLabel.tag = indexPath.row
        cell.commentButtonLabel.addTarget(self, action: #selector(FeedViewController.commentButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        cell.allCommentsButton.tag = indexPath.row
        cell.allCommentsButton.addTarget(self, action: #selector(FeedViewController.commentButtonTapped(_:)), for: UIControl.Event.touchUpInside)

            return cell
        }
    
    @objc func likesButtonTapped(_ sender:UIButton!) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        let id = posts[indexPath!.row].postID
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("Posts").document(id).collection("Likes").getDocuments { (snapshot
            , error) in
            for document in snapshot!.documents{
                self.likeNames.append(document.get("username") as! String)
                if document.get("userPP") as! String != ""{
                    self.likeImages.append(document.get("userPP") as! String)
                }
                else{
                    self.likeImages.append("")
                }
            }
            self.performSegue(withIdentifier: "toUserListVC", sender: nil)
            self.likeNames.removeAll()
            self.likeImages.removeAll()
            self.ids.removeAll()
        }
    }
    @objc func commentButtonTapped(_ sender:UIButton!) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        self.postID = posts[indexPath!.row].postID
        self.titleComment = posts[indexPath!.row].postcomment
        self.titleName = posts[indexPath!.row].postedBy
        self.titlePicture = posts[indexPath!.row].userPPlink
        self.performSegue(withIdentifier: "toCommentsVC", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserListVC"{
            let destination = segue.destination as! ListOfUsersViewController
            destination.ids = self.ids
            destination.names = self.likeNames
            destination.images = self.likeImages
        }
        if segue.identifier == "toCommentsVC" {
            let destination = segue.destination as! CommentViewController
            
            destination.postID = self.postID
            destination.commentTitle = self.titleComment
            if self.titleComment != ""{
                destination.nameTitle = "\(self.titleName) : "
            }
            destination.pictureTitle = self.titlePicture
        }
    }
    func getComments(){
        var count = 0.0
        for postID in self.posts{
            count += 0.5
            let firestoreDatabase = Firestore.firestore()
            DispatchQueue.main.asyncAfter(deadline: .now() + count) {
                firestoreDatabase.collection("Posts").document(postID.postID).collection("Comments").getDocuments(completion: { (snapshot, error) in
                    
                    var comments = [String]()
                    for document in snapshot!.documents{
                        comments.append(document.get("comment") as! String)
                    }
                    self.commentArray.append(comments)
                    comments.removeAll()
                })
                
            }
        }
        
    }
    func getLikes(){
        var count = 0.0
        for postID in self.posts{
            count += 0.5
            let firestoreDatabase = Firestore.firestore()
            DispatchQueue.main.asyncAfter(deadline: .now() + count) {
                firestoreDatabase.collection("Posts").document(postID.postID).collection("Likes").getDocuments(completion: { (snapshot, error) in
                    var likes = [String]()
                    for document in snapshot!.documents{
                        likes.append(document.get("username") as! String)
                    }
                    self.likeArray.append(likes)
                    
                    likes.removeAll()
                })
            }
        }
    }

   
}
