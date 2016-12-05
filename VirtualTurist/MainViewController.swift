//
//  ViewController.swift
//  VirtualTurist
//
//  Created by apple on 15/11/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit
import MapKit
import CoreData

final class PinPointAnnotation : MKPointAnnotation {
    var pin : Pin?
}
final class MainViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupDeleteAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.removeAnnotations(mapView.annotations)
        let pins = fetchAllPins()
        pins.forEach { pin in
            let annotation = PinPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.lat), longitude: CLLocationDegrees(pin.lng))
            annotation.title = ""
            annotation.pin = pin
            mapView.addAnnotation(annotation)
        }
    }
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        let app = UIApplication.shared.delegate as? AppDelegate
        do {
            return try app?.stack.context.fetch(fetchRequest) ?? [Pin]()
        } catch {
            return [Pin]()
        }
    }
    
    func setupDeleteAll() {
        let delete = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteAll))
        navigationItem.rightBarButtonItem = delete
    }
    
    func deleteAll() {
        mapView.removeAnnotations(mapView.annotations)
       let app = UIApplication.shared.delegate as? AppDelegate
        try? app?.stack.dropAllData()
    }
    
    fileprivate func setupMap() {
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(insertPin))
        
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        
        
    }
    
    func insertPin(getstureRecognizer : UIGestureRecognizer) {
        if getstureRecognizer.state != .began { return }
        
        let touchPoint = getstureRecognizer.location(in: self.mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = PinPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        annotation.title = ""
        
        
        if let app = UIApplication.shared.delegate as? AppDelegate {
            let pin = Pin(context: app.stack.context)
            pin.lat = Float(touchMapCoordinate.latitude)
            pin.lng = Float(touchMapCoordinate.longitude)
            FlickerAPI.images(pin : pin) { list in
                list?.forEach { item in
                    if let path = item.imagePath {
                        FlickerAPI.downloadImage(pin: pin, path: path)
                    }
                }
                pin.load = true
            }
            annotation.pin = pin
        }
        mapView.addAnnotation(annotation)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.image = UIImage(named: "pin")
        annotationView.canShowCallout = false
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? PinPointAnnotation, let pin = annotation.pin {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController {
                vc.pin = pin
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        mapView.subviews.filter({ $0.isKind(of: PointOfInteressView.self)}).forEach({ $0.removeFromSuperview()})
    }
    
}

final class PointOfInteressView : UIView {
    init(center : CGPoint) {
        super.init(frame: CGRect(origin: center, size: CGSize(width: 200, height: 60)))
        backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

