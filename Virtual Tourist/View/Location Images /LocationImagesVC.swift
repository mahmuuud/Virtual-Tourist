//
//  LocationImagesVC.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/17/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import UIKit
import Kingfisher
class LocationImagesVC: UIViewController {
    private let reuseIdentifier = "ImageCollectionViewCell"
    private let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
    private var images:[UIImage] = []
    private var numberOfImages:Int = 0
    private var selectedImages:[IndexPath] = []
    private var photos:ArraySlice<Photo> = []
    var lon:Double!
    var lat:Double!
    
    // MARK: - IBOutlets
    @IBOutlet var imagesCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getImagesForLocation()
    }
    
    func config(){
        self.noImagesLabel.isHidden = true
        self.newCollectionButton.isEnabled = false
        configCollectionView()
    }
    
    func configCollectionView(){
        self.imagesCollectionView.dataSource = self
        self.imagesCollectionView.delegate = self
        imagesCollectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    fileprivate func getImagesForLocation() {
        Client.searchPhoto(lat: lat, lon: lon) { (photos, error)
            in
            if error != nil || photos == nil || photos?.count == 0{
                print("No Images👾")
                DispatchQueue.main.async {
                    self.imagesCollectionView.isHidden = true
                    self.noImagesLabel.isHidden = false
                }
                return
            }
            print(photos?.count)
            DispatchQueue.main.async {
                if photos!.count < 21{
                    self.photos = photos![0..<photos!.count]
                    self.numberOfImages = photos!.count
                    
                }
                else{
                    self.photos = photos![...20]
                    self.numberOfImages = 21
                }
                self.imagesCollectionView.reloadData()
                self.newCollectionButton.isEnabled = true
            }
            
            
            
        }
    }
    
    func retrieveImageForLocation(imageUrl:URL,completionHandler:@escaping (UIImage?,Error?)->Void){
        KingfisherManager.shared.retrieveImage(with: imageUrl, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
            if error != nil || image == nil{
                completionHandler(nil,error)
                return
            }
            completionHandler(image!,nil)
        }
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        if newCollectionButton.titleLabel?.text == "New Collection"{
            self.getImagesForLocation()
            DispatchQueue.main.async {
                self.imagesCollectionView.reloadData()
            }
        }
        
        else if newCollectionButton.titleLabel?.text == "Remove Selected Picture(s)"{
            self.numberOfImages -= selectedImages.count
            imagesCollectionView.deleteItems(at: selectedImages)
            self.selectedImages=[]
            self.newCollectionButton.setTitle("New Collection", for: .normal)
        }
    }
    
    
}

// MARK: - UICollectionView data source methods
extension LocationImagesVC:UICollectionViewDataSource{
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfImages
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let currentPhoto = self.photos[indexPath.row]
        let imageUrl = Client.EndPoints.getImage(farm: currentPhoto.farm, server: currentPhoto.server, id: currentPhoto.id, secret: currentPhoto.secret).url
        cell.configureCell(imageUrl: imageUrl)
//        if photos.count > 0 && cell.tag == 0{
//            self.retrieveImageForLocation(imageUrl: imageUrl) { (image, error) in
//                if error != nil || image == nil{
//                    print("cannot retrieve photo")
//                    return
//                }
//                DispatchQueue.main.async {
//                    cell.tag = 1
//                    cell.configureCell(image: image!)
//                }
//            }
//        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout Methods
extension LocationImagesVC:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width/3)-5, height: collectionView.frame.size.width/3)
    }
}

// MARK: - UICollectionView Delegate Methods
extension LocationImagesVC:UICollectionViewDelegate{
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !(selectedImages.contains(indexPath)) {
            selectedImages.append(indexPath)
            newCollectionButton.setTitle("Remove Selected Picture(s)", for: .normal)
            collectionView.cellForItem(at: indexPath)?.isSelected = true
        }
        
        else{
            for i in 0..<selectedImages.count{
                collectionView.cellForItem(at: indexPath)?.isSelected = false
                if selectedImages[i] == indexPath{
                    selectedImages.remove(at: i)
                    break
                }
            }
            if selectedImages.count == 0{
                newCollectionButton.setTitle("New Collection", for: .normal)
            }
        }
    }
}
