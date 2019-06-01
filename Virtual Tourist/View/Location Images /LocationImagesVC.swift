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
    var imagesDataToSave:[IndexPath:LocationPhoto] = [:]
    var savedCells:[IndexPath] = []
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
            print("there are saved \(results!.count) photos")
            self.numberOfImages = results!.count
            self.savedLocationPhotos = results!
            for locationPhoto in results!{
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
        Client.searchPhoto(lat: lat, lon: lon) { (photos, error)
            in
            if error != nil || photos == nil || photos?.count == 0{
                print("No Images👾")
                DispatchQueue.main.async {
                    self.imagesCollectionView.isHidden = true
                    self.newCollectionButton.isEnabled = true
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
    
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: Any) {
        print(self.imagesDataToSave.count)
        self.dismiss(animated: true, completion: nil)
        if self.imagesDidChange {
            try? dataController.viewContext.save()
        }
        self.imagesDidChange = false
        self.imagesDataToSave = [:]
        self.savedImages = []
    }
    
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        if newCollectionButton.titleLabel?.text == "New Collection"{
            self.resetSavedImages()
            self.numberOfImages = 0
            self.getImagesForLocation()
            DispatchQueue.main.async {
                self.imagesCollectionView.reloadData()
            }
        }
            
        else if newCollectionButton.titleLabel?.text == "Remove Selected Picture(s)"{
            
            self.numberOfImages -= selectedImages.count
            imagesCollectionView.deleteItems(at: selectedImages)
            for indexPath in selectedImages{
                print(indexPath)
                print(imagesDataToSave)
                if imagesDataToSave.count > 0{
                    let locationPhoto = imagesDataToSave[indexPath]
                    dataController.viewContext.delete(locationPhoto!)
                    imagesDataToSave.removeValue(forKey: indexPath)
                }
                else{
                    let locationPhoto = savedLocationPhotos[indexPath.row]
                    self.dataController.viewContext.delete(locationPhoto)
                    //savedLocationPhotos.remove(at: indexPath.row)
                    self.imagesDidChange = true
                }
            }
            self.selectedImages=[]
            self.newCollectionButton.setTitle("New Collection", for: .normal)
        }
    }
    
    func resetSavedImages(){
        for locationPhoto in self.savedLocationPhotos{
            self.dataController.viewContext.delete(locationPhoto)
        }
        for locationPhoto in self.imagesDataToSave.values{
            self.dataController.viewContext.delete(locationPhoto)
        }
        self.savedLocationPhotos = []
        self.imagesDataToSave = [:]
        self.savedCells = []
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
        cell.delegate = self
        cell.cellIndexPath = indexPath
        if self.savedImages.count > 0 && self.photos.count == 0{
            cell.configureCell(imageUrl: nil, image: self.savedImages[indexPath.row])
        }
            
        else{
            let currentPhoto = self.photos[indexPath.row]
            let imageUrl = Client.EndPoints.getImage(farm: currentPhoto.farm, server: currentPhoto.server, id: currentPhoto.id, secret: currentPhoto.secret).url
            cell.configureCell(imageUrl: imageUrl,image:nil)
        }
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
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        if !(selectedImages.contains(indexPath)) {
            cell.checkImageView.isHidden = false
            selectedImages.append(indexPath)
            newCollectionButton.setTitle("Remove Selected Picture(s)", for: .normal)
        }
            
        else{
            cell.checkImageView.isHidden = true
            for i in 0..<selectedImages.count{
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

extension LocationImagesVC:CellDidSetImage{
    func getCellImage(image: UIImage,indexPath:IndexPath) {
        if !self.savedCells.contains(indexPath){
            print("saving...")
            let locationPhoto = LocationPhoto(context: dataController.viewContext)
            locationPhoto.pin = self.pin
            locationPhoto.imageData = image.jpegData(compressionQuality: 1)
            imagesDataToSave[indexPath] = locationPhoto
        }
        self.savedCells.append(indexPath)
    }
}
