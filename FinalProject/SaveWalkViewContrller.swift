//
//  SaveWalkViewContrller.swift
//  FinalProject
//
//  Created by Scott Kopczynski on 12/9/18.
//  Copyright © 2018 Scott Kopczynski. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import GoogleMaps

class SaveWalkViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    var walk: Walk? = nil
    var walks: [Walk]? = nil
    var distance: Double? = nil
    var duration: Int? = nil
    var steps: Int? = nil
    var doubleCoords: [Double]? = nil
    var mapCoords: [CLLocationCoordinate2D]? = nil
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var walkDistance: UILabel!
    @IBOutlet var walkDuration: UILabel!
    @IBOutlet var walkSteps: UILabel!
    @IBOutlet var walkCalories: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var userMap: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var calories = (0.035 * 76.4303143)
        calories +=  ((distance! * 1609 / Double(duration!)) / 1.7018) * (0.029) * (76.4303143)
        walkCalories.text = "Calories: \(String(format: "%.2f", calories))"
        if let distance = distance{
            walkDistance.text = "Distance: \(String(format: "%.2f", distance))"
        }
        if let duration = duration{
            walkDuration.text = "Time: \(String(format: "%02d", duration / 3600)):\(String(format: "%02d", (duration % 3600) / 60 )):\(String(format: "%02d", (duration % 3600) % 60))"
        }
        if let coords = mapCoords{
            setupMap(coordinates: coords)
        }
        if let userSteps = steps{
            walkSteps.text = "Steps \(userSteps)"
        }
        else{
            walkSteps.text = "Steps: Not Available on Simulator"
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func addImage(_ sender: UIButton){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style:
                .default, handler: { action in
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true,
                                 completion: nil)
            })
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { action in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true,
                             completion: nil)
            })
            alertController.addAction(photoLibraryAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    func setupMap(coordinates: [CLLocationCoordinate2D]){
        let path = GMSMutablePath()
        for i in 0 ..< coordinates.count {
            print(coordinates[i])
            path.add(coordinates[i])
        }
        let polyline = GMSPolyline(path: path)
        
        // Add the GMSPolyline object to the mapView
        polyline.map = self.userMap
        
        let camera = GMSCameraPosition.camera(withLatitude: coordinates[coordinates.count - 1].latitude + 0.0095,
                                              longitude: coordinates[coordinates.count - 1].longitude - 0.0095,
                                              zoom:14)
        self.userMap.animate(to: camera)
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage =
            info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func saveWalk(_ sender: Any) {
        let entity = NSEntityDescription.entity(forEntityName: "Walk", in: context)
        let newWalk = NSManagedObject(entity: entity!, insertInto: context)
        newWalk.setValue(Int64(duration!), forKey: "duration")
        newWalk.setValue(doubleCoords, forKey: "coordinates")
        newWalk.setValue(distance!, forKey: "distance")
        
        if let userSteps = steps{
            newWalk.setValue(Int64(userSteps), forKey: "steps")
        }
        else{
            newWalk.setValue(0, forKey: "steps")
        }
        do {
            try context.save()
        }
        catch {
            print("Error saving walk")
            
        }
    }
    /*
     Excerpt From: Apple Education. “App Development with Swift.” Apple Inc. - Education, 2017. iBooks. https://itunes.apple.com/us/book/app-development-with-swift/id1219117996?mt=11
     */
    
    /*
    @IBAction func buttonTapped(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        if tripDestinationText.text == ""{
            let alert = UIAlertController(title: "Input Error", message: "You forgot to type in a value for the destination", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if dateFormatter.date(from: startDateText.text!) == nil{
            let alert = UIAlertController(title: "Input Error", message: "Bad start date", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if dateFormatter.date(from: endDateText.text!) == nil{
            let alert = UIAlertController(title: "Input Error", message: "Bad end date", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            performSegue(withIdentifier: "newTrip", sender: self)
        }
    }
    */
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            if identifier == "newTrip" {
                if let name = tripDestinationText.text, let startDate = startDateText.text, let endDate = endDateText.text {
                    // what to do if one of the fields is empty??
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    /*
                     let newTrip = Trip(destination: name, startDate: dateFormatter.date(from: startDate)!, endDate: dateFormatter.date(from: endDate)!, imageName: "blank")*/
                    let newTrip = Trip(context: self.context)
                    newTrip.desitinationName = name
                    newTrip.startDate = dateFormatter.date(from: startDate)! as NSDate
                    newTrip.endDate = dateFormatter.date(from: endDate)! as NSDate
                    newTrip.imageFileName = writeImage()
                    self.trip = newTrip
                }
            }
        }
    }
    */
    func writeImage() -> String{
        let filename = "\(UUID().uuidString)"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // .userDomainMask refers to the user's home directory
        let fileURL = documentsDirectory.appendingPathComponent(filename).appendingPathExtension("jpg")
        if let imageData = imageView.image?.jpegData(compressionQuality: 1.0){
            try? imageData.write(to: fileURL)
        }
        return fileURL.path
    }
}
