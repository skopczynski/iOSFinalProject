//
//  AllWalksViewController.swift
//  FinalProject
//
//  Created by Scott Kopczynski on 12/10/18.
//  Copyright © 2018 Scott Kopczynski. All rights reserved.
//

import Foundation
import CoreData
import GoogleMaps

class AllWalksViewController: UITableViewController{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var walkArray = [Walk]()
    var calories: Double? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectory)
        
        loadWalks()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return walkArray.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalkCell", for: indexPath)
        let walk = walkArray[indexPath.row]
        calories = (0.035 * 76.4303143)
        calories! +=  ((walk.distance * 1609 / Double(walk.duration)) / 1.7018) * (0.029) * (76.4303143)
        cell.textLabel?.text = "Distance: \(String(format: "%.2f", walk.distance)) Time: \(String(format: "%02d", walk.duration / 3600)):\(String(format: "%02d", (walk.duration % 3600) / 60 )):\(String(format: "%02d", (walk.duration % 3600) % 60)) Calories: \(String(format: "%.2f", calories!))"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(walkArray[indexPath.row])
            walkArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveWalks()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let walk = walkArray.remove(at: sourceIndexPath.row)
        walkArray.insert(walk, at: destinationIndexPath.row)
        tableView.reloadData()
    }
 
    
    func loadWalks() {
        let request: NSFetchRequest<Walk> = Walk.fetchRequest()
        do {
            walkArray = try context.fetch(request)
        }
        catch {
            print("Error fetching categories: \(error)")
        }
        tableView.reloadData()
    }
    func saveWalks() {
        do {
            try context.save() // like a git commit
        }
        catch {
            print("Error saving categories")
        }
        
        self.tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "walkDetails"  {
            
            guard let walkDetailVC = segue.destination as? WalkDetailViewController else {
                return
            }
            
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
                return
            }
            
            walkDetailVC.calories = calories
            let distance = walkArray[selectedIndexPath.row].distance
            let steps = walkArray[selectedIndexPath.row].steps
            let duration = walkArray[selectedIndexPath.row].duration
            let coordinates = walkArray[selectedIndexPath.row].coordinates
            walkDetailVC.distance = distance
            walkDetailVC.steps = Int(steps)
            walkDetailVC.duration = Int(duration)
            walkDetailVC.coordinates = coordinates
            //let calorie
            //itemsTableVC.category = category
        }
    }
}
