//
//  Photo+CoreDataProperties.swift
//  VirtualTurist
//
//  Created by apple on 04/12/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var data: Data?
    @NSManaged public var pin: Pin?

}
