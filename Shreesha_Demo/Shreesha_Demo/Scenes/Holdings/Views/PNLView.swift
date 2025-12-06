//
//  PNLView.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//


import UIKit
import LayoutKit

final class PNLHeaderView: BaseView {
    
    struct ViewModel {
        let amountText: String        // "₹697.06" or "-₹697.06"
        let percentageText: String    // "(2.44%)"
        let isProfit: Bool            // true -> green, false -> red
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profit & Loss*"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let rightStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private var viewModel: ViewModel? {
        didSet { displayItem() }
    }
    
    // MARK: - BaseView
    
    override func setup() {
        layout()
    }
    
    // MARK: - Public
    
    func configure(with viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    func changeArrowup() {
        arrowImageView.image = UIImage(systemName: "chevron.up")
    }
    
    func changeArrowDown() {
        arrowImageView.image = UIImage(systemName: "chevron.down")
    }
}

// MARK: - Private

private extension PNLHeaderView {
    
    func displayItem() {
        guard let vm = viewModel else { return }
        
        amountLabel.text = vm.amountText
        percentageLabel.text = vm.percentageText
        
        let color: UIColor = vm.isProfit ? .systemGreen : .systemRed
        amountLabel.textColor = color
        percentageLabel.textColor = color
    }
    
    func layout() {
        // Left side: "Profit & Loss*  ▼"
        let leftStack = UIStackView(arrangedSubviews: [titleLabel, arrowImageView])
        leftStack.axis = .horizontal
        leftStack.spacing = 4
        leftStack.alignment = .center
        
        // Right side: "-₹697.06 (2.44%)"
        rightStack.addArrangedSubview(amountLabel)
        rightStack.addArrangedSubview(percentageLabel)
        
        containerStack.addArrangedSubview(leftStack)
        containerStack.addArrangedSubview(rightStack)
        
        addSubview(containerStack)
        
        containerStack.makeConstraint {
            $0.sameLeadingTrailing(self, 16)
            $0.top(self, 8)
        }
    }
}
