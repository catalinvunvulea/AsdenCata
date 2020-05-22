//
//  OnRunVC.swift
//  RunApp
//
//  Created by Dumitru Catalin Vunvulea on 20/05/2020.
//  Copyright © 2020 Dumitru Catalin Vunvulea. All rights reserved.
//

import UIKit
import MapKit

class OnRunVC: LocationVC {  //inherit everithing from LocationVC
    
    @IBOutlet weak var swipeBackgroundImg: UIImageView!
    @IBOutlet weak var sliderImg: UIImageView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var pauseBtn: UIButton!
    
    
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    
    var runDistance = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(endRunSwiped(sender:)))
        sliderImg.addGestureRecognizer(swipeGesture)
        sliderImg.isUserInteractionEnabled = true
        swipeGesture.delegate = self as? UIGestureRecognizerDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager?.delegate = self
        manager?.distanceFilter = 10     //distance will update each 10 meeters
        onRun()
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        
    }
    
    
    func onRun() {   //update location
        manager?.startUpdatingLocation()
    }
    
    func endRun() {
        manager?.stopUpdatingLocation()
    }
    
    
    @objc func endRunSwiped(sender: UIPanGestureRecognizer) {
        let minAdjust: CGFloat = 80 //values are given based on how they look on the screen
        let maxAdjust: CGFloat = 129
        if let sliderView = sender.view {
            if sender.state == UIGestureRecognizer.State.began || sender.state == UIGestureRecognizer.State.changed {
                let translation = sender.translation(in: self.view) // give us how many points we are adding or substracting from the current location
                if sliderView.center.x >= (swipeBackgroundImg.center.x - minAdjust) && sliderView.center.x <= (swipeBackgroundImg.center.x + maxAdjust) {
                    sliderView.center.x = sliderView.center.x + translation.x //seting the center of the slider to move according to the swipeGesture, between the min and max points(Adjust
                } else if sliderView.center.x >= (swipeBackgroundImg.center.x + maxAdjust){
                    sliderView.center.x = swipeBackgroundImg.center.x + maxAdjust //adjust if slider got to far to right from view
                    // TO DO: end running code goes here
                    
                    dismiss(animated: true, completion: nil)
                } else {
                    sliderView.center.x = swipeBackgroundImg.center.x - minAdjust    //adjust if slider go to far to left from view
                }
                sender.setTranslation(CGPoint.zero, in: self.view) //set the translation value of the coordonate system in the specifil view
            } else if sender.state == UIGestureRecognizer.State.ended {  //se the slider to return to initial value if not dragged to end
                UIView.animate(withDuration: 0.2) {
                    sliderView.center.x = self.swipeBackgroundImg.center.x - minAdjust
                }
                
            }
            
        }
        
    }
    
    
}

extension OnRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways { //it is mandatory to check if user has approved to share location
            checkLocationAuthStatus()
        }
    }
    
    // update the locations in an array; it will be called every time the location gets updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first     //we populate var startLocation with the first location
        } else if let location = locations.last { // it means we have started to run, bun paused
            runDistance += lastLocation.distance(from: location)  //setting the runDistance
            distanceLbl.text = "\(runDistance.metersToKm(decimals: 2))"
        }
        lastLocation = locations.last
    }
    
}
