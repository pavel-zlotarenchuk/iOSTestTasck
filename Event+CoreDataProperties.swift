//
//  Event+CoreDataProperties.swift
//  
//
//  Created by Mac on 3/29/18.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var bus_id: Int32
    @NSManaged public var from_date: String?
    @NSManaged public var from_highlight: Int32
    @NSManaged public var from_id: Int32
    @NSManaged public var from_info: String?
    @NSManaged public var from_name: String?
    @NSManaged public var from_time: String?
    @NSManaged public var id: Int32
    @NSManaged public var info: String?
    @NSManaged public var price: Int32
    @NSManaged public var reservation_count: Int32
    @NSManaged public var to_date: String?
    @NSManaged public var to_highlight: Int32
    @NSManaged public var to_id: Int32
    @NSManaged public var to_info: String?
    @NSManaged public var to_name: String?
    @NSManaged public var to_time: String?

}
