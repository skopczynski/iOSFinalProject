//
//  ViewController.swift
//  FinalProject
//
//  Created by Scott Kopczynski on 11/26/18.
//  Copyright © 2018 Scott Kopczynski. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import CoreMotion

class NewWalkViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var distanceWalkedLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    var steps: Int? = nil
    var path: [CLLocationCoordinate2D] = []
    var doubleCoords : [Double] = []
    var startTime = TimeInterval()
    var timer: Timer? = nil
    var seconds = 0 {
        didSet {
            timerLabel.text = "\(String(format: "%02d", seconds / 3600)):\(String(format: "%02d", (seconds % 3600) / 60 )):\(String(format: "%02d", (seconds % 3600) % 60))"
        }
    }
    let locationManager = CLLocationManager()
    var start:CLLocation!
    var last:CLLocation!
    var distanceWalked = 0.0
    var lastLat = 0.0
    var lastLon = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("Need to Enable Location")
        }
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        }
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func startTimer() {
        distanceWalked = 0.0
        start = nil
        last = nil
        startTiming()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func pausePressed(_ sender: UIButton) {
        print("pause pressed")
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func saveWalk() {
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
        performSegue(withIdentifier: "AddSegue", sender: self)
    }
    
    func startTiming() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) -> Void in
            self.seconds += 1
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        path.append(locValue)
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        doubleCoords.append(locValue.latitude)
        doubleCoords.append(locValue.longitude)
        lastLat = locValue.latitude
        lastLon = locValue.longitude
        if start == nil {
            start = locations.first as CLLocation!
        } else {
            let lastDistance = last.distance(from: locations.last as CLLocation!)
            distanceWalked += lastDistance * 0.000621371
            
            let trimmedDistance = String(format: "%.2f", distanceWalked)
            
            distanceWalkedLabel.text = "\(trimmedDistance)"
        }
        
        last = locations.last as CLLocation!
    }
    
    func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    print("Walking")
                } else if activity.stationary {
                    print("Stationary")
                } else if activity.running {
                    print("Running")
                } else if activity.automotive {
                    print("Automotive")
                }
            }
        }
    }

    func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            
            DispatchQueue.main.async {
                self!.steps = pedometerData.numberOfSteps as! Int
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "AddSegue" {
                if let newWalkVC = segue.destination as? SaveWalkViewController{
                    newWalkVC.distance = distanceWalked
                    newWalkVC.duration = seconds
                    newWalkVC.mapCoords = path
                    newWalkVC.steps = steps
                    newWalkVC.doubleCoords = doubleCoords
                }
            }
        }
    }

}

