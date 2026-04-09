//
//  CategoryMO+CoreDataProperties.swift
//  StudySprint
//
//  Created by Rene Torres on 8/4/26.
//
//

public import Foundation
public import CoreData


public typealias CategoryMOCoreDataPropertiesSet = NSSet

extension CategoryMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryMO> {
        return NSFetchRequest<CategoryMO>(entityName: "CategoryMO")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var categoryDescription: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var sessions: NSSet?

}

// MARK: Generated accessors for sessions
extension CategoryMO {

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: SessionMO)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: SessionMO)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

}

extension CategoryMO : Identifiable {

}
