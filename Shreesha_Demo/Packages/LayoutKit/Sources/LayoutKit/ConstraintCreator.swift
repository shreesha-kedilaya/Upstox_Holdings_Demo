//
//  File.swift
//
//
//  Created by Shreesha Kedlaya on 09/08/24.
//
import UIKit

@MainActor
public final class ConstraintCreator: NSObject {
    let constraints: [Constraint]

    public init(constraints: [Constraint]) {
        self.constraints = constraints
    }

    /// Public enum containing all possible cases for "Getting" the constraint
    public enum ConstraintType {

        case top
        case bottom
        case leading
        case trailing
        case width
        case height
        case centerX
        case centerY
        case aspectRatio
    }

    /// Public enum containing all possible cases for constraints
    public enum Constraint {

        case equate(viewAttribute: NSLayoutConstraint.Attribute, toView: ConstrainableAnchors, toViewAttribute: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation, constant: CGFloat, multiplier: CGFloat)

        case height(view: ConstrainableAnchors?, relation: NSLayoutConstraint.Relation, constant: CGFloat, multiplier: CGFloat)

        case width(view: ConstrainableAnchors?, relation: NSLayoutConstraint.Relation, constant: CGFloat, multiplier: CGFloat)

        case top(view: ConstrainableAnchors, constant: CGFloat, relation: NSLayoutConstraint.Relation, multiplier: CGFloat)

        case bottom(view: ConstrainableAnchors, constant: CGFloat, relation: NSLayoutConstraint.Relation, multiplier: CGFloat)

        case leading(view: ConstrainableAnchors, constant: CGFloat, relation: NSLayoutConstraint.Relation, multiplier: CGFloat)

        case trailing(view: ConstrainableAnchors, constant: CGFloat, relation: NSLayoutConstraint.Relation, multiplier: CGFloat)

        case before(view: ConstrainableAnchors, constant: CGFloat, relation: NSLayoutConstraint.Relation, multiplier: CGFloat)

        case after(view: ConstrainableAnchors, constant: CGFloat, relation: NSLayoutConstraint.Relation, multiplier: CGFloat)

        case above(view: ConstrainableAnchors, constant: CGFloat, relation: NSLayoutConstraint.Relation, multiplier: CGFloat)

        case below(view: ConstrainableAnchors, constant: CGFloat, relation: NSLayoutConstraint.Relation, multiplier: CGFloat)

        case centerX(view: ConstrainableAnchors, constant: CGFloat, relation: NSLayoutConstraint.Relation, multiplier: CGFloat)

        case centerY(view: ConstrainableAnchors, constant: CGFloat, relation: NSLayoutConstraint.Relation, multiplier: CGFloat)

        case aspectRatio(ratio: CGFloat)

        /// A helper method which returns a NSLayoutConstraint on the basis of provided values
        @MainActor func getConstraint(for view: ConstrainableAnchors) -> NSLayoutConstraint {

            switch self {

            case .equate(viewAttribute: let viewAttribute, toView: let toView, toViewAttribute: let toViewAttribute, relation: let relation, constant: let constant, let multiplier):

                return NSLayoutConstraint(item: view, attribute: viewAttribute, relatedBy: relation, toItem: toView, attribute: toViewAttribute, multiplier: multiplier, constant: constant)

            case .height(view: let toView, relation: let relation, constant: let constant, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .height, relatedBy: relation, toItem: toView, attribute: toView == nil ? .notAnAttribute : .height, multiplier: multiplier, constant: constant)

            case .width(view: let toView, relation: let relation, constant: let constant, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .width, relatedBy: relation, toItem: toView, attribute: toView == nil ? .notAnAttribute : .width, multiplier: multiplier, constant: constant)

            case .top(view: let toView, constant: let constant, relation: let relation, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .top, relatedBy: relation, toItem: toView, attribute: .top, multiplier: multiplier, constant: constant)

            case .bottom(view: let toView, constant: let constant, relation: let relation, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: relation.inverse(), toItem: toView, attribute: .bottom, multiplier: multiplier, constant: -constant)

            case .leading(view: let toView, constant: let constant, relation: let relation, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .leading, relatedBy: relation, toItem: toView, attribute: .leading, multiplier: multiplier, constant: constant)

            case .trailing(view: let toView, constant: let constant, relation: let relation, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: relation.inverse(), toItem: toView, attribute: .trailing, multiplier: multiplier, constant: -constant)

            case .before(view: let toView, constant: let constant, relation: let relation, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: relation.inverse(), toItem: toView, attribute: .leading, multiplier: multiplier, constant: -constant)

            case .above(view: let toView, constant: let constant, relation: let relation, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: relation.inverse(), toItem: toView, attribute: .top, multiplier: multiplier, constant: -constant)

            case .after(view: let toView, constant: let constant, relation: let relation, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .leading, relatedBy: relation, toItem: toView, attribute: .trailing, multiplier: multiplier, constant: constant)

            case .below(view: let toView, constant: let constant, relation: let relation, let multiplier):
                return NSLayoutConstraint(item: view, attribute: .top, relatedBy: relation, toItem: toView, attribute: .bottom, multiplier: multiplier, constant: constant)

            case .centerX(view: let toView, constant: let constant, relation: let relation, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: relation, toItem: toView, attribute: .centerX, multiplier: multiplier, constant: constant)

            case .centerY(view: let toView, constant: let constant, relation: let relation, let multiplier):

                return NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: relation, toItem: toView, attribute: .centerY, multiplier: multiplier, constant: constant)

            case .aspectRatio(let constant):

                return view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: constant)
            }
        }
    }

    /// Use this method to equate constraints between any two attributes of two views
    /// - Parameters:
    ///   - attribute: the attribute of main view
    ///   - view: secondary view
    ///   - toAttribute: the attribute of secondary view
    ///   - relation: the Layout constraint relation
    ///   - constant: the height to be fixed
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func equateAttribute(_ attribute: NSLayoutConstraint.Attribute, toView view: ConstrainableAnchors, toAttribute: NSLayoutConstraint.Attribute, withRelation relation: NSLayoutConstraint.Relation, _ constant: CGFloat = 0, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.equate(viewAttribute: attribute, toView: view, toViewAttribute: toAttribute, relation: relation, constant: constant, multiplier: multiplier)])
    }

    /// Use this method to provide the height of the view
    /// - Parameters:
    ///   - constant: the height to be fixed
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func height(_ constant: CGFloat, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.height(view: nil, relation: relation, constant: constant, multiplier: multiplier)])
    }

    /// Use this method to provide the height of the view
    /// - Parameters:
    ///   - view: the `toView` height to be anchored with
    ///   - constant: A constant that can be offsetted from the `view` height. By default it will be `zero`.
    ///   - relation: the layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func sameHeight(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.height(view: view, relation: relation, constant: constant, multiplier: multiplier)])
    }

    /// Use this method to provide the width of the view
    /// - Parameters:
    ///   - constant: the width to be fixed
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func width(_ constant: CGFloat, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.width(view: nil, relation: relation, constant: constant, multiplier: multiplier)])
    }

    /// Use this method to provide the width of the view
    /// - Parameters:
    ///   - view: the `toView` width to be anchored with
    ///   - constant: A constant that can be offsetted from the `view` width. By default it will be `zero`.
    ///   - relation: the layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func sameWidth(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.width(view: view, relation: relation, constant: constant, multiplier: multiplier)])
    }

    /// Use this method to align top anchors of two views
    /// - Parameters:
    ///   - view: the view to align top anchor with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func top(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.top(view: view, constant: constant, relation: relation, multiplier: multiplier)])
    }

    /// Use this method to align bottom anchors of two views
    /// - Parameters:
    ///   - view: the view to align bottom anchor with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func bottom(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.bottom(view: view, constant: constant, relation: relation, multiplier: multiplier)])
    }

    /// Use this method to align leading anchors of two views
    /// - Parameters:
    ///   - view: the view to align leading anchor with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func leading(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.leading(view: view, constant: constant, relation: relation, multiplier: multiplier)])
    }

    /// Use this method to align trailing anchors of two views
    /// - Parameters:
    ///   - view: the view to align trailing anchor with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func trailing(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.trailing(view: view, constant: constant, relation: relation, multiplier: multiplier)])
    }

    /// Use this method to align the trailing and leading anchors of two views
    /// - Parameters:
    ///   - view: the view to align trailing anchor with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func before(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.before(view: view, constant: constant, relation: relation, multiplier: multiplier)])
    }

    /// Use this method to align the leading and trailing anchors of two views
    /// - Parameters:
    ///   - view: the view to align leading anchor with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func after(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.after(view: view, constant: constant, relation: relation, multiplier: multiplier)])
    }

    /// Use this method to align the bottom and top anchors of two views
    /// - Parameters:
    ///   - view: the view to align bottom anchor with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func above(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.above(view: view, constant: constant, relation: relation, multiplier: multiplier)])
    }

    /// Use this method to align the top and bottom anchors of two views
    /// - Parameters:
    ///   - view: the view to align top anchor with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func below(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.below(view: view, constant: constant, relation: relation, multiplier: multiplier)])
    }

    /// Use this method to align the centerX anchors of two views
    /// - Parameters:
    ///   - view: the view to align center X anchor with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func centerX(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.centerX(view: view, constant: constant, relation: relation, multiplier: multiplier)])
    }

    /// Use this method to align the centerY anchors of two views
    /// - Parameters:
    ///   - view: the view to align center Y anchor with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    ///   - multiplier: multiplier for the constraint
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func centerY(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.centerY(view: view, constant: constant, relation: relation, multiplier: multiplier)])
    }

    /// Use this method to align the center anchors of two views
    /// - Parameter view: the view to align center anchors with
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func centerView(_ view: ConstrainableAnchors) -> ConstraintCreator {
        ConstraintCreator(constraints: ConstraintCreator.centerX(view).constraints + ConstraintCreator.centerY(view).constraints)
    }

    /// Use this method to align the height and width anchors of a view
    /// - Parameters:
    ///   - width: the constant to be applied while fixing width
    ///   - height: the constant to be applied while fixing height
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func size(_ width: CGFloat, _ height: CGFloat) -> ConstraintCreator {
        ConstraintCreator(constraints: ConstraintCreator.width(width).constraints +  ConstraintCreator.height(height).constraints)
    }

    /// Use this method to align the height and width anchors of a view
    /// - Parameter size: the constant to be applied while fixing size
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func size(_ size: CGSize) -> ConstraintCreator {
        ConstraintCreator(constraints: ConstraintCreator.width(size.width).constraints +  ConstraintCreator.height(size.height).constraints)
    }

    /// Use this method to align the leading and trailing anchors of a view
    /// /Param - view -
    /// /Param - constant -
    /// /Returns -
    /// - Parameters:
    ///   - view: the view to align leading and trailing anchors with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func sameLeadingTrailing(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal) -> ConstraintCreator {
        ConstraintCreator(constraints: ConstraintCreator.leading(view, constant, relation).constraints +  ConstraintCreator.trailing(view, constant, relation).constraints)
    }

    /// Use this method to align the top and bottom anchors of a view
    /// - Parameters:
    ///   - view: the view to align top and bottom anchors with
    ///   - constant: the constant to be applied while aligning views
    ///   - relation: the Layout constraint relation
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func sameTopBottom(_ view: ConstrainableAnchors, _ constant: CGFloat = 0, _ relation: NSLayoutConstraint.Relation = .equal) -> ConstraintCreator {
        ConstraintCreator(constraints: ConstraintCreator.top(view, constant, relation).constraints +  ConstraintCreator.bottom(view, constant, relation).constraints)
    }

    /// Use this method to align the leading, trailing, top and bottom anchors of a view
    /// - Parameters:
    ///   - view: the view to align all 4 anchors with
    ///   - top: the top constant to be applied while aligning views
    ///   - left: the left constant to be applied while aligning views
    ///   - bottom: the bottom constant to be applied while aligning views
    ///   - right: the right constant to be applied while aligning views
    /// - Returns: ConstraintCreator Object with suitable constraints
    @available(*, deprecated, message: "use `fill(_:top:leading:bottom:trailing)` instead")
    public static func fillSuperView(_ view: ConstrainableAnchors, _ top: CGFloat?, left: CGFloat?, bottom: CGFloat?, right: CGFloat?) -> ConstraintCreator {
        var constraints: [Constraint] = []

        if let leftInset = left {
            constraints += ConstraintCreator.leading(view, leftInset).constraints
        }

        if let bottomInset = bottom {
            constraints += ConstraintCreator.bottom(view, bottomInset).constraints
        }

        if let rightInset = right {
            constraints += ConstraintCreator.trailing(view, rightInset).constraints
        }

        if let topInset = top {
            constraints += ConstraintCreator.top(view, topInset).constraints
        }

        return ConstraintCreator(constraints: constraints)
    }

    /// Use this method to align the leading, trailing, top and bottom anchors of a view
    /// - Parameters:
    ///   - view: the view to align all 4 anchors with
    ///   - constant: the constant to be applied while aligning views
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func fill(_ view: ConstrainableAnchors, _ constant: CGFloat = 0) -> ConstraintCreator {
        ConstraintCreator(constraints: ConstraintCreator.sameLeadingTrailing(view, constant).constraints +  ConstraintCreator.sameTopBottom(view, constant).constraints)
    }

    /// Use this method to align the leading, trailing, top and bottom anchors of a view
    /// - Parameters:
    ///   - view: the view to align all 4 anchors with
    ///   - top: the top constant to be applied while aligning views
    ///   - left: the left constant to be applied while aligning views
    ///   - bottom: the bottom constant to be applied while aligning views
    ///   - right: the right constant to be applied while aligning views
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func fill(_ view: ConstrainableAnchors, top: CGFloat?, leading: CGFloat?, bottom: CGFloat?, trailing: CGFloat?) -> ConstraintCreator {
        var constraints: [Constraint] = []

        if let leadingInset = leading {
            constraints += ConstraintCreator.leading(view, leadingInset).constraints
        }

        if let bottomInset = bottom {
            constraints += ConstraintCreator.bottom(view, bottomInset).constraints
        }

        if let trailingInset = trailing {
            constraints += ConstraintCreator.trailing(view, trailingInset).constraints
        }

        if let topInset = top {
            constraints += ConstraintCreator.top(view, topInset).constraints
        }

        return ConstraintCreator(constraints: constraints)
    }

    /// Use this method to align the leading, trailing, top and bottom anchors of a view
    /// - Parameters:
    ///   - view: the view to align all 4 anchors with
    ///   - insets: inset to be applied on all four directions
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func fill(_ view: ConstrainableAnchors, insets: UIEdgeInsets) -> ConstraintCreator {
        fill(view, top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
    }

    /// Use this create a ratio between width and height of the view
    /// - Parameter value: the ratio provided, will be taken as positive. it should be a ratio of `width/height`
    /// - Returns: ConstraintCreator Object with suitable constraints
    public static func aspectRatio(_ value: CGFloat) -> ConstraintCreator {
        ConstraintCreator(constraints: [Constraint.aspectRatio(ratio: abs(value))])
    }
}

private extension NSLayoutConstraint.Relation {
    func inverse() -> NSLayoutConstraint.Relation {
        switch self {
        case .equal:
            return .equal
        case .greaterThanOrEqual:
            return .lessThanOrEqual
        case .lessThanOrEqual:
            return .greaterThanOrEqual
        @unknown default:
            return self
        }
    }
}
