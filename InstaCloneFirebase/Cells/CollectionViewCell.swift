//
//  CollectionViewCell.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 10.01.2021.
//  Copyright © 2021 Bulut. All rights reserved.
//

import UIKit
import Firebase
class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var postImage: UIImageView!
    var postComment = String()
}
