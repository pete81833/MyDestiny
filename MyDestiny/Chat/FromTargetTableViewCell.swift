//
//  FromTargetTableViewCell.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/16.
//

import UIKit

class FromTargetTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var textView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
