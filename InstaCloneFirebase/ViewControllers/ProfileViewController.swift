//
//  ProfileViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 29.12.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit
import Firebase
class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate{
    //MotherView
    @IBOutlet weak var motherView: UIView!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followerView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followCount: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //PopPost
    @IBOutlet weak var popPost: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userPPImage: UIImageView!
    @IBOutlet weak var postComment: UILabel!
    
    let usernameLabel = UILabel() //Navigation title
    
    var profilePPLink = String()
    var users = [User]()
    var posts = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.settingsButton.setTitle("Profile Settings", for: .normal)
        self.settingsButton.isHidden = false
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if let picture = snapshot!.get("profilePicture") as? String{
                self.profilePPLink = picture
                self.profilePicture.sd_setImage(with: URL(string: self.profilePPLink))
            }
            else{
                self.profilePicture.image = UIImage(named: "profilePic")
            }
        }//Get profilepicture
       
            firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            self.posts.removeAll()
            let name = snapshot!.get("username") as! String
            firestoreDatabase.collection("Posts").whereField("postedBy", isEqualTo: name).getDocuments(completion: { (snapshot, error) in
                for document in snapshot!.documents{
                    let post = Post(postID: document.documentID, postedBy: document.get("postedBy") as! String, userPPlink:document.get("userPP") as! String, date: (document.get("date") as! Timestamp).dateValue(), postedImagelink: document.get("imageUrl") as! String, postcomment: document.get("postComment") as! String)
                    
                    self.posts.append(post)
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.postCount.text = String(self.posts.count)
                self.postCount.isHidden = false
                self.collectionView.reloadData()
            }
        }//Get posts
        
        firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Follows").getDocuments { (snapshot, error) in
            var followCount = [String]()
            for document in snapshot!.documents{
                followCount.append(document.get("username") as! String)
            }
            self.followCount!.text = "\(followCount.count)"
            self.followCount.isHidden = false
        }//Get follows
        firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Followers").getDocuments { (snapshot, error) in
            var followerCount = [String]()
            for document in snapshot!.documents{
                followerCount.append(document.get("username") as! String)
            }
            self.followerCount!.text = "\(followerCount.count)"
            self.followerCount.isHidden = false
        }//Get followers
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        let followerGR = UITapGestureRecognizer(target: self, action: #selector(self.followersTabbed))
        followerView.addGestureRecognizer(followerGR)
        followerView.isUserInteractionEnabled = true
        
        let followGR = UITapGestureRecognizer(target: self, action: #selector(self.followsTabbed))
        followView.addGestureRecognizer(followGR)
        followView.isUserInteractionEnabled = true
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        for view in (self.navigationController?.navigationBar.subviews)!{
            if view == self.usernameLabel{
                view.removeFromSuperview()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if let navigationBar = self.navigationController?.navigationBar {
            let imgBackArrow = UIImage(named: "profilePic")
            navigationBar.backIndicatorImage = imgBackArrow
            navigationBar.backIndicatorTransitionMaskImage = imgBackArrow
            
            let usernameFrame = CGRect(x: 0, y: 0, width: navigationBar.frame.width, height: navigationBar.frame.height)
            usernameLabel.frame = usernameFrame
            usernameLabel.textAlignment = .center
            usernameLabel.text = Auth.auth().currentUser!.displayName!
            navigationBar.addSubview(usernameLabel)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath as IndexPath) as! CollectionViewCell
        cell.postImage.sd_setImage(with: URL(string: posts[indexPath.row].postedImagelink))
        cell.postComment = self.posts[indexPath.row].postcomment
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        performSegue(withIdentifier: "toListOfPosts", sender: nil)
    }
    
    @objc func followersTabbed(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let fireStoreDataBase = Firestore.firestore()
            fireStoreDataBase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Followers").getDocuments { (snapshot, error) in
                for document in snapshot!.documents {
                    fireStoreDataBase.collection("Users").document(document.documentID).getDocument(completion: { (snapshot, error) in
                        if let picture = snapshot!.get("profilePicture") as? String{
                            let user = User(userID: document.documentID, userEmail: "", userName: snapshot!.get("username") as! String, userProfilePicture: picture)
                            self.users.append(user)
                        }
                        else{
                            let user = User(userID: document.documentID, userEmail: "", userName: snapshot!.get("username") as! String, userProfilePicture: "")
                            self.users.append(user)
                        }
                    })
                    
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.performSegue(withIdentifier: "toUserListVC", sender: nil)
            }
        }
    }
    
    
    @objc func followsTabbed(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let fireStoreDataBase = Firestore.firestore()
            fireStoreDataBase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Follows").getDocuments { (snapshot, error) in
                for document in snapshot!.documents {
                    fireStoreDataBase.collection("Users").document(document.documentID).getDocument(completion: { (snapshot, error) in
                        if let picture = snapshot!.get("profilePicture") as? String{
                            let user = User(userID: document.documentID, userEmail: "", userName: snapshot!.get("username") as! String, userProfilePicture: picture)
                            self.users.append(user)
                        }
                        else{
                            let user = User(userID: document.documentID, userEmail: "", userName: snapshot!.get("username") as! String, userProfilePicture: "")
                            self.users.append(user)
                        }
                    })
                    
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.performSegue(withIdentifier: "toUserListVC", sender: nil)
            }
        }
    }
    
    
    @IBAction func settingsButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "toProfileVC", sender: nil )
    }
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        var workOnce = true
        
        
        if gestureReconizer.state == .began{
            if workOnce == true{
                let point = gestureReconizer.location(in: self.collectionView)
                let indexPath = self.collectionView.indexPathForItem(at: point)
                self.postImage.sd_setImage(with: URL(string: posts[indexPath!.row].postedImagelink))
                if self.profilePPLink == ""{
                    self.userPPImage.image = UIImage(named: "profilePic")
                }
                else{
                    self.userPPImage.sd_setImage(with: URL(string: profilePPLink))
                }
                self.userName.text! = Auth.auth().currentUser!.displayName!
                self.postComment.text! = self.posts[indexPath!.row].postcomment
                
                
                self.popPost.isHidden = false
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.motherView.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.motherView.addSubview(blurEffectView)
            }
            workOnce = false
        }
        if gestureReconizer.state == .ended{
            for subview in self.motherView.subviews where subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
            self.popPost.isHidden = true
        }
    }//Longpressing the post
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfileVC" {
            let destination = segue.destination as! SettingsViewController
            destination.useremail = Auth.auth().currentUser!.email!
            destination.username = Auth.auth().currentUser!.displayName!
            destination.userPPLink = self.profilePPLink
        }
        if segue.identifier == "toUserListVC" {
            let destination = segue.destination as! ListOfUsersViewController
            var names = [String]()
            var images = [String]()
            var ids = [String]()
            for user in users{
                names.append(user.userName)
                images.append(user.userProfilePicture)
                ids.append(user.userID)
            }
            users.removeAll()
            destination.names = names
            destination.images = images
            destination.ids = ids
        }
        if segue.identifier == "toListOfPosts"{
            let destination = segue.destination as! ListOfPostsViewController
            destination.userID = Auth.auth().currentUser!.uid
        }
    }
    
  

}
