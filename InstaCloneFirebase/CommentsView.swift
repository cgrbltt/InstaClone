//
//  CommentsView.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 9.10.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit

class CommentsView: UIViewController {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var commentText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        commentText.sizeToFit()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
