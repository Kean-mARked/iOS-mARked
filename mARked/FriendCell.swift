//
//  FrienCell.swift
//  mARked
//
//  Created by Katherine Cabrera on 4/25/18.
//  Copyright © 2018 AGlez. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    
    var username: String = ""{
        didSet{
            userLabel.text = username
        }
    }
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
