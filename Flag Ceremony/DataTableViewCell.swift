//
//  DataTableViewCell.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 07/04/2017.
//  Copyright © 2017 Jovit Royeca. All rights reserved.
//

import UIKit

class DataTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statIcon: UIImageView!
    @IBOutlet weak var statLabel: UILabel!
    
    
    // MARK: Overrides
    override func prepareForReuse() {
        super.prepareForReuse()
        imageIcon.image = nil
        rankLabel.text = nil
        nameLabel.text = nil
        statIcon.image = nil
        statLabel.text = nil
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
