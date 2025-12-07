//
//  AnyTableViewCell.swift
//
//  Created by Shreesha Kedlaya on 11/08/24.
//

import Foundation
import UIKit
import LayoutKit

protocol ReusableView: UIView {
    func prepareForReuse()
    func didEndDisplaying()
    func apply(_ layoutAttributes: UICollectionViewLayoutAttributes)
}

extension ReusableView {

    func prepareForReuse() {}
    func didEndDisplaying() {}
    func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {}
}

final class AnyTableViewCell<View: ReusableView>: UITableViewCell {

    let wrappedView: View = View()

    override func prepareForReuse() {
        super.prepareForReuse()
        wrappedView.prepareForReuse()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addWrappedView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addWrappedView()
    }
}

private extension AnyTableViewCell {

    func addWrappedView() {
        self.selectionStyle = .none
        contentView.addSubview(wrappedView)
        wrappedView.set(.fill(contentView))
    }
}
