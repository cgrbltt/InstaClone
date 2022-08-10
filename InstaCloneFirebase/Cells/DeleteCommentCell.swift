//
//  DeleteCommentCell.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 8.12.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit

class DeleteCommentCell: UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var likelbl: UIButton!
    @IBOutlet weak var likeslbl: UIButton!
    @IBOutlet weak var commentID: UILabel!
    @IBOutlet weak var postID: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePic.clipsToBounds = true
        profilePic.layer.cornerRadius = profilePic.bounds.width / 2
        comment.sizeToFit()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
