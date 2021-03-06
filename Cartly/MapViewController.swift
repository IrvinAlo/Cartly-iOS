//
//  ViewController.swift
//  Cartly
//
//  Created by Vrezh Gulyan on 10/10/16.
//  Copyright © 2016 Revenge Apps Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var typeSelector: UISegmentedControl!

    var start : CLLocationCoordinate2D!
    var end : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mapView.showsUserLocation = true
        mapView.delegate = self

        let csunLocation = CLLocation(latitude: 34.238476, longitude: -118.529330)
        
        mapView.mapType = MKMapType.satellite
        typeSelector.selectedSegmentIndex = 1
        
        centerOnUser(location: csunLocation)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    @IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
        sender.numberOfTapsRequired = 2
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print(touchMapCoordinate)

        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = touchMapCoordinate

        if start == nil {
            start = touchMapCoordinate
            pointAnnotation.title = "Oviatt Library"
        } else {
            end = touchMapCoordinate
            pointAnnotation.title = "VPAC"
        }
        
        mapView.addAnnotation(pointAnnotation)

    }

    @IBAction func requestPressed(_ sender: AnyObject) {

        getDirections(from: start, to: end)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let path = MKPolylineRenderer(overlay: overlay)
        path.strokeColor = UIColor.red
        path.lineWidth = 2.0
        
        return path
    }
    
    func getDirections(from : CLLocationCoordinate2D, to : CLLocationCoordinate2D){
        let directions = MKDirectionsRequest()
        let start = MKPlacemark(coordinate: from)
        let end = MKPlacemark(coordinate: to)
        directions.source = MKMapItem(placemark: start)
        directions.destination = MKMapItem(placemark: end)
        directions.transportType = MKDirectionsTransportType.walking
        
        let route = MKDirections(request: directions)
        route.calculate(completionHandler: {
            (response, error) in
            
            if let route = response?.routes{
                let path = route.first
                print(path)
                self.mapView.add((path?.polyline)!, level: MKOverlayLevel.aboveRoads)
                self.mapView.setNeedsDisplay()
                
                let alert = UIAlertController(title: "Success", message: "Your Carty will arrive in 3 min.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive , handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                print("no routes")
            }
            
        })
    }

    
    @IBAction func zoomToCurrentLocation(_ sender: UIBarButtonItem) {
        centerOnUser(location: locationManager.location!)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerOnUser(location: locations.first!)
    }
    
    
    
    func centerOnUser (location : CLLocation){
        
        let spanX = 0.01
        let spanY = 0.01
        var region : MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = location.coordinate.latitude
        region.center.longitude = location.coordinate.longitude
        region.span.latitudeDelta = spanX
        region.span.longitudeDelta = spanY
        
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func setMapType(_ sender: UISegmentedControl) {
        
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = MKMapType.standard
            break
        case 1:
            mapView.mapType = MKMapType.satellite
            break
        case 2:
            mapView.mapType = MKMapType.hybrid
            break
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

