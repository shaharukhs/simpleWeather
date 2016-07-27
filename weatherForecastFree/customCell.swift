//
//  customCell.swift
//  weatherForecastFree
//
//  Created by Vaibhav Narkhede on 7/25/16.
//  Copyright © 2016 DeviseApps. All rights reserved.
//

import UIKit

class customCell: UITableViewCell {

    
    @IBOutlet var weatherCondition: UILabel!
    @IBOutlet var weatherSubClass: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var cellBackgrounImageView: UIImageView!
    @IBOutlet var currentTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var tempLogo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
