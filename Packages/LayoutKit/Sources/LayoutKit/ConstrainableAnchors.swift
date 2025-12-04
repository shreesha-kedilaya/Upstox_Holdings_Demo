//
//  File.swift
//
//
//  Created by Shreesha Kedlaya on 09/08/24.
//
import UIKit

/// A protocol to handle adding constraints.
@MainActor
public protocol ConstrainableAnchors: AnyObject {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }

    /// This method is called before activating the constraint.
    /// use this method to prepare for activation
    func prepareForActivatingConstraints()
}

extension UIView: ConstrainableAnchors {
    public func prepareForActivatingConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}
extension UILayoutGuide: ConstrainableAnchors {
    public func prepareForActivatingConstraints() {}
}
