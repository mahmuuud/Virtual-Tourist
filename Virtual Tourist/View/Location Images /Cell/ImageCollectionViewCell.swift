//
//  ImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/17/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import UIKit

protocol LocationImageProtocol {
    func configureCell(imageUrl:URL?,image:UIImage?)
}

class ImageCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var dataController:DataController!
    var cellImage:UIImage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetPlaceHolder()
    }
    
    override var isSelected: Bool {
        didSet {
            // set color according to state
            self.backgroundColor = self.isSelected ? .blue : .clear
        }
    }
    
    func displayPlaceHolder(){
        self.locationImageView.image = nil
        self.locationImageView.backgroundColor = .lightGray
        self.activityIndicator.startAnimating()
    }
    
    func resetPlaceHolder(){
        self.locationImageView.backgroundColor = .white
        self.activityIndicator.stopAnimating()
    }
    
}

extension ImageCollectionViewCell:LocationImageProtocol{
    
    func configureCell(imageUrl: URL?,image:UIImage?) {
        if imageUrl != nil{
            displayPlaceHolder()
            self.locationImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
                if error != nil || image == nil {
                    print("setting cell image failed")
                    return
                }
                DispatchQueue.main.async {
                    if self.locationImageView.image != nil{
                        self.resetPlaceHolder()
                        self.cellImage = self.locationImageView.image
                    }
                }
            }
        }
        
        if image != nil {
            self.locationImageView.image = image
            //self.resetPlaceHolder()
            self.cellImage = image
        }
    }
    
}
