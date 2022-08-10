//
//  FeedViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 8.11.2019.
//  Copyright © 2019 Bulut. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class FeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
  
    
  
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var UIView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var likeArray = [[String]]()
    var commentArray = [[String]]()
    
    //Story
    var storyList = [[Story]]()//Bütün kullanıcıların storileri 
    var stories = [Story]()//Bir kişinin storileri
    var storyUserPP = String()//Story paylaşan kişinin profil resmi. Yukarıdaki yuvarlak resimler için.
    var storyImage = UIImage()//Telefon galerisinden seçilen resim. Upload sayfasına geçerken burası yüklenmeli.
    var userHasStory = false //Kullanıcının kendi storisi aktifse
    var storyPosition = Int()//Tıkladığın storinin indexi
    var choosenStoryList = Story()//Tıkladığın storinin kendisi
    
    //Segue
    var titleName = String()
    var titleComment = String()
    var titlePicture = String()
    var postID = String()

    var buttons = [String]()
    var likeNames = [String]()
    var likeImages = [String]()
    var ids = [String]()
    var userID = String()
    var profilePicture = String()
    var selfProfile = false
    var username = String()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
      
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if let picture = snapshot!.get("profilePicture") as? String{
                self.storyUserPP = picture
            }
            else{
                self.storyUserPP = ""
            }//Get user's Profilepicture
            firestoreDatabase.collection("Stories").whereField("postedBy", isEqualTo: snapshot!.get("username") as! String).getDocuments(completion: { (snapshot2, error) in
                    for document in snapshot2!.documents{
                        if document.exists{
                            self.userHasStory = true
                            let id = document.documentID
                            let postedBy = document.get("postedBy") as! String
                            let userPPlink = document.get("userPP") as! String
                            let date = (document.get("date") as! Timestamp).dateValue()
                            let postedImagelink = document.get("imageUrl") as! String
                            let story = Story(storyId: id,postedBy: postedBy, userPPlink: userPPlink, date: date, postedImagelink: postedImagelink)
                            self.stories.append(story)
                        }
                    }
                        if self.stories.isEmpty == false{
                            self.storyList.append(self.stories)
                        }
                        self.stories.removeAll()
                    })
            }//Set user's profile
        
           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.collectionView.reloadData()
            self.getDataFromFirestore()
            NotificationCenter.default.addObserver(self, selector: #selector(self.getDataFromFirestore), name: NSNotification.Name(rawValue: "feedViewNotif"), object: nil)
        }
    }
    @objc func chooseImage(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController,animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.storyImage = info[.originalImage] as! UIImage
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let uploadStoryVC = storyBoard.instantiateViewController(withIdentifier: "uploadStory") as! UploadStoryViewController
        uploadStoryVC.storyPic = self.storyImage
        self.dismiss(animated: true)
        self.present(uploadStoryVC, animated:false, completion:nil)
  
    }
    
    
    @objc func getDataFromFirestore(){
        self.posts.removeAll()
        let firestoreDatabase = Firestore.firestore()
        UIApplication.shared.endIgnoringInteractionEvents()
        firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).collection("Follows").getDocuments { (snapshot, error) in
            for document in snapshot!.documents{
              let name = document.get("username") as! String
                firestoreDatabase.collection("Posts").whereField("postedBy", isEqualTo: name).getDocuments(completion: { (snapshot, error) in
                    for document in snapshot!.documents{
                        let postedBy = document.get("postedBy") as! String
                        let userPPlink = document.get("userPP") as! String
                        let date = (document.get("date") as! Timestamp).dateValue()
                        let postedImagelink = document.get("imageUrl") as! String
                        let postcomment = document.get("postComment") as! String
                        let post = Post(postID: document.documentID, postedBy: postedBy, userPPlink: userPPlink, date: date, postedImagelink: postedImagelink, postcomment: postcomment)
                        self.posts.append(post)
                    }
                })
            }
            firestoreDatabase.collection("Posts").whereField("postedBy", isEqualTo: Auth.auth().currentUser!.displayName!).getDocuments(completion: { (snapshot, error) in
                for document in snapshot!.documents{
                    let postedBy = document.get("postedBy") as! String
                    let userPPlink = document.get("userPP") as! String
                    let date = (document.get("date") as! Timestamp).dateValue()
                    let postedImagelink = document.get("imageUrl") as! String
                    let postcomment = document.get("postComment") as! String
                    let post = Post(postID: document.documentID, postedBy: postedBy, userPPlink: userPPlink, date: date, postedImagelink: postedImagelink, postcomment: postcomment)
                    self.posts.append(post)
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.posts.sort(by: {$0.date.timeIntervalSinceNow > $1.date.timeIntervalSinceNow})
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.getLikes()
                self.getComments()
                self.getStories()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                self.tableView.reloadData()
                self.collectionView.reloadData()
            }
        }
    }
    func getStories(){
        let firestoreDatabase = Firestore.firestore()
        
        if self.userHasStory == false {
            let story = [Story]()
            self.storyList.append(story)
        }
        
        
        firestoreDatabase.collection("Users").getDocuments { (snapshot, error) in
            for document in snapshot!.documents {
                firestoreDatabase.collection("Stories").whereField("postedBy", isEqualTo:  document.get("username") as! String).getDocuments(completion: { (snapshot2, error) in
                    for document in snapshot2!.documents{
                        let id = document.documentID
                        let postedBy = document.get("postedBy") as! String
                        let userPPlink = document.get("userPP") as! String
                        let date = (document.get("date") as! Timestamp).dateValue()
                        let postedImagelink = document.get("imageUrl") as! String
                        let story = Story(storyId: id,postedBy: postedBy, userPPlink: userPPlink, date: date, postedImagelink: postedImagelink)
                        self.stories.append(story)                 
                    }
                    if self.stories.isEmpty == false{
                    self.storyList.append(self.stories)
                    }
                    self.stories.removeAll()
                })
            }
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }//TableView set amount of posts
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.username.setTitle(posts[indexPath.row].postedBy, for: .normal)
        cell.postCommentLabel.text = posts[indexPath.row].postcomment
        cell.userImageView.sd_setImage(with: URL(string: self.posts[indexPath.row].postedImagelink))
        cell.documentIDLabel.text = posts[indexPath.row].postID
        cell.likesLabel.tag = indexPath.row
        cell.likesLabel.addTarget(self, action: #selector(likesButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        cell.commentButtonlabel.tag = indexPath.row
        cell.commentButtonlabel.addTarget(self, action: #selector(commentButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        cell.allCommentsButtonLabel.tag = indexPath.row
        cell.allCommentsButtonLabel.addTarget(self, action: #selector(commentButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        cell.optionsButtonLabel.tag = indexPath.row
        cell.optionsButtonLabel.addTarget(self, action: #selector(optionsButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        cell.profilePicture.tag = indexPath.row
        cell.profilePicture.addTarget(self, action: #selector(profilePictureOrUsernameButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        cell.username.tag = indexPath.row
        cell.username.addTarget(self, action: #selector(profilePictureOrUsernameButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        //Button fucntions
        if commentArray[indexPath.row].count == 0{
            cell.allCommentsButtonLabel.isHidden = true
        }
        else if commentArray[indexPath.row].count == 1{
            cell.allCommentsButtonLabel.setTitle(String("See \(commentArray[indexPath.row].count) comment"), for: .normal)
        }
        else{
            cell.allCommentsButtonLabel.setTitle(String("See \(commentArray[indexPath.row].count) comments"), for: .normal)
        }//Cheking comment count
        
        if likeArray[indexPath.row].count == 0{
            cell.likesLabel.isHidden = true
        }
        else if likeArray[indexPath.row].count == 1{
            cell.likesLabel.setTitle(String("See \(likeArray[indexPath.row].count) like"), for: .normal)
            cell.likesLabel.isHidden = false
        }
        else{
            cell.likesLabel.setTitle(String("See \(likeArray[indexPath.row].count) likes"), for: .normal)
            cell.likesLabel.isHidden = false
        }
        //Cheking like count
 
        if posts[indexPath.row].userPPlink == ""{
            cell.profilePicture.setImage(UIImage(named: "profilePic"), for: .normal)
        }
        else{
            cell.profilePicture.sd_setImage(with: URL(string: self.posts[indexPath.row].userPPlink), for: .normal)
        }
        return cell
    }// TableView Initialize posts
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath as IndexPath) as! FeedStoryViewCell
       
        cell.story.clipsToBounds = true
        cell.story.layer.cornerRadius = cell.story.bounds.width / 2
        cell.story.layer.borderWidth = 2
        cell.story.layer.borderColor = UIColor.red.cgColor
        cell.story.tag = indexPath.row
        cell.story.addTarget(self, action: #selector(addStoryButtonAction(_:)), for: UIControl.Event.touchUpInside)
        if indexPath.row == 0{
            if self.storyUserPP == ""{
                cell.story.setImage(UIImage(named: "profilePic"), for: .normal)
            }
            else{
                cell.story.sd_setImage(with: URL(string: self.storyUserPP), for: .normal)
            }
        }//Current user's story spot
        else{
            if storyList[indexPath.row][0].userPPlink == ""{
                cell.story.setImage(UIImage(named: "profilePic"), for: .normal)
            }
            else{
                cell.story.sd_setImage(with: URL(string: storyList[indexPath.row][0].userPPlink), for: .normal)
            }
        }//Other user's story spot
        return cell
    }
    
    
    
    @objc func addStoryButtonAction(_ sender:UIButton!){
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
        let indexPath = self.collectionView.indexPathForItem(at: buttonPosition)
        if indexPath!.row == 0{
            if userHasStory == false{
                chooseImage()
            }
            else{
                chooseImage()
            }
        }
        else{
         
            self.storyPosition = indexPath!.row
            performSegue(withIdentifier: "toStory", sender: nil)
        }
    }
    
    
    
    @objc func profilePictureOrUsernameButtonTapped(_ sender:UIButton!){
      
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Posts").document(posts[indexPath!.row].postID).getDocument { (snapshot, error) in
            firestoreDatabase.collection("Users").whereField("username",isEqualTo:snapshot!.get("postedBy") as! String).getDocuments(completion: { (snapshot2, error) in
                for document in snapshot2!.documents{
                    self.userID = document.documentID
                    self.username = document.get("username") as! String
                    if let picture = document.get("profilePicture") as? String {
                          self.profilePicture = picture
                    }
                    else{
                        self.profilePicture = ""
                    }
                  
                    if (document.get("username") as! String) == Auth.auth().currentUser!.displayName{
                        self.selfProfile = true
                    }
                    
                }
             self.performSegue(withIdentifier: "toSearchedView", sender: nil)
            })
         
        }
    }
    
   
    
    
    @objc func optionsButtonTapped(_ sender:UIButton!){
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if posts[indexPath!.row].postedBy == Auth.auth().currentUser!.displayName{
            let popOptionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popOptions") as! OptionsViewController
            popOptionsVC.buttonNames.append("Delete")
            popOptionsVC.buttonNames.append("More")
            popOptionsVC.ID.append(posts[indexPath!.row].postID)
            self.addChild(popOptionsVC)
            popOptionsVC.view.frame = self.view.frame
            self.view.addSubview(popOptionsVC.view)
            popOptionsVC.didMove(toParent: self)
        }
        else{
            let popOptionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popOptions") as! OptionsViewController
            popOptionsVC.buttonNames.append("More")
            self.addChild(popOptionsVC)
            popOptionsVC.view.frame = self.view.frame
            self.view.addSubview(popOptionsVC.view)
            popOptionsVC.didMove(toParent: self)
        }
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
     
                fireStoreDatabase.collection("Users").whereField("username", isEqualTo: document.get("username") as! String).getDocuments(completion: { (snapshot, error) in
                    for document in snapshot!.documents{
                        self.ids.append(document.documentID)
                    }
                })
                
                if document.get("userPP") as! String != ""{
                    self.likeImages.append(document.get("userPP") as! String)
                }
                else{
                    self.likeImages.append("")
                }
                
               
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.performSegue(withIdentifier: "toUserListVC", sender: nil)
            self.ids.removeAll()
            self.likeNames.removeAll()
            self.likeImages.removeAll()
            }
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
        //Comment
        if segue.identifier == "toCommentsVC" {
            let destination = segue.destination as! CommentViewController
            destination.postID = self.postID
            destination.commentTitle = self.titleComment
            if self.titleComment != ""{
                destination.nameTitle = "\(self.titleName) : "
            }
                destination.pictureTitle = self.titlePicture
        }
        //Like
        if segue.identifier == "toUserListVC"{
            let destination = segue.destination as! ListOfUsersViewController
            destination.ids = self.ids
            destination.names = self.likeNames
            destination.images = self.likeImages
        }
        if segue.identifier == "toSearchedView"{
            let destination = segue.destination as! SearchedProfileViewController
            destination.userID = self.userID
            destination.username = self.username
            destination.selfProfile = self.selfProfile
            destination.profilePicUrl = self.profilePicture
        }
        if segue.identifier == "toStory"{
            let destination = segue.destination as! ViewStoryViewController
            destination.position = self.storyPosition
            destination.storyImages.removeAll()
            destination.storyImages = self.storyList
        }
    }
}
        
        
        
    
    
    
    
    
    
    
    
    
    



