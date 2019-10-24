//
//  ProfileCollectionViewCell.swift
//  visionGate
//
//  Created by Bahadır Enes Atay on 5.07.2019.
//  Copyright © 2019 Bahadır Enes Atay. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setImage(image: UIImage) {
        self.imageView.image = image
    }
}
