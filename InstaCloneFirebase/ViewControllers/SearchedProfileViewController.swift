//
//  SearchProfileViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 22.12.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit
import Firebase
class SearchedProfileViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate,UIGestureRecognizerDelegate {
    
    
    
    //PostView
    @IBOutlet weak var popPost: UIView!
    @IBOutlet weak var userPP: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postComment: UILabel!
    
    //MotherView
    @IBOutlet weak var motherView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var PostCount: UILabel!
    @IBOutlet weak var FollowerCount: UILabel!
    @IBOutlet weak var FollowCount: UILabel!
    @IBOutlet weak var ProfilePic: UIImageView!
    @IBOutlet weak var FollowButtonLabel: UIButton!
    @IBOutlet weak var PostView: UIView!
    @IBOutlet weak var FollowerView: UIView!
    @IBOutlet weak var FollowView: UIView!
    
    
    let usernameLabel = UILabel() //Navigation title
    var users = [User]() //Followers or follows
    var posts = [Post]() // Searhed profile's posts
    var userID = String() //Searched profile's id
    var username = String() //Searched profile's username
    var profilePicUrl = String() //Searched profile's profilepicture
    
    
    var selfProfile = false //Cheking if searched profile is currentuser's
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        userPP.clipsToBounds = true
        userPP.layer.cornerRadius = userPP.bounds.width / 2
        
        let firestoreDatabase = Firestore.firestore()
        
        if profilePicUrl == ""{
            ProfilePic.image = UIImage(named: "profilePic")
        }
        else{
           ProfilePic.sd_setImage(with: URL(string: self.profilePicUrl))
        }
        ProfilePic.clipsToBounds = true
        ProfilePic.layer.cornerRadius = ProfilePic.bounds.width / 2
        //Set profile picture
        if self.selfProfile == true {
            self.FollowButtonLabel.setTitle("Profile Settings", for: .normal)
            self.FollowButtonLabel.isHidden = false
        }
        else{
        var exist = false
            firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Follows").getDocuments { (snapshot, error) in
            firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Follows").document(self.userID).getDocument(completion: { (snapshot2, error) in
                for user in snapshot!.documents{
                    if user.documentID == snapshot2!.documentID{
                        exist = true
                        //takip varken
                        self.FollowButtonLabel.setTitle("Stop Following", for: .normal)
                        self.FollowButtonLabel.backgroundColor = .white
                        self.FollowButtonLabel.setTitleColor(.black, for: .normal)
                        self.FollowButtonLabel.isHidden = false
                    }
                }
                if exist == false{
                    self.FollowButtonLabel.setTitle("Follow", for: .normal)
                    self.FollowButtonLabel.backgroundColor = UIColor.init(red: 0.67, green: 0.84, blue: 0.90, alpha: 1)
                    self.FollowButtonLabel.setTitleColor(.white, for: .normal)
                    self.FollowButtonLabel.isHidden = false
                }
            })
        }
    } //Set follow button
            firestoreDatabase.collection("Users").document(self.userID).collection("Follows").getDocuments { (snapshot, error) in
                var followCount = [String]()
                for document in snapshot!.documents{
                    followCount.append(document.get("username") as! String)
                }
                self.FollowCount!.text = "\(followCount.count)"
                self.FollowCount.isHidden = false
            } //Get Follows
        
            firestoreDatabase.collection("Users").document(self.userID).collection("Followers").getDocuments { (snapshot, error) in
                var followerCount = [String]()
                for document in snapshot!.documents{
                    followerCount.append(document.get("username") as! String)
                }
                self.FollowerCount!.text = "\(followerCount.count)"
                self.FollowerCount.isHidden = false
            } //Get Followers
        
        
        firestoreDatabase.collection("Users").document(self.userID).getDocument { (snapshot, error) in
            self.posts.removeAll()
         
            let name = snapshot!.get("username") as! String
            firestoreDatabase.collection("Posts").whereField("postedBy", isEqualTo: name).getDocuments(completion: { (snapshot, error) in
                for document in snapshot!.documents{
                let post = Post(postID: document.documentID, postedBy: document.get("postedBy") as! String, userPPlink:document.get("userPP") as! String, date: (document.get("date") as! Timestamp).dateValue(), postedImagelink: document.get("imageUrl") as! String, postcomment: document.get("postComment") as! String)
                    
                    self.posts.append(post)
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.PostCount.text = String(self.posts.count)
                self.PostCount.isHidden = false
                self.collectionView.reloadData()
            }
        }//Get Posts of searched profile
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        
    
        
        let followerGR = UITapGestureRecognizer(target: self, action: #selector(self.followersTabbed))
        FollowerView.addGestureRecognizer(followerGR)
        FollowerView.isUserInteractionEnabled = true
        
        let followGR = UITapGestureRecognizer(target: self, action: #selector(self.followsTabbed))
        FollowView.addGestureRecognizer(followGR)
        FollowView.isUserInteractionEnabled = true
        
        
      NotificationCenter.default.addObserver(self, selector: #selector(viewDidLoad), name: NSNotification.Name(rawValue: "SearchProfileViewController"), object: nil)

    }//ViewDidLoad
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
            usernameLabel.text = self.username
            navigationBar.addSubview(usernameLabel)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }//CollectionView Number of Posts
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath as IndexPath) as! CollectionViewCell
        cell.postImage.sd_setImage(with: URL(string: posts[indexPath.row].postedImagelink))
        cell.postComment = self.posts[indexPath.row].postcomment
            return cell
    }//CollectionView Initialize Posts
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        performSegue(withIdentifier: "toListOfPosts", sender: nil)
    }
    

    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        var workOnce = true


        if gestureReconizer.state == .began{
            if workOnce == true{
                let point = gestureReconizer.location(in: self.collectionView)
                let indexPath = self.collectionView.indexPathForItem(at: point)
                self.postImage.sd_setImage(with: URL(string: posts[indexPath!.row].postedImagelink))
                if self.profilePicUrl == ""{
                    self.userPP.image = UIImage(named: "profilePic")
                }
                else{
                    self.userPP.sd_setImage(with: URL(string: self.profilePicUrl))
                }
                self.userName.text! = self.username
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
    
    
    @objc func followersTabbed(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let fireStoreDataBase = Firestore.firestore()
            fireStoreDataBase.collection("Users").document(userID).collection("Followers").getDocuments { (snapshot, error) in
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
            fireStoreDataBase.collection("Users").document(userID).collection("Follows").getDocuments { (snapshot, error) in
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserListVC"{
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
        if segue.identifier == "toListOfPosts" {
             let destination = segue.destination as! ListOfPostsViewController
            destination.userID = self.userID
        }
    }
    @IBAction func FollowButtonAction(_ sender: Any) {
        
        if FollowButtonLabel.titleLabel!.text == "Profile Settings"{
            let firestoreDatabase = Firestore.firestore()
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
                
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "profileSettings") as! SettingsViewController
                
                
                nextViewController.useremail = (snapshot!.get("email") as! String)
                nextViewController.username = (snapshot!.get("username") as! String)
                if let picture = snapshot!.get("profilePicture") as? String{
                nextViewController.userPPLink = picture
                }
                else{
                nextViewController.userPPLink = ""
                }
                nextViewController.fromSearchVC = true
                self.present(nextViewController, animated:false, completion:nil)
            }
        }//If user cheking his/her own profile
        else{
        let firestoreDatabase = Firestore.firestore()
        var exist = false
        firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Follows").getDocuments { (snapshot, error) in
            
            firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Follows").document(self.userID).getDocument(completion: { (snapshot2, error) in
                for user in snapshot!.documents{
                    if user.documentID == snapshot2!.documentID{
                            exist = true
                        
                        let popOptionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popOptions") as! OptionsViewController
                        popOptionsVC.buttonNames.append("Stop Following")
                        popOptionsVC.ID.append(self.userID)
                        self.addChild(popOptionsVC)
                        popOptionsVC.view.frame = self.view.frame
                        self.view.addSubview(popOptionsVC.view)
                        popOptionsVC.didMove(toParent: self)
                    }
                    //If user is following searched profile
                }
                if exist == false{
                    let firestorePost = ["username" : self.username ] as [String : Any]
                    let firestorePost2 = ["username" : Auth.auth().currentUser!.displayName!] as [String : Any]
                    firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Follows").document(self.userID).setData(firestorePost)
                    
                    firestoreDatabase.collection("Users").document(self.userID).collection("Followers").document(Auth.auth().currentUser!.uid).setData(firestorePost2)
                    self.FollowButtonLabel.setTitle("Follow", for: .normal)
                    self.FollowButtonLabel.backgroundColor = UIColor.init(red: 0.67, green: 0.84, blue: 0.90, alpha: 1)
                     self.FollowButtonLabel.setTitleColor(.white, for: .normal)
                   
                       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SearchProfileViewController"), object: nil)
                }
                //If user is not following searched profile
            })
        }
    }
    //If user cheking someone else's profile
    }
}

