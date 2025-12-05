//
//  Utility.swift
//  CryptoCoins
//
//  Created by Shreesha Kedlaya on 11/08/24.
//

import Foundation
import UIKit
import Combine

@globalActor
actor CryptoGlobalActor: GlobalActor {
    static let shared = CryptoGlobalActor()
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
    func width(height: CGFloat, fontSize: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize)
        ]
        let attributedText = NSAttributedString(string: self, attributes: attributes)
        let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: height)
        let textWidth = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
        
        return textWidth
    }
}


final class Synchronized<T> {
    private var _value: T

    private let queue: DispatchQueue

    init(_ value: T, qos: DispatchQoS = .userInteractive) {
        _value = value
        let queueLabel = Bundle.init(for: Synchronized.self).bundleIdentifier ?? "" + ".synchronizedQueue"
        self.queue = DispatchQueue(label: queueLabel,
                                   qos: qos,
                                   attributes: .concurrent)
    }

    // A threadsafe variable to set and get the underlying object
    var value: T {
        get { return queue.sync { _value } }
        set { queue.async(flags: .barrier) { self._value = newValue } }
    }

    // A "reader" method to allow thread-safe, read-only concurrent access to the underlying object.
    //
    // - Warning: If the underlying object is a reference type, you are responsible for making sure you
    //            do not mutating anything. If you stick with value types (`struct` or primitive types),
    //            this will be enforced for you.
    func read<U>(_ block: (T) throws -> U) rethrows -> U {
        return try queue.sync { try block(_value) }
    }

    // A "writer" method to allow thread-safe write with barrier to the underlying object
    func write(_ block: @escaping (inout T) -> Void) {
        queue.async(flags: .barrier) {
            block(&self._value)
        }
    }
}

extension UIView {
    func fadeOut(animDuration: TimeInterval = 0.2, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], completion: ((Bool) -> Swift.Void)? = nil) {

        func execute() {
            UIView.animate(withDuration: animDuration, delay: delay, options: options, animations: { [weak self] () in
                self?.alpha = 0.0
                self?.layoutIfNeeded()
            }, completion: { [weak self] (isCompleted) in
                self?.isHidden = true
                if let completionBlock = completion {
                    completionBlock(isCompleted)
                }
            })
        }

        DispatchQueue.main.async {
            execute()
        }

    }

    /**
     Animates the view by varying alpha value.
     */
    func fadeIn(
        finalAlpha: CGFloat = 1.0,
        animDuration: TimeInterval = 0.2,
        delay: TimeInterval = 0.0,
        options: UIView.AnimationOptions = [],
        layoutView: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {

        isHidden = false
        alpha = 0.0

        UIView.animate(withDuration: animDuration, delay: delay, options: options, animations: { [weak self] () in
            self?.alpha = finalAlpha
            if layoutView {
                self?.layoutIfNeeded()
            }
        }, completion: completion)
    }
}


public extension UIApplication {
    static var keyWindow: UIWindow? {
            UIApplication.shared
                .connectedScenes.lazy
                .compactMap { ($0 as? UIWindowScene) }
                .first(where: { $0.keyWindow != nil })?
                .keyWindow
        }
    
    static func keyWindowSafeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            if let window = UIApplication.keyWindow {
                return window.safeAreaInsets
            }
        }
        return UIEdgeInsets.zero
    }

}


extension Formatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹ "
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

extension Double {
    func fmt() -> String {
        Formatter.currencyFormatter.string(from: self as NSNumber) ?? "\(self)"
    }
}


public protocol TaskCancellable: Hashable, Sendable {
    func cancel()
}

extension Task: TaskCancellable {}


extension Task {
    public func store(in set: inout Set<AnyCancellable>) {
        set.insert(AnyCancellable(cancel))
    }
}
