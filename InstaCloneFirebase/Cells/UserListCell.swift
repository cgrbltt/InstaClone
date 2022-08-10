//
//  LikesCell.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 14.09.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var userId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        picture.clipsToBounds = true
        picture.layer.cornerRadius = picture.bounds.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
