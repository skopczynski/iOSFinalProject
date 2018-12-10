//
//  WalkDetailViewController.swift
//  FinalProject
//
//  Created by Scott Kopczynski on 12/10/18.
//  Copyright © 2018 Scott Kopczynski. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit
import CoreData

class WalkDetailViewController: UIViewController{
    
    var calories: Double? = nil
    var distance: Double? = nil
    var duration: Int? = nil
    var steps: Int? = nil
    var coordinates: [Double]? = nil
    var properCoords: [CLLocationCoordinate2D] = []
    
    @IBOutlet var walkDistance: UILabel!
    @IBOutlet var walkDuration: UILabel!
    @IBOutlet var walkSteps: UILabel!
    @IBOutlet var walkCalories: UILabel!
    @IBOutlet var userMap: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walkCalories.text = "Calories: \(String(format: "%.2f", calories!))"
        if let distance = distance{
            walkDistance.text = "Distance: \(String(format: "%.2f", distance))"
        }
        if let duration = duration{
            walkDuration.text = "Time: \(String(format: "%02d", duration / 3600)):\(String(format: "%02d", (duration % 3600) / 60 )):\(String(format: "%02d", (duration % 3600) % 60))"
        }
        if let coords = coordinates{
            genCoords(coordinates: coords)
            setupMap()
        }
        if let userSteps = steps{
            walkSteps.text = "Steps: \(userSteps)"
        }
        else{
            walkSteps.text = "Steps: Not Available on Simulator"
        }
    }
    func genCoords(coordinates: [Double]){
        var i = 0
        
        while i < coordinates.count{
            let coordinate = CLLocationCoordinate2D(latitude: coordinates[i], longitude: coordinates[i+1])
            properCoords.append(coordinate)
            i = i + 2
        }
        
    }
    func setupMap(){
        let path = GMSMutablePath()
        for i in 0 ..< properCoords.count {
            path.add(properCoords[i])
        }
        let polyline = GMSPolyline(path: path)
        
        // Add the GMSPolyline object to the mapView
        polyline.map = self.userMap
        
        let camera = GMSCameraPosition.camera(withLatitude: properCoords[properCoords.count - 1].latitude + 0.0095,
                                              longitude: properCoords[properCoords.count - 1].longitude - 0.0095,
                                              zoom:14)
        self.userMap.animate(to: camera)
    }
}
