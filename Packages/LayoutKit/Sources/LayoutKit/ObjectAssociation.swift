//
//  ObjectAssociation.swift
//
//
//  Created by Shreesha Kedlaya on 11/08/24.
//

import Foundation

/// Helper class for getting and setting Objective-C runtime properties on objects.
/// In this case object -> UIView and properties -> NSLayoutConstraint
public final class ObjectAssociation<T: AnyObject> {

    private let policy: objc_AssociationPolicy

    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        self.policy = policy
    }

    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public func get(index: AnyObject, key: inout String) -> T? {
        return objc_getAssociatedObject(index, &key) as! T?
    }

    /// Set associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public func set(index: AnyObject, key: inout String, newValue: T?) {
        objc_setAssociatedObject(index, &key, newValue, policy)
    }
}
