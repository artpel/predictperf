//
//  domaineCell.swift
//  PredictPerf
//
//  Created by Arthur Péligry on 08/03/2018.
//  Copyright © 2018 Arthur Péligry. All rights reserved.
//

import UIKit
import FloatRatingView

class domaineCell: UITableViewCell {
    
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var firmName: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var medal: RoundShadowView!
    @IBOutlet weak var libelleAPE: UILabel!
    @IBOutlet weak var noteAFDCC: UILabel!
    @IBOutlet weak var ville: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
