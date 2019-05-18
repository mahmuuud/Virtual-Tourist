//
//  MapVC.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/18/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    var lat:Double!
    var lon:Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func addAnnotation(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            mapView.addAnnotation(annotation)
            print(mapView.annotations.count)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let imagesVC = segue.destination as! LocationImagesVC
        imagesVC.lat = self.lat
        imagesVC.lon = self.lon
    }

}

extension MapVC:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView") as? MKPinAnnotationView
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            pinView?.animatesDrop = true
            pinView?.pinTintColor = .red
        }
        
        else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        lat = view.annotation?.coordinate.latitude
        lon = view.annotation?.coordinate.longitude
        self.performSegue(withIdentifier: "showImages", sender: self)
    }

}
