//
//  SearchProfileCell.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 22.12.2020.
//  Copyright © 2020 Bulut. All rights reserved.
//

import UIKit

class SearchProfileCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postCommentLabel: UILabel!
    @IBOutlet weak var allCommentsButtonLabel: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likesLabel: UIButton!
    @IBOutlet weak var commentButtonlabel: UIButton!
    @IBOutlet weak var optionsButtonLabel: UIButton!
    @IBOutlet weak var documentIDLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
