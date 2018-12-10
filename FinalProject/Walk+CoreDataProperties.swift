//
//  Walk+CoreDataProperties.swift
//  
//
//  Created by Scott Kopczynski on 12/9/18.
//
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var coordinates: [Double]?
    @NSManaged public var duration: Int64
    @NSManaged public var imageFile: String?
    @NSManaged public var steps: Int64
    @NSManaged public var distance: Double

}
