//
//  BaseView.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//

import Foundation
import UIKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {}
}
