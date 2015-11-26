//
//  RiderViewController.swift
//  UberApp
//
//  Created by Ranjan on 11/25/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit


@available(iOS 8.0, *)
class RiderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callUberButton: UIButton!
    
    var locationManager:CLLocationManager!
    
    var latitude : CLLocationDegrees = 0.0
    
    var longitude : CLLocationDegrees = 0.0
    
    var riderRequestActive = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        let location : CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        self.map.removeAnnotations(map.annotations)
        
        var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = pinLocation
        annotation.title = "Your Location"
        
        map.addAnnotation(annotation)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutForRider"
        {
            PFUser.logOut()
        }
    }
    

    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false
        {
        
        var riderRequest = PFObject(className:"riderRequest")
        riderRequest["userName"] = PFUser.currentUser()?.username
        riderRequest["location"] = PFGeoPoint(latitude: latitude, longitude:longitude)
        riderRequest.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                
                self.callUberButton .setTitle("Cancel Uber", forState: UIControlState.Normal)
                
            
            } else {
                let alert = UIAlertController(title: "Couldn't call Uber", message: "Please try again later!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
            riderRequestActive = true
    }
        else{
            
            self.callUberButton .setTitle("Request an Uber", forState: UIControlState.Normal)
            
            riderRequestActive = false
            
            var query = PFQuery(className:"riderRequest")
            query.whereKey("userName", equalTo: (PFUser.currentUser()?.username)!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
    
}
