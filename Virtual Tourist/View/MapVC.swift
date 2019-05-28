//
//  MapVC.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/18/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    var span:MKCoordinateSpan!
    var lat:Double!
    var lon:Double!
    var dataController:DataController!
    private var pins:[Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configMapView()
    }
    
    fileprivate func configMapView() {
        self.mapView.isZoomEnabled = true
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(gestureRecognizer)
        if UserDefaults.standard.value(forKey: "locationLat") != nil{
            mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: UserDefaults.standard.value(forKey: "locationLat") as! CLLocationDegrees, longitude: UserDefaults.standard.value(forKey: "locationLon") as! CLLocationDegrees), span: self.span), animated: true)
        }
        else{
            mapView.region.span = self.span
        }
        
        restorePins()
    }
    
    func restorePins(){
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let pins = try? dataController.viewContext.fetch(fetchRequest){
            self.pins = pins
        }
        
        if self.pins.count != 0{
            for pin in self.pins{
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = pin.lat
                annotation.coordinate.longitude = pin.lon
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    @objc func addAnnotation(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            mapView.addAnnotation(annotation)
            let pin = Pin(context: dataController.viewContext)
            pin.lat = annotation.coordinate.latitude
            pin.lon = annotation.coordinate.longitude
            pins.append(pin)
            try? dataController.viewContext.save()
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("new span: ",mapView.region.span)
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "spanLat")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta,forKey: "spanLon")
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "locationLat")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "locationLon")
        UserDefaults.standard.synchronize()
        
    }

}
