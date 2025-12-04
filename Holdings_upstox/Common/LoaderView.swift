//
//  LoaderView.swift
//  CryptoCoins
//
//  Created by Shreesha Kedlaya on 04/12/25.
//

import UIKit
import LayoutKit

final class LoaderView: BaseView {
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func setup() {
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        activityIndicator.color = .white
        addSubview(activityIndicator)
        
        // Center the activity indicator in the view
        activityIndicator.makeConstraint { make in
            make.centerView(self)
        }
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
