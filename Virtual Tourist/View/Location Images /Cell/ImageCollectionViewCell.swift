//
//  ImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/17/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import UIKit

protocol LocationImageProtocol {
    func configureCell(image:UIImage)
}

class ImageCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.activityIndicator.startAnimating()
    }
    
}

extension ImageCollectionViewCell:LocationImageProtocol{
    
    func configureCell(image: UIImage) {
        self.locationImageView.image = image
        if locationImageView.image != nil{
            self.activityIndicator.stopAnimating()
            self.locationImageView.backgroundColor = .white
        }
    }

}
