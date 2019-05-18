//
//  LocationImagesVC.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/17/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import UIKit

class LocationImagesVC: UIViewController {
    private let reuseIdentifier = "ImageCollectionViewCell"
    private let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
    private var images:[UIImage] = []
    private var selectedImages:[Int] = []
    var lon:Double!
    var lat:Double!
    
    // MARK: - IBOutlets
    @IBOutlet var imagesCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(lat)
        getImagesForLocation()
    }
    
    func config(){
        configCollectionView()
    }
    
    func configCollectionView(){
        self.imagesCollectionView.dataSource = self
        self.imagesCollectionView.delegate = self
        imagesCollectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    fileprivate func getImagesForLocation() {
        Client.searchPhoto(lat: lat, lon: lon) { (photos, error) in
            Client.getImages(photos: photos!, completionHandler: { (images, error) in
                if error != nil{
                    return
                }
                self.images = images!
                print(self.images.count)
                self.imagesCollectionView.reloadData()
            })
        }
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionView data source methods
extension LocationImagesVC:UICollectionViewDataSource{
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        if images.count >= indexPath.row {
            cell.configureCell(image: images[indexPath.row])
        }
        return cell
    }
    
}

extension LocationImagesVC:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width/3)-5, height: collectionView.frame.size.width/3)
    }
}

// MARK: - UICollectionView Delegate Methods
extension LocationImagesVC:UICollectionViewDelegate{
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       //let cell  = collectionView.cellForItem(at: indexPath)?.backgroundColor
        if !(selectedImages.contains(indexPath.row)) {
            selectedImages.append(indexPath.row)
            newCollectionButton.setTitle("Remove Selected Picture(s)", for: .normal)
        }
        
        else{
            for i in selectedImages.count-1...0{
                if selectedImages[i] == indexPath.row{
                    selectedImages.remove(at: i)
                }
            }
            if selectedImages.count == 0{
                newCollectionButton.setTitle("New Collection", for: .normal)
            }
        }
    }
}
