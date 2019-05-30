//
//  LocationImagesVC.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/17/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class LocationImagesVC: UIViewController {
    private let reuseIdentifier = "ImageCollectionViewCell"
    private let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
    private var numberOfImages:Int = 0
    private var selectedImages:[IndexPath] = []
    private var photos:ArraySlice<Photo> = []
    var lon:Double!
    var lat:Double!
    var pin:Pin!
    var dataController:DataController!
    var savedImages:[UIImage] = []
    var savedLocationPhotos:[LocationPhoto] = []
    var cells:[ImageCollectionViewCell] = []
    var imagesToSave:[LocationPhoto] = []
    var imagesDidChange:Bool = false
    
    // MARK: - IBOutlets
    @IBOutlet var imagesCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        
        fetchSavedImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // getImagesForLocation()
    }
    
    func config(){
        self.noImagesLabel.isHidden = true
        configCollectionView()
    }
    
    func configCollectionView(){
        self.imagesCollectionView.dataSource = self
        self.imagesCollectionView.delegate = self
        imagesCollectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    fileprivate func fetchSavedImages() {
        let fetchRequest:NSFetchRequest<LocationPhoto> = LocationPhoto.fetchRequest()
        fetchRequest.predicate=NSPredicate(format: "pin == %@", self.pin)
        let results = try? dataController.viewContext.fetch(fetchRequest)
        if results?.count ?? 0 > 0{
            print("there are saved photos")
            self.numberOfImages = results!.count
            for locationPhoto in results!{
                self.savedLocationPhotos.append(locationPhoto)
                let image = UIImage(data:locationPhoto.imageData!)
                self.savedImages.append(image!)
            }
        }
            
        else{
            print("NO saved photos")
            getImagesForLocation()
        }
    }
    
    fileprivate func getImagesForLocation() {
        self.imagesDidChange = true
        self.newCollectionButton.isEnabled = false
        self.resetSavedImages()
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
        if self.imagesDidChange{
            print("has changes")
            for cell in cells{
                let locationPhoto = LocationPhoto(context: self.dataController.viewContext)
                if let cellImage = cell.cellImage{
                    print("cell has image")
                    locationPhoto.pin = self.pin
                    locationPhoto.imageData = cellImage.jpegData(compressionQuality: 1)
                    self.imagesToSave.append(locationPhoto)
                }
            }
            self.cells = []
            self.imagesToSave = []
            try? self.dataController.viewContext.save()
        }
        self.imagesDidChange = false
    }
    
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        if newCollectionButton.titleLabel?.text == "New Collection"{
            self.numberOfImages = 0
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
    
    func resetSavedImages(){
        for locationPhoto in self.savedLocationPhotos{
            self.dataController.viewContext.delete(locationPhoto)
        }
        self.cells = []
        self.savedLocationPhotos = []
        try? self.dataController.viewContext.save()
    }
    
}

// MARK: - UICollectionView data source methods
extension LocationImagesVC:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.dataController = self.dataController
        if self.savedImages.count > 0 && self.photos.count == 0{
            cell.configureCell(imageUrl: nil, image: self.savedImages[indexPath.row])
        }
            
        else{
            let currentPhoto = self.photos[indexPath.row]
            let imageUrl = Client.EndPoints.getImage(farm: currentPhoto.farm, server: currentPhoto.server, id: currentPhoto.id, secret: currentPhoto.secret).url
            cell.configureCell(imageUrl: imageUrl,image:nil)
        }
        cells.append(cell)
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
