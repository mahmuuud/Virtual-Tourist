//
//  ImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/17/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import UIKit

protocol LocationImageProtocol {
    func configureCell(imageUrl:URL)
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
    
    func configureCell(imageUrl: URL) {
        self.locationImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
            if error != nil || image == nil {
                print("setting cell image failed")
                return
            }
            DispatchQueue.main.async {
                if self.locationImageView.image != nil{
                    self.activityIndicator.stopAnimating()
                    self.locationImageView.backgroundColor = .white
                }
            }
        }
        
    }
    
}
