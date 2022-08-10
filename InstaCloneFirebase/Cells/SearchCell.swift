//
//  SearchCell.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 20.12.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        profilePic.clipsToBounds = true
        profilePic.layer.cornerRadius = profilePic.bounds.width / 2
    }
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userID: UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
