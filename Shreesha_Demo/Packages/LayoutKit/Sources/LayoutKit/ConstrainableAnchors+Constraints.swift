//
//  File.swift
//
//
//  Created by Shreesha Kedlaya on 09/08/24.
//
import UIKit

// MARK: Public APIs
public extension ConstrainableAnchors {
    func makeConstraint(@ConstraintBuilder constraints: (ConstraintCreator.Type) -> [ConstraintCreator]) {
        constraints(ConstraintCreator.self)
            .flatMap(\.constraints)
            .forEach(set(_:))
    }

    /// This function is used to add constraints to a view, and this in turn calls
    /// another private function of the same name.
    /// - Parameter constraints: An array of "ConstraintCreator" objects
    func set(_ constraints: ConstraintCreator...) {
        constraints.forEach { constraintCreator in
            let allConstraints = constraintCreator.constraints
            allConstraints.forEach { self.set($0) }
        }
    }

    /// This function is used to get constraints of a view
    /// - Parameter constraint: A GetConstraint object
    /// - Returns: An optional NSLayoutConstraint
    func get(_ constraint: ConstraintCreator.ConstraintType) -> NSLayoutConstraint? {
        switch constraint {
        case .top:
            return topConstraint
        case .bottom:
            return bottomConstraint
        case .leading:
            return leadingConstraint
        case .trailing:
            return trailingConstraint
        case .width:
            return widthConstraint
        case .height:
            return heightConstraint
        case .centerX:
            return centerXConstraint
        case .centerY:
            return centerYConstraint
        case .aspectRatio:
            return aspectRatioConstraint
        }
    }
}

/// A struct containing all keys for Objective-C runtime association


private struct ViewAssociatedKeys {
    nonisolated(unsafe) static var leadingConstraint = "leadingConstraint"
    nonisolated(unsafe) static var trailingConstraint = "trailingConstraint"
    nonisolated(unsafe) static var topConstraint = "topConstraint"
    nonisolated(unsafe) static var bottomConstraint = "bottomConstraint"
    nonisolated(unsafe) static var heightConstraint = "heightConstraint"
    nonisolated(unsafe) static var widthConstraint = "widthConstraint"
    nonisolated(unsafe) static var centerXConstraint = "centerXConstraint"
    nonisolated(unsafe) static var centerYConstraint = "centerYConstraint"
    nonisolated(unsafe) static var aspectRatioConstraint = "aspectRatioConstraint"
}

nonisolated(unsafe) private let constraintAssociation = ObjectAssociation<NSLayoutConstraint>()

// MARK: Private APIs
private extension ConstrainableAnchors {

    /// This function is used to add constraints to a view
    /// - Parameter constraint: A array of Constraint object
    func set(_ constraint: ConstraintCreator.Constraint) {
        let nsLayoutConstraint = constraint.getConstraint(for: self)

        guard let _ = nsLayoutConstraint.firstItem as? ConstrainableAnchors else {
            assertionFailure("Constraint is not attached to a ConstrainableAnchors. Please check")
            return
        }

        switch constraint {
        case .top:
            deactivateIfActive(topConstraint)
            topConstraint = nsLayoutConstraint

        case .leading:
            deactivateIfActive(leadingConstraint)
            leadingConstraint = nsLayoutConstraint

        case .height:
            deactivateIfActive(heightConstraint)
            heightConstraint = nsLayoutConstraint

        case .width:
            deactivateIfActive(widthConstraint)
            widthConstraint = nsLayoutConstraint

        case .bottom:
            deactivateIfActive(bottomConstraint)
            bottomConstraint = nsLayoutConstraint

        case .trailing:
            deactivateIfActive(trailingConstraint)
            trailingConstraint = nsLayoutConstraint

        case .before:
            deactivateIfActive(trailingConstraint)
            trailingConstraint = nsLayoutConstraint

        case .above:
            deactivateIfActive(bottomConstraint)
            bottomConstraint = nsLayoutConstraint

        case .after:
            deactivateIfActive(leadingConstraint)
            leadingConstraint = nsLayoutConstraint

        case .below:
            deactivateIfActive(topConstraint)
            topConstraint = nsLayoutConstraint

        case .centerX:
            deactivateIfActive(centerXConstraint)
            centerXConstraint = nsLayoutConstraint

        case .centerY:
            deactivateIfActive(centerYConstraint)
            centerYConstraint = nsLayoutConstraint

        case .aspectRatio:
            deactivateIfActive(aspectRatioConstraint)
            aspectRatioConstraint = nsLayoutConstraint

        case .equate:
            deactivateIfActive(nsLayoutConstraint)
        }

        prepareForActivatingConstraints()

        if isValid(constraint: nsLayoutConstraint) {
            nsLayoutConstraint.isActive = true
        }
    }

    /// This function checks if the constraint is already active or if repeated constraints
    /// are being applied. If that is the case, it deactivates the previous one, and always
    /// honors the latest one.
    /// - Parameter constraint: a NSLayoutConstraint to be validated
    func deactivateIfActive(_ constraint: NSLayoutConstraint?) {
        if let unwrappedConstraint = constraint, constraint?.isActive == true {
            unwrappedConstraint.isActive = false
        }
    }

    /// This function validates the constraint before activating it
    /// - Parameter constraint: The NSLayoutConstraint to be validated
    /// - Returns: Whether to activate the constraint or not.
    func isValid(constraint: NSLayoutConstraint) -> Bool {
        if Thread.isMainThread == false {
            assertionFailure("This API can only be used from the main thread")
        }

        guard let _ = constraint.firstItem as? ConstrainableAnchors else {
            assertionFailure("Constraint is not attached to a ConstrainableAnchors. Please check")
            return false
        }

        return true
    }
}

private extension ConstrainableAnchors {
    /// The parameter for holding leading constraint on UIView
    var leadingConstraint: NSLayoutConstraint? {
        get { constraintAssociation.get(index: self, key: &ViewAssociatedKeys.leadingConstraint) }
        set { constraintAssociation.set(index: self, key: &ViewAssociatedKeys.leadingConstraint, newValue: newValue) }
    }

    /// The parameter for holding trailing constraint on UIView
    var trailingConstraint: NSLayoutConstraint? {
        get { constraintAssociation.get(index: self, key: &ViewAssociatedKeys.trailingConstraint) }
        set { constraintAssociation.set(index: self, key: &ViewAssociatedKeys.trailingConstraint, newValue: newValue) }
    }

    /// The parameter for holding top constraint on UIView
    var topConstraint: NSLayoutConstraint? {
        get { constraintAssociation.get(index: self, key: &ViewAssociatedKeys.topConstraint) }
        set { constraintAssociation.set(index: self, key: &ViewAssociatedKeys.topConstraint, newValue: newValue) }
    }

    /// The parameter for holding bottom constraint on UIView
    var bottomConstraint: NSLayoutConstraint? {
        get { constraintAssociation.get(index: self, key: &ViewAssociatedKeys.bottomConstraint) }
        set { constraintAssociation.set(index: self, key: &ViewAssociatedKeys.bottomConstraint, newValue: newValue) }
    }

    /// The parameter for holding height constraint on UIView
    var heightConstraint: NSLayoutConstraint? {
        get { constraintAssociation.get(index: self, key: &ViewAssociatedKeys.heightConstraint) }
        set { constraintAssociation.set(index: self, key: &ViewAssociatedKeys.heightConstraint, newValue: newValue) }
    }

    /// The parameter for holding width constraint on UIView
    var widthConstraint: NSLayoutConstraint? {
        get { constraintAssociation.get(index: self, key: &ViewAssociatedKeys.widthConstraint) }
        set { constraintAssociation.set(index: self, key: &ViewAssociatedKeys.widthConstraint, newValue: newValue) }
    }

    /// The parameter for holding centerX constraint on UIView
    var centerXConstraint: NSLayoutConstraint? {
        get { constraintAssociation.get(index: self, key: &ViewAssociatedKeys.centerXConstraint) }
        set { constraintAssociation.set(index: self, key: &ViewAssociatedKeys.centerXConstraint, newValue: newValue) }
    }

    /// The parameter for holding centerY constraint on UIView
    var centerYConstraint: NSLayoutConstraint? {
        get { constraintAssociation.get(index: self, key: &ViewAssociatedKeys.centerYConstraint) }
        set { constraintAssociation.set(index: self, key: &ViewAssociatedKeys.centerYConstraint, newValue: newValue) }
    }

    /// The parameter for holding aspect ratio constraint on UIView
    var aspectRatioConstraint: NSLayoutConstraint? {
        get { constraintAssociation.get(index: self, key: &ViewAssociatedKeys.aspectRatioConstraint) }
        set { constraintAssociation.set(index: self, key: &ViewAssociatedKeys.aspectRatioConstraint, newValue: newValue) }
    }
}
