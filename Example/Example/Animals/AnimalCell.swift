//
//  AnimalCell.swift
//  Example
//
//  Created by Alexander Kravchenkov on 09.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

public class AnimalCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var animalImage: UIImageView!

    func configure(name: String, url: String) {
        self.titleLabel.text = name
        self.animalImage.af_setImage(withURL: URL(string: url)!)
    }

}
